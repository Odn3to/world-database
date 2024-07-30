#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

CSV_FILE="games.csv"

# Loop para ler o arquivo CSV linha por linha
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  # Verificar e inserir winner
  RESULT=$($PSQL "SELECT name FROM teams WHERE name='$winner';")
  if [[ -z $RESULT ]]; then
    $PSQL "INSERT INTO teams (name) VALUES ('$winner');"
  fi

  # Verificar e inserir opponent
  RESULT=$($PSQL "SELECT name FROM teams WHERE name='$opponent';")
  if [[ -z $RESULT ]]; then
    $PSQL "INSERT INTO teams (name) VALUES ('$opponent');"
  fi

done < <(tail -n +2 "$CSV_FILE")  # tail -n +2 pula o cabeçalho do CSV

# Loop para inserir dados na tabela games
while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")
  
  $PSQL "INSERT INTO games (year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES ($year, '$round', $winner_goals, $opponent_goals, $winner_id, $opponent_id);"

done < <(tail -n +2 "$CSV_FILE")  # tail -n +2 pula o cabeçalho do CSV

# Consulta para selecionar todos os registros da tabela games
RESULT=$($PSQL "SELECT * FROM games;")

# Imprime o resultado
echo "$RESULT"
