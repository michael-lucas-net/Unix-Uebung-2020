#!/bin/bash

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
showError() {
	local errorCode=1
	local errorText=""

	if [ "$1" = "wrong-arguments" ]; then
		errorText="Wrong arguments where used."
	elif [ "$1" = "no-arguments" ]; then
		errorText="There are no arguments."
	elif [ "$1" = "wrong-file" ]; then
		errorText="The given file does not fit the requirements."
	elif [ "$1" = "wrong-group" ]; then
		errorText="Wrong group! Only 'A' & 'B' allowed"
	elif [ "$1" = "wrong-day" ]; then
		errorText="Wrong day! Only days from Monday-Friday are allowed."
	fi

	printf "Error: %s\n" "$errorText" >&2
	showHelp >&2
	exit "$errorCode"	
}

# Gibt den uebergebenen Parameter in Kleinbuchstaben wieder aus
toLower(){
	echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Gibt den uebergebenen Parameter in Großbuchstaben wieder aus
toUpper(){
	echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Gibt den Index fuer das Reihenueberspringen eines Tages aus
# Montag ist 2, weil fuer das korrekte Springen muss immer 1 addiert werden
getIndexOfDay(){
	day="$(toLower "$1")"
	if [ "$day" = "montag" ]; then
		echo "2"
	elif [ "$day" = "dienstag" ]; then
		echo "3"
	elif [ "$day" = "mittwoch" ]; then
		echo "4"
	elif [ "$day" = "donnerstag" ]; then
		echo "5"
	elif [ "$day" = "freitag" ]; then
		echo "6"
	fi	
}

# Prueft, ob der uebergebene Parameter ein gueltiger (MO-FR) Tag ist
# TODO: Schleifen nicht erlaubt
isCorrectDay(){
	local isCorrect="false"
	local day=$(toLower "$1")
	days="montag dienstag mittwoch donnerstag freitag"

	for d in ${days[*]}
	do
		if [ "$d" = "$day" ]; then
			isCorrect="true"
		fi		
	done

	echo "$isCorrect"
}

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

	# FAQ oder Kalender
	if [ -z "$2" ] || [ -z "$3" ]; then
		showError "wrong-arguments"
	else
		# FAQ
		if [ "$2" = "-s" ]; then
			# Dateiname muss "faq" enthalten
			if [[ "$1" = *"faq"* ]]; then
				# TODO: WTF https://stackoverflow.com/questions/4055837/delete-html-comment-tags-using-regexp
				cat "$1" \
				| sed 's/<h3>/\n<h3>/g; s/<\/h3>/<\/h3>\n/g;' \
				| sed -e :branch -re 's/<!--.*?-->//g; /<!--/N;//bbranch' \
				| grep "<h3>.*</h3>" -i \
				| grep "$3" -i \
				| sed "s/<[/]*[hH]3>//gi;"
			else
				showError "wrong-file"
			fi

		# Kalender
		elif [ "$2" = "-c" ]; then
			if [ -z "$4" ]; then
				showError "wrong-arguments"
			fi

			# Dateiname muss "kalender" enthalten
			if [[ "$1" = *"kalender"* ]]; then
				day="$3"
				grp=$(toUpper "$4")

				# Gruppe muss entweder a oder b sein
				if [ $(toLower "$grp") != "a" ] && [ $(toLower "$grp") != "b" ]; then
					showError "wrong-group"
				fi


				# Tag muss [Montag-Freitag] sein
				if $(isCorrectDay "$day"); then
					textDay="$(toLower "$day")"
					textDay="${textDay}s"
					dayIndex="$(getIndexOfDay "$day")"

					echo "Gruppe \"$grp\" - \"$textDay\""

					# als erstes wird alles entfernt, außer Inhalt zwischen <tr>***</tr>
					# als zweites immer $dayIndex schritte (von 7) weitergehen
					# 	-> es gibt immer 5 tds innerhalb von 1 tr -> 7
					# Nur relevante Datum finden (z.B: A2 (WInf: B))
					# jetzt nur noch Daten innerhalb von div.date anzeigen
					# div.date enternen, sodass nur noch der Inhalt davon (also die Datum) zu sehen ist
					# Datum mit "|- " beginnen lassen
					cat "$1" \
						| sed -n "/<tr>/,/<\/tr>/p" \
						| sed -n "$dayIndex~7p" \
						| grep "[AB][1-5] (.*: $grp" \
						| grep -o "<div class=\"date\">.*<\/div>" \
						| sed "s/<div class=\"date\">//g; s/<\/div>//g;" \
						| sed "s/.*/|- &/g"
				else
					showError "wrong-day"	
				fi	
			else
				showError "wrong-file"
			fi
		else
		      showError "wrong-arguments"	
		fi
	fi
else
	showError "no-arguments"
fi
