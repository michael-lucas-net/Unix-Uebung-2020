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

# Prueft, ob der uebergebene Parameter ein gueltiger (MO-FR) Tag ist
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
			if [[ "$1" = *"faq"* ]]; then
				# TODO: WTF https://stackoverflow.com/questions/4055837/delete-html-comment-tags-using-regexp
				cat "$1" \
				# Leerzeilen hinzufuegen
				| sed 's/<h3>/\n<h3>/g; s/<\/h3>/<\/h3>\n/g;' \
				# Kommentare entfernen
				| sed -e :branch -re 's/<!--.*?-->//g; /<!--/N;//bbranch' \
				# h3s auslesen
				| grep "<h3>.*</h3>" -i \
				# Nach Text filtern
				| grep "$3" -i \
				# h3s entfernen
				| sed "s/<[/]*[hH]3>//gi;"
			else
				showError "wrong-file"
			fi

		# Kalender
		elif [ "$2" = "-c" ]; then
			if [ -z "$4" ]; then
				showError "wrong-arguments"
			fi

			if [[ "$1" = *"kalender"* ]]; then
				day="$3"
				dayShort=$(echo "$day" | cut -c1-2)
				grp=$(toUpper "$4")

				if [ $(toLower "$grp") != "a" ] && [ $(toLower "$grp") != "b" ]; then
					showError "wrong-group"
				fi
				
				if $(isCorrectDay "$day"); then
					textDay="$(toLower "$day")"
					textDay="${textDay}s"				
					echo "Gruppe $grp - $textDay"		

					# TODO: Fertigstellen (Tag fehlt noch)

					cat "$1" \
					# Gruppe finden
					| grep ": $grp"  \
					# Nur Datum ausgeben
					| grep -o "<div class=\"date\">.*</div>"  \
					# div usw. entfernen
					| sed "s/<div class=\"date\">//g; s/.<\/div>//g;"

				else
					showError "wrong-day"	
				fi
				echo "Datei: $1 | Tag: $day | grp: $4"			
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
