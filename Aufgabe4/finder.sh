#!/bin/bash

# +--------------------------------------+----------------------------------------------------------------------+
# |                               Finder - Michael Lucas inf102773                                      	|
# +--------------------------------------+----------------------------------------------------------------------+
# | Beschreibung                         | Dieses Skript durchsucht HTML-Seiten.				|
# | Letzte Aenderung                     | 29.06.2020                                                         	|
# +--------------------------------------+----------------------------------------------------------------------+
# | Aufruf                               | -h / --help 					=> Hilfeausgabe		|
# | 		                     	 | FILE -s STRING --search 		=> Sucht FAQ-Dateien nach String|
# | 		                 	 | FILE -c T G / --calendar T G => Sucht in Dateien nach Tag und Gruppen|
# | 		                     	 | FILE -g X / --group X 		=> Sucht Dateien nach GRP / MatrikelNr.	|
# | Beispiel-Aufruf                      | finder.sh cache/faq.html -s "Was sind die"                         	|
# | Beispiel-Ausgabe (stdout)            | Was sind die Kommunikationskanäle für die Übungen?			|
# +--------------------------------------+----------------------------------------------------------------------+

# Gibt die Hilfe aus 
showHelp() {
    echo "Usage:
finder.sh -h | finder.sh --help
  print this help and exit

finder.sh HTML-FILE OPTION

  where HTML-FILE
    is a file ending with .html and beginning with a specific PREFIX for each OPTION

  where OPTION is one of
    -s CHARS, --search CHARS
         extract and print all <h3>-headlines containing the given character string
         where CHARS
               is the searched for character string
         and PREFIX for HTML-FILE is: faq

    -g SID, -g GROUPNO, --group SID, --group GROUPNO
         extract and print the timeslot, group and student-ID(s) for a given group number or student-ID
         where SID
               is a string containing 3 or 4 alphabetic signs (optional) followed by exactly 6 digits
         where GROUPNO
               is a two-digit number
         and PREFIX for HTML-FILE is: gruppen

    -c DAY SUBGROUP, --calendar DAY SUBGROUP
          extract all calendar dates belonging to the given weekday and subgroup
          where DAY
                is a weekday between 'Montag' and 'Freitag' (in German)
          where SUBGROUP
                is either A or B
         and PREFIX for HTML-FILE is: kalender"
}

# Gibt eine Fehlermeldung auf stderr aus
# und beendet das Programm mit dem dazugehoerigen Errorcode (> 0)
# Params: $1 kurzer Error Text
# Return: Error Beschreibung für den Nutzer
# Stderr: errorCode > 0
showError() {
	local errorCode=1
	local errorText=""

	if [ "$1" = "wrong-arguments" ]; then
		errorText="Wrong arguments where used."
	elif [ "$1" = "no-arguments" ]; then
		errorText="There are no arguments."
		errorCode=2
	elif [ "$1" = "wrong-file" ]; then
		errorText="The given file does not fit the requirements."
		errorCode=3
	elif [ "$1" = "wrong-group" ]; then
		errorText="Wrong group! Only 'A' & 'B' allowed"
		errorCode=4
	elif [ "$1" = "wrong-day" ]; then
		errorText="Wrong day! Only days from Monday-Friday are allowed."
		errorCode=5
	elif [ "$1" = "no-html" ]; then
		errorText="Wrong file ending! Please only use HTML-files!"
		errorCode=6
	elif [ "$1" = "wrong-group-number" ]; then
		errorText="Wrong matriculation or group number!"
		errorCode=7
	fi

	printf "ERROR: %s\n" "$errorText" >&2
	showHelp >&2
	exit "$errorCode"
}

