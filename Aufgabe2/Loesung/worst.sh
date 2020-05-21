#!/bin/sh

# Wertet fiktive Umfragetools aus.
# Muster sind (Kennzahl, Bewertung, Text)

# grep: nach Muster suchen
    # ",*," - Eintraege sind (a, b, c)
# sort: Sortiert Text
    # -k2 = Sortiert nach 2tem Key (a, >b<, c)
# tee: Ausgabe in Console und Datei

# Fuer STDOUT
    # tail: Nur letzte Zeile nehmen
    # cut: Schneided Text ab
        # -d: teilt Text anhand von ',' auf
        # -f3 letzte Stelle (a, b, >c<)

# TODO: Wenn Werte glech sind, soll erste Zeile verglichen werden
grep ",*," | sort -k2 | tee "$1" | tail -n1 | cut -d "," -f3
