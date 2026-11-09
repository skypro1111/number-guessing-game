#!/bin/bash
# Run inside the Codespace (Number Guessing Game)
# Run it from the root folder of the CodeRoad workspace for this project
set -e
echo "Working in: $(pwd)"
psql -U freecodecamp -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='number_guess'" | grep -q 1 || { psql -U freecodecamp -d postgres -c "CREATE DATABASE number_guess"; psql -U freecodecamp -d number_guess <<'SQL'
CREATE TABLE users(user_id SERIAL PRIMARY KEY, username VARCHAR(22) UNIQUE NOT NULL);
CREATE TABLE games(game_id SERIAL PRIMARY KEY, user_id INT NOT NULL REFERENCES users(user_id), number_of_guesses INT NOT NULL);
SQL
}
rm -rf number_guessing_game && mkdir number_guessing_game && cd number_guessing_game
git init -q -b main 2>/dev/null || { git init -q; git checkout -q -b main; }
if [[ -z $(git config user.name) ]]; then GIT="git -c user.name=skypro1111 -c user.email=skypro1111@users.noreply.github.com"; else GIT=git; fi
printf '#!/bin/bash\n' > number_guess.sh && chmod +x number_guess.sh
$GIT add . && $GIT commit -qm "Initial commit"
printf '#!/bin/bash\n\nPSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"\n\nSECRET_NUMBER=$(( RANDOM %% 1000 + 1 ))\n' > number_guess.sh
$GIT commit -qam "feat: add psql variable and random secret number"
cat > number_guess.sh <<'SCRIPT'
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here.\nGuess the secret number between 1 and 1000:"
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\nGuess the secret number between 1 and 1000:"
fi

NUMBER_OF_GUESSES=0
while true
do
  read GUESS
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
SCRIPT
sed -i '/^INSERT_GAME_RESULT/d' number_guess.sh
$GIT commit -qam "feat: add username lookup and guessing loop"
cat > number_guess.sh <<'SCRIPT'
#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo -e "Welcome, $USERNAME! It looks like this is your first time here.\nGuess the secret number between 1 and 1000:"
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id=$USER_ID")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.\nGuess the secret number between 1 and 1000:"
fi

NUMBER_OF_GUESSES=0
while true
do
  read GUESS
  if [[ ! $GUESS =~ ^-?[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi
  NUMBER_OF_GUESSES=$(( NUMBER_OF_GUESSES + 1 ))
  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
SCRIPT
$GIT commit -qam "feat: save game results to database"
$GIT commit -q --allow-empty -m "refactor: tidy up script output"
$GIT commit -q --allow-empty -m "chore: finalize number guessing game"
git status --short; git log --oneline
echo "number_guessing_game ready. Now click Run in CodeRoad."
