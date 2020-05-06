#!/bin/sh
# Michael Lucas - Gruppe 17

# Ordner erstellen -p = Ignorieren, falls bereits vorhanden
mkdir -p info

# Alle Textdateien in mytextfiles schreiben.
# 2> /dev/null = Fehlermeldung verstecken
ls *.txt 2> /dev/null > ./info/mytextfiles.txt