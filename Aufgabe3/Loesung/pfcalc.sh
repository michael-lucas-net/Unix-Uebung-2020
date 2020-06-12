#!/bin/bash

# Gibt die Hilfe aus
showHelp(){
echo "Usage:
pfcalc.sh -h | pfcalc.sh --help

  prints this help and exits

pfcalc.sh NUM1 NUM2 OP [NUM OP] ...

  provides a simple calculator using a postfix notation. A call consists of
  two numbers and an operation optionally followed by an arbitrary number
  of number-operation pairs.

  NUM1, NUM2 and NUM are treated as integer numbers.

  NUM is treated in the same way as NUM2 whereas NUM1 in this case is the
  result of the previous operation.

  OP is one of:
    ADD - adds NUM1 and NUM2
    SUB - subtracts NUM2 from NUM1
    MUL - multiplies NUM1 and NUM2
    DIV - divides NUM1 by NUM2 and returns the integer result
    MOD - divides NUM1 by NUM2 and returns the integer remainder
    EXP - raises NUM1 to the power of NUM2

At the end of a successful call the history of all intermediate calculations 
is printed out to stderr."
}

# Gibt uebergebenen Text aus.
# Methode erstellt, um Code-Verdopplung zu sparen und 
# Darstellung zu verschoenern
printText(){
  printf "\n"
  echo "  ----------------------------"
  printf "   %s\n" "$1"
  echo "  ----------------------------"
  printf "\n"
}

# Laesst Fehler anzeigen
# Es werden kurze Parameter verwendet, welche zu Texten umgewandelt werden
# und mit der Funktion "printText" ausgegeben werden
showError(){
  if [ "$1" == "wrong-arguments" ]; then
    printText "Wrong arguments were used."
  elif [ "$1" == "no-int" ]; then
    printText "No integer was used"
  fi

  showHelp
  exit 1
}

isNumber(){
  if [[ "$1"  =~ ^[0-9]+$ ]]; then
    return 0
  else 
    return 1
  fi
}

# Solange die Anzahl der Parameter ($#) größer 0
while [ $# -gt 0 ];
do

  #Hilfe
  if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then

    # Nur anzeigen, wenn kein weiterer Parameter vorhanden
    if [ -z "$2" ]; then
      showHelp
      exit 0
    else
      showError "wrong-arguments"
    fi

  # Zahlen
  elif ! isNumber "$1"; then
    showError "no-int"

  elif isNumber "$1"; then
    echo "Scheint korrekt zu sein"

  # Keiner zutreffend
  else
    showError "wrong-arguments"
  fi

  shift
done
