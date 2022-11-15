#!/bin/bash

# Gives information about atomic number, symbol or element given as argument

# Create PSQL command in order to query the database
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"


# In case invalid argument is provided
MESSAGE_IF_INVALID() {
  echo "I could not find that element in the database."
}

MESSAGE_IF_VALID() {
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

GET_INFORMATION() {
  # Format atomic number
  ATOMIC_NUMBER=$(echo $RAW_ATOMIC_NUMBER | sed 's/^ *//g')

  # Get name and format it
  RAW_NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  NAME=$(echo $RAW_NAME | sed 's/^ *//g')
    
  # Get symbol and format it
  RAW_SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  SYMBOL=$(echo $RAW_SYMBOL | sed 's/^ *//g')
    
  # Get type and format it
  RAW_TYPE=$($PSQL "SELECT type FROM properties INNER JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
  TYPE=$(echo $RAW_TYPE | sed 's/^ *//g')

  # Get mass and format it
  RAW_MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  MASS=$(echo $RAW_MASS | sed 's/^ *//g')
    
  # Get melting point and format it
  RAW_MELTING_POINT=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  MELTING_POINT=$(echo $RAW_MELTING_POINT | sed 's/^ *//g')

  # Get boiling point and format it
  RAW_BOILING_POINT=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
  BOILING_POINT=$(echo $RAW_BOILING_POINT | sed 's/^ *//g')   
}

# In case no argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
# In case argument is a number
elif [[ $1 =~ ^[0-9]+$ ]]
then
  # Check if number is in the atomic_number column
  CHECK_ATOMIC_NUMBER=$($PSQL "SELECT EXISTS(SELECT 1 FROM elements WHERE atomic_number = $1)")

  # If atomic_number column contains input, get information and output it
  if [[ $CHECK_ATOMIC_NUMBER ]]
  then
    # Get atomic_number
    RAW_ATOMIC_NUMBER=$1

    # Get information
    GET_INFORMATION

    # Output formatted information
    MESSAGE_IF_VALID
  fi
# In case argument is a symbol
elif [[ $1 =~ ^[A-Z][a-z]{0,1}$ ]]
then
  # Check if symbol is in the symbol column
  CHECK_SYMBOL=$($PSQL "SELECT EXISTS(SELECT 1 FROM elements WHERE symbol = '$1')")

  # If symbol column contains input, get information and output it
  if [[ $CHECK_SYMBOL ]]
  then
    # Get atomic_number without any formatting
    RAW_ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")

    # Get information
    GET_INFORMATION

    # Output formatted information
    MESSAGE_IF_VALID
  fi
# In case argument is a name
elif [[ $1 =~ ^[A-Z][a-z]{2,}$ ]]
then
  # Check if name is in the name column
  CHECK_NAME=$($PSQL "SELECT EXISTS(SELECT 1 FROM elements WHERE name = '$1')")

  # If name column contains input, get information and output it
  if [[ $CHECK_NAME ]]
  then
    # Get atomic_number without any formatting
    RAW_ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")

    # Get information
    GET_INFORMATION

    # Output formatted information
    MESSAGE_IF_VALID
  fi
# In case argument can't be found in the elements table
else
  echo "I could not find that element in the database."
fi