# Gibt den uebergebenen Parameter in Großbuchstaben wieder aus
# Params: $1 String, der uppercased wird
# Return: uppercased String
toUpper(){
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Prueft, ob der uebergebene Parameter eine Zahl ist
# Params: $1 - Wird ueberprueft, ob eine Zahl
# Return: true, wenn eine Zahl
isNumber(){
  if echo "$1" | grep -E -q '^[-]?[[:digit:]]+$'; then
    echo true
  else
    echo false
  fi
}

# Gibt den Index fuer das Reihenueberspringen eines Tages aus
# Montag ist 2, weil fuer das korrekte Springen muss immer 1 addiert werden
# Params: $1 String, der ein Wochentag sein kann
# Return: index 0, wenn kein Tag, sonst > 0
getIndexOfDay(){
    index=0
	if [ "$1" = "montag" ]; then
		index=2
	elif [ "$1" = "dienstag" ]; then
		index=3
	elif [ "$1" = "mittwoch" ]; then
		index=4
	elif [ "$1" = "donnerstag" ]; then
		index=5
	elif [ "$1" = "freitag" ]; then
		index=6
	fi

    echo "$index"
}

# Pruefen, ob es Parameter gibt
# Es kann bis zu 4 Parameter geben (FAQ 3 | Kalender 4 | Gruppen 3)
if [ $# -gt 0 ]; then
	# Hilfe-Ausgabe
	if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
		if [ -z "$2" ]; then
			showHelp
			exit 0
		else
			showError "wrong-arguments"
		fi
	fi

	# FAQ, Kalender oder Gruppensuche
	if [ -z "$2" ] || [ -z "$3" ]; then
		showError "wrong-arguments"
	else

		# Pruefen, ob Datei mit HTML endet!
		if echo "$1" | grep -ivq ".html$"; then
			showError "no-html"
		fi

		# --------------------------------------------------------------------------------- #
		# ==== FAQ ====
		# --------------------------------------------------------------------------------- #
		if [[ "$2" = "-s" || "$2" = "--search" ]]; then
			# Dateiname muss "faq" enthalten
			# i: case insensitive
			# v: negieren
			# q: ohne output (ich moechte nur pruefen und nichts ausgeben)
			if echo "$1" | grep -ivq faq; then
				showError "wrong-file"
			fi

			# 1: Leerzeilen vor und nach <h3> einfuegen
			# 2: HTML-Kommentare entfernen
				# -> sucht nach Kommentare und ersetzt sie
				# -> falls noch einer vorkommt, ersetzt er nochmals
			# 3: nur noch die h3 Uberschriften nehmen
			# 4: Nach uebergebenen Parameter suchen
			# 5: <(/)h3> entfernen
			cat "$1" \
			| sed 's/<h3>/\n<h3>/g; s/<\/h3>/<\/h3>\n/g;' \
			| sed -e :start -re 's/<!--.*?-->//g; /<!--/N;//bstart' \
			| grep "<h3>.*</h3>" -i \
			| grep "$3" -i \
			| sed "s/<[/]*[hH]3>//g;"

		# --------------------------------------------------------------------------------- #
		# ==== Kalender ====
		# --------------------------------------------------------------------------------- #
		elif [[ "$2" = "-c" || "$2" = "--calendar" ]]; then
			# Wenn ein Parameter zu viel, dann Fehler
			if [ -z "$4" ]; then
				showError "wrong-arguments"
			fi

			# Dateiname muss "kalender" enthalten
				# -i = ignore case
				# -v = reverse
				# -q = keine Ausgabe (ich moechte ja nur pruefen)
			if echo "$1" | grep -ivq kalender; then
				showError "wrong-file"
			fi

			# Tag in klein (fuer z.B. dienstags) und Gruppe in groß
			day=$(echo "$3" | tr '[:upper:]' '[:lower:]')
			grp=$(echo "$4" | tr '[:lower:]' '[:upper:]')

			# Gruppe muss entweder a oder b sein
			if [ "$grp" != "A" ] && [ "$grp" != "B" ]; then
				showError "wrong-group"
			fi

			# Tag muss [Montag-Freitag] sein
			if [ $(getIndexOfDay "$day") -gt 0 ]; then
				textDay="${day}s"
				dayIndex="$(getIndexOfDay "$day")"

				echo "Gruppe $grp - $textDay"

				# 1: neue Zeilen bei <tr>s (fuer compacted)
				# 2: neue Zeilen bei <td>s (fuer compacted)
				# 3: HTML-Kommentare entfernen (Beschreibung oben bei FAQ)
				# 4: Alles außer <tr>.*</tr> entfernen
				# 5: Leerzeilen entfernen
				# 6: Richtige Zeile anhand des Index waehlen
					# -> es gibt 7 Zeilen (2 <tr> und 5 <td>) 
					# -> in einer der 5 <td> steht der relevante Inhalt
					# -> Montag steht in der zweiten Zeile (deshalb index 2)
				# 7: Kalendereintrag kann z.B. sein: A1 (Inf: B)
				# 8: Divs waehlen, wo das Datum drin steht
				# 9: Divs und sonstige Html-Tags entfernen
				# 10: |- vor Datum hinzufügen
				cat "$1" \
					| sed 's/<tr>/\n<tr>/g; s/<\/tr>/<\/tr>\n/g;' \
					| sed 's/<td.*>/\n&/g; s/<\/td>/<\/td>\n/g;' \
					| sed -e :branch -re 's/<!--.*?-->//g; /<!--/N;//bbranch' \
					| sed -n "/<tr>/I,/<\/tr>/Ip" \
					| grep "\S" \
					| sed -n "$dayIndex~7p" \
					| grep -i "[AB][1-5] (.*: $grp" \
					| grep -o -i "<div.*>.*<\/div>" \
					| sed "s/<[^>]*>//g" \
					| sed "s/.*/|- &/g"
			else
				showError "wrong-day"
			fi

		# --------------------------------------------------------------------------------- #
		# ==== Gruppen ====
		# --------------------------------------------------------------------------------- #
		elif [[ "$2" = "-g" || "$2" = "--group" ]]; then

			# Nicht genug Parameter
			if [ -z "$3" ]; then
				showError "wrong-arguments"
			fi

			# Pruefen, ob Praefix "gruppe" enthalten
			if echo "$1" | grep -ivq gruppen; then
				showError "wrong-file"
			fi

			# 1: bei <tr> neue Zeilen hinzufeugen (fuer compact)
			# 2: Alles außer <tr>.*</tr> entfernen
			# 3: HTML-Kommentare entfernen (Beschreibung oben)
			# 4: Die ersten 5 Zeilen entfernen (sind <th> Ueberschriften und daher irrelevant)
			# 5: Zeilenumbrueche entfernen und nur nach </tr> hinzufuegen, 
			#    damit alle Infos pro Gruppe in einer Reihe sind
				# :label erstellt ein Label,
				# :N aktuelle und neachste Zeile hinzufuegen
				# $!blabel: falls noch Zeilen fehlen, wieder zu label
			data=$(cat "$1" \
				| sed 's/<tr>/\n<tr>/g; s/<\/tr>/<\/tr>\n/g;' \
				| sed -n "/<[TRtr]*>/I,/<\/[TRtr]*>/Ip" \
				| sed -e :branch -re 's/<!--.*?-->//g; /<!--/N;//bbranch' \
				| tail -n +6 \
				| sed ':label;N;$!blabel;s/\n//g; s/<\/[TRtr]*>/<\/tr>\n/g;')

			# Pruefen, ob nach Gruppennummer oder Matrikelnummer gesucht werden soll
			# Gruppen 2 Stellig, Matrik. 6 bis 10 stellig
			# Gruppennummer
			length=${#3}
			if [[ "$length" -eq 2 && $(isNumber $3) ]]; then
				data=$(echo "$data" | grep -i ".*<td.*>$3<\/td>.*")
			# Matrikelnummer
			elif [[ "$length" -eq 6 || "$length" -gt 8  && "$length" -lt 11 ]]; then
				data=$(echo "$data" | grep -i "<tr>.*$3.*")
			else 
				showError "wrong-group-number"
			fi

			# 1: Neue Zeilen vor und nach <(/)td> hinzufuegen
			# 2: Alle HTML-Tags entfernen
			# 3: Leerzeichen entfernen
			# 4: Leerzeilen entfernen
			data=$(echo "$data" | sed 's/<[TDtd]*.*>/\n&/g; s/<\/[TDtd]*>/<\/td>\n/Ig;' \
				| sed "s/<[^>]*>//g" \
				| sed "s/  //g; s/^ //g;" \
				| grep "\S")

			# Daten der Uebersicht halber auflisten
			meeting=$(echo "$data" | sed -n 1p)
			foundGrp=$(echo "$data" | sed -n 2p)
			mat1=$(echo "$data" | sed -n 3p)
			mat2=$(echo "$data" | sed -n 4p)
			member="$mat1"

			# 2tes Gruppenmitglied hinzufuegen, falls vorhanden
			if [ -n "$mat2" ]; then
				member="$mat1 $mat2"
			fi

			# Ausgabe
			if [ -n "$member" ]; then
				echo "Gruppe:       $foundGrp"
				echo "Mitglied(er): $member"
				echo "Termin:       $meeting"
			fi			
		# --------------------------------------------------------------------------------- #
		# ==== ENDE ====
		# --------------------------------------------------------------------------------- #	
		else
		    showError "wrong-arguments"
		fi
	fi
else
	showError "no-arguments"
fi
