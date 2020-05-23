#!/bin/sh

# Wertet fiktive Umfragetools aus.# Muster sind(Kennzahl, Bewertung, Text)

# grep: nach Muster suchen
    # ",*," - Eintraege sind (a, b, c)
# sort: Sortiert Text
    # - t "," Laesst nach Key sortieren
    # - k2 = Sortiert nach 2 tem Key (a, > b <, c)
    # - k1 sortiert zudem nach erstem ersten Key (in dem Fall Kennzahl) NACHDEM die Bewertung sortiert wurde
    # - r Absteigend
    # - n numerisch sortieren (beruecksichtigt z.B. 10 > 9)
# tee: Ausgabe in Console und Datei

# Fuer STDOUT
    # tail: Nur letzte Zeile nehmen
    # cut: Schneidet Text ab
    # - d: teilt Text anhand von ',' auf
    # - f3 letzte Stelle(a, b, > c <)
grep -v "***error***"  | grep ",*," | sort -t ',' -k2 -k1 -r -n | tee "$1" | tail -n1 | cut -d "," -f3
