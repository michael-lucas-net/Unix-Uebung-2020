#!/bin/sh

# TODO: Change Last Change
# TODO: Funktionsbeschreibung inkl. Parameter
# TODO: Endlosschleife?
# Bash-Calculator | Michael Lucas inf102773 | Last Change: 13.06.2020 - 15:30


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
  printf "ERROR: %s\n" "$1"
}

# Laesst Fehler anzeigen
# Es werden kurze Parameter verwendet, welche zu Texten umgewandelt werden
# und mit der Funktion "printText" ausgegeben werden
showError(){
  local errorCode=1
  if [ "$1" = "wrong-arguments" ]; then
    printText "Wrong arguments were used."
  elif [ "$1" = "no-int" ]; then
    printText "No integer was used"
    errorCode=2
  elif [ "$1" = "div-zero" ]; then
    printText  "Dont div by zero, please"
    errorCode=3
  elif [ "$1" = "mod-zero" ]; then
    printText  "Dont mod with zero, please"
    errorCode=4
  elif [ "$1" = "exp-negative" ]; then
    printText "Dont exp with numbers less than zero, please"
    errorCode=5
  elif [ "$1" = "wrong-operator" ]; then
    printText "Please use a correct operator"
    errorCode=6
  elif [ "$1" = "no-numbers" ]; then
    printText "Please select a correct amount of numbers"
    errorCode=7
  else 
    printText "$1"
    errorCode=8
  fi

  showHelp
  exit "$errorCode"
}

# Ueberprueft, ob die uebergebene Zahl eine ganze Zahl ist
isNumber(){
  if echo "$1" | grep -E -q '^[-]?[[:digit:]]+$'; then
    return 0
  else
    return 1
  fi
}

# Prueft, ob die uebergebene Zahl negativ ist
isNegativeNumber(){
  if [ "$1" -lt 0 ]; then
    return 0
  else 
    return 1
  fi
}

# Prueft, ob der uebergebene Operator auch wirklich ein Operator ist
isOperator(){
  if [ "$1" = "ADD" ] || [ "$1" = "SUB" ] || [ "$1" = "MUL" ] || [ "$1" = "DIV" ] || [ "$1" = "MOD" ] || [ "$1" = "EXP" ]; then
    return 0
  else
    return 1
  fi
}

# power 2 3 -> 8
power() {
  local res=1
  local i=0

  while [ "$i" -ne "$2" ]
  do
    res=$((res * $1))
    i=$((i + 1))
  done

  echo "$res"
}

# Schreibt Geschichte ;)
writeHistory(){
  local history="$1"
  local op="$2"
  local num1="$3"
  local num2="$4"
  if [ -n "$history" ]; then
    history="${history}\n"
  fi
  echo "$history> $op $num1 $num2"
}

# Solange die Anzahl der Parameter ($#) größer 0
while [ $# -gt 0 ];
do

  #Hilfe
  if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then

    # Nur anzeigen, wenn kein weiterer Parameter vorhanden
    if [ -z "$2" ]; then
      showHelp
      exit 0
    else
      showError "wrong-arguments"
    fi

  # Korrekte Zahl
  elif isNumber "$1"; then
    result="$1"
    history=""
    shift

    if [ -z "$1" ]; then  
      showError "wrong-arguments"
    fi

    # -n : not null
    while [ -n "$1" ] && [ -n "$2" ]; do

      # Fuer History Temp-Variable "number1"
      number1="$result"

      number2="$1"
      op="$2"

      if isNumber "$op"; then
        showError "wrong-operator"
      fi

      # Rechnen
      if isNumber "$number2"; then
        case "$op" in
          "ADD")
              result=$(($result + $number2))
            ;;
            "SUB")
              result=$(($result - $number2))
            ;;
            "MUL")
              result=$(($result * $number2))
            ;;
            "DIV")
              if [ "$number2" = 0 ]; then
                showError "div-zero"
              fi
              result=$(($result / $number2))
            ;;
            "MOD")
              if [ "$number2" = 0 ]; then
                showError "mod-zero"
              fi
              result=$(($result % $number2))
            ;;
            "EXP")
              if isNegativeNumber "$number2"; then
                showError "exp-negative"
              fi
              result=$( power "$result" "$number2" ) 
          ;;
        esac

        history=$(writeHistory "$history" "$op" "$number1" "$number2")

      fi
      shift
      shift
    done

  # Keiner zutreffend
  else
    showError "wrong-arguments"
  fi

done

# History ausgeben
if [ -z "$history" ]; then
  showError "wrong-arguments"
else 
  echo "$history" >&2

  # Ergebnis ausgeben
  echo "$result"
fi

exit 0
