#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TARGET=$((1+$RANDOM%1000))

COUNT=0

echo -e "\nEnter your username:"
read USERNAME
USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

GUESS_GAME () {
  read GUESS
  if [[ $GUESS =~ ^-?[0-9]+$ ]]
  then
    if (( $GUESS == $TARGET ))
    then
	    COUNT=$(( $COUNT + 1 ))
      echo -e "\nYou guessed it in $COUNT tries. The secret number was $TARGET. Nice job!\n"
    elif (( $GUESS > $TARGET ))
    then
      echo -e "\nIt's lower than that, guess again:"
      COUNT=$(( $COUNT + 1 ))
      GUESS_GAME
    else
      echo -e "\nIt's higher than that, guess again:"
      COUNT=$(( $COUNT + 1 ))
      GUESS_GAME
    fi
  else
    echo -e "\nThat is not an integer, guess again:\n"
    COUNT=$(( $COUNT + 1 ))
    GUESS_GAME
  fi
}

GUESS_GAME

if (( $GAMES_PLAYED == 0 ))
then
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))
  UPDATE_DATA=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$COUNT WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

  if (( $COUNT < $BEST_GAME ))
  then
    UPDATE_DATA=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED, best_game=$COUNT WHERE username='$USERNAME'")
  else
    UPDATE_DATA=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE username='$USERNAME'")
  fi
fi
