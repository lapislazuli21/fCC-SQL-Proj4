#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
declare ATOMIC_NUMBER
if [[ $1 ]]
then
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = '$1'") 
  else
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1' OR name = '$1'")
  fi
  if [[ -z $ATOMIC_NUMBER ]]
  then
    echo -e "I could not find that element in the database."
  else
    PROPERTY_RESULT=$($PSQL "SELECT * FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
    if [[ -z $PROPERTY_RESULT ]]
    then
      echo -e "\nI could not find that element in the database"
    else 
      RES=$($PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number = '$ATOMIC_NUMBER'")
      IFS='|' read -r TYPE_ID MASS MELT BOIL <<< "$RES"
      TYPE=$($PSQL "SELECT type FROM types WHERE type_id = '$TYPE_ID'")
      if [[ -z $TYPE ]]
      then
        echo -e "\nI could not find that element in the database"
      else
        echo $($PSQL "SELECT symbol, name FROM elements WHERE atomic_number = '$ATOMIC_NUMBER'") | while IFS='|' read SYMBOL NAME
        do 
          echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
        done
      fi
    fi
  fi
else
  echo "Please provide an element as an argument."
fi