#!/bin/bash

# TODO: Change Last Change xD
# Bash-Calculator | Michael Lucas inf102773 | Last Change: 13.06.2020 - 01:09

lastNum="-1"
num1="-1"
num2="-1"
op=""

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
  elif [ "$1" == "div-zero" ]; then
    printText  "Dont div by zero, please"
  elif [ "$1" == "mod-zero" ]; then
    printText  "Dont mod with zero, please"
  elif [ "$1" == "wrong-operator" ]; then
    printText "Please use a correct operator"
  elif [ "$1" == "no-numbers" ]; then
    printText "Please select a correct amount of numbers"
  else 
    printText "$1"
  fi

  showHelp
  exit 1
}

# Ueberprueft, ob die uebergebene Zahl eine ganze Zahl ist
isNumber(){
  #TODO: Check, ob wirklich nur ints erlaubt sind
  if [[ "$1"  =~ ^-?[0-9]+$ ]]; then
    return 0
  else 
    return 1
  fi
}

# Prueft, ob der uebergebene Operator auch wirklich ein Operator ist
isOperator(){
  if [ "$1" == "ADD" ] || [ "$1" == "SUB" ] || [ "$1" == "MUL" ] || [ "$1" == "DIV" ] || [ "$1" == "MOD" ] || [ "$1" == "EXP" ]; then
    return 0
  else
    return 1
  fi
}

# Setzt die richtige Zahl auf den uebergebenen Wert
# Ich gehe davon aus, das die Funktion korrekt aufgerufen wird
setNumber(){
  case "$lastNum" in
    -1 | 2)
      num1=$1
      lastNum=1
      ;;

    1)
      num2=$1
      lastNum=2
      ;;
    esac
}

# Setzt nach einer Berechnung die Variablen zurueck
setVars(){
  op=""
  num2="-1"
  lastNum="1"
}

# Rechnet das Ergebnis aus und schreibt es auf "num1"
# Pruefungen wurden vorher erledigt (bis auf 0 check bei div und mod)
calculate(){
    case "$op" in
    "ADD")
      num1=$(("$num1" + "$num2"))
    ;;
    "SUB")
      num1=$(("$num1" - "$num2"))
    ;;
    "MUL")
      num1=$(("$num1" * "$num2"))
    ;;
    "DIV")
      if [ "$num2" == 0 ]; then
        showError "div-zero"
      else
        num1=$(("$num1" / "$num2"))
      fi
    ;;
    "MOD")
      if [ "$num1" == 0 ]; then
        showError "mod-zero"
      else
        num1=$(("$num1" % "$num2"))
      fi 
    ;;
    "EXP")
      num1=$(("$num1" ** "$num2"))
    ;;
  esac
}

printHistory() {
 echo ">" "$op" "$num1" "$num2" >&2
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

  # Keine korrekte Zahl
  elif ! isNumber "$1"; then

    # Pruefen ob Operator
    if ! isOperator "$1"; then
      showError "wrong-operator"
    else
      op="$1"

      # Gibt zwar Operator, aber keine Zahlen
      if [ ! "$num1" -gt 0 ] || [ ! "$num1" -gt 0 ] ; then
        showError "no-numbers"
      else
        # Rechnen
        printHistory
        calculate
        setVars
      fi
    fi

  # Korrekte Zahl
  elif isNumber "$1"; then
    setNumber "$1" 

  # Keiner zutreffend
  else
    showError "wrong-arguments"
  fi

  shift
done

  # Ergebnis ausgeben
  echo "$num1"
