#! /bin/bash

# Variables
Answer=""
Error=false

# Functions

# Execution
while [[ $Answer != "exit" ]]
do
  if [[ $Error == true ]]
  then
    echo "Error: $Answer is an unknown command!"
    Error=false
  fi
  if [[ $Answer == "help" ]]
  then
    echo "help - Shows accepted options."
    echo "exit - Exits the interactive terminal."
    echo ""
  fi
  read -p 'Type "help" to list options. Waiting for orders: ' Answer
  Status=$(cat ./Controls | grep Status | awk '{ print $2 }')
  case $Answer
  in
              "" ) 
                   ;;
          "help" ) :
                   ;;
          "exit" ) :
                   ;;
                *) Error=true
                   ;;
  esac
  clear
done
