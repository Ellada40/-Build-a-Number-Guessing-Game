#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number between 1-1000
RANDOM_NUMBER=$(( ( $RANDOM % 1000 ) + 1 )) 

# Get username
echo -e "\nEnter your username:"
read USERNAME

USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

# Check If that username has been used before
if [[ -z $USER ]]
then 
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME')"  > /dev/null
else
  echo -e "\nWelcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Get user input
echo -e "\nGuess the secret number between 1 and 1000:"
GUESSES=0

while true
do 
  read USER_GUESS
  (( GUESSES++ ))

  # Check if integer
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
    continue
  fi

  if [[ $USER_GUESS -gt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  else
    echo -e "\nYou guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

    # Update games played
    $PSQL "UPDATE users SET games_played=games_played+1 WHERE username='$USERNAME'"  > /dev/null

    # Update best game only if better
    $PSQL "UPDATE users SET best_game=$GUESSES WHERE username='$USERNAME' AND (best_game IS NULL OR $GUESSES < best_game)"  > /dev/null

    break
  fi
done
