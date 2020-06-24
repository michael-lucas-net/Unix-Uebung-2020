#!/bin/bash

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
	fi

	printf "Error: %s\n" "$errorText" >&2
	showHelp >&2
	exit "$errorCode"	
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
				cat "$1" | sed 's/<h3>/\n<h3>/g; s/<\/h3>/<\/h3>\n/g;' | sed -e :branch -re 's/<!--.*?-->//g; /<!--/N;//bbranch' | grep "<h3>.*</h3>" -i | grep "$3" -i | sed "s/<[/]*[hH]3>//gi;"
			else
				showError "wrong-file"
			fi
		# Kalender
		elif [ "$2" = "-c" ]; then
			echo "Kalender-Suche"
		else
		      showError "wrong-arguments"	
		fi

	fi
else
	showError "no-arguments"
fi
