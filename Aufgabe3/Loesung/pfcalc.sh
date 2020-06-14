#!/bin/sh

# +--------------------------------------+--------------------------------------------------------------------+
# |                                 Calculator - Michael Lucas inf102773                                      |
# +--------------------------------------+--------------------------------------------------------------------+
# | Beschreibung                         | Dieses Skript ist ein kleiner Taschenrechner mit Postfix-Notation. |
# | Last Change                          | 14.06.2020                                                         |
# | Aufruf                               | -h / --help => Hilfeausgabe | NUM1 NUM2 OP [...] => Berechnung     |
# | Beispiel-Aufruf                      | pfcalc.sh 5 7 ADD 2 DIV => 6                                       |
# | Historie -Ausgabe                    | > ADD 5 7                                                          |
# |                                      | > DIV 12 2                                                         |
# +--------------------------------------+--------------------------------------------------------------------+

# Gibt die Hilfe aus
showHelp(){
  cat << buffer
Usage:
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
is printed out to stderr.
buffer
}

# Gibt uebergebenen Text aus.
printError(){
  printf "ERROR: %s\n" "$1" >&2
}

# Laesst Fehler anzeigen
# Es werden kurze Parameter verwendet, welche zu Texten umgewandelt werden
# und mit der Funktion "printError" ausgegeben werden
showError(){
  local errorCode=1
  local errorText=""
  if [ "$1" = "wrong-arguments" ]; then
    errorText="Wrong arguments were used."
  elif [ "$1" = "no-int" ]; then
    errorText="No integer was used"
    errorCode=2
  elif [ "$1" = "div-zero" ]; then
    errorText="Dont div by zero, please"
    errorCode=3
  elif [ "$1" = "mod-zero" ]; then
    errorText="Dont mod with zero, please"
    errorCode=4
  elif [ "$1" = "exp-negative" ]; then
    errorText="Dont exp with numbers less than zero, please"
    errorCode=5
  elif [ "$1" = "wrong-operator" ]; then
    errorText="Please use a correct operator"
    errorCode=6
  elif [ "$1" = "no-numbers" ]; then
    errorText="Please select a correct amount of numbers"
    errorCode=7
  else 
    errorText="$1"
    errorCode=8
  fi

  printError "$errorText"
  showHelp
  exit "$errorCode"
}

# Ueberprueft, ob die uebergebene Zahl eine ganze Zahl ist
isNumber(){
  if echo "$1" | grep -E -q '^[-]?[[:digit:]]+$'; then
    echo true
  else
    echo false
  fi
}

# Rekursive Loesung fuer Exponentialrechnung
# Beispielaufruf: Power 2 3
# $1 = 2
# $2 = 3
power() {
  if [ $2 -eq 0 ]; then
    echo 1
  else
    # z.B. 2 * Power 2 2
    echo $(($1 * $(power $1 $(($2 - 1)))))
  fi
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
  elif $(isNumber "$1"); then
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

      if $(isNumber "$op"); then
        showError "wrong-operator"
      fi

      # Rechnen
      if $(isNumber "$number2"); then
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
              if [ "$number2" -eq 0 ]; then
                showError "div-zero"
              fi
              result=$(($result / $number2))
            ;;
            "MOD")
              if [ "$number2" -eq 0 ]; then
                showError "mod-zero"
              fi
              result=$(($result % $number2))
            ;;
            "EXP")
             # Bei negativer Zahl Fehler ausgeben
             if [ "$number2" -lt 0 ]; then
                showError "exp-negative"
              fi
              result=$( power "$result" "$number2" ) 
          ;;
          *)
            showError "wrong-operator"
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

# History und Ergebnis ausgeben
if [ -z "$history" ]; then
  showError "wrong-arguments"
else 
  echo "$history" >&2
  echo "$result"
fi

exit 0
