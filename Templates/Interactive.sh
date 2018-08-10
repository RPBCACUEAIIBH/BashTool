#! /bin/bash

# Finding roots
PWDir="$(pwd)" # Saving current path (from where the script was called... usually "/home/$USER" if you just opened a new terminal and calling the script.)
cd $(cd "$(dirname "$0")"; pwd -P) # Entering the directory where this script is, so you can simply use just the "filename" or "./filename" to refer to a file within the script's directory...
OwnDir="$(pwd)" # Saving path to own directory path.
#cd "$PWDir" # Uncomment this if you prefer going back to the directory where the script was called from. Uncommenting this is usually good practice... (In this case you need to use "$OwnDir/filename" in the script to refer to a file in it's own directory. You may wanna use "$OwnDir/filename" from the beginning instead of "./filename" cause if you need to pass filenames as parameters when you're calling the script even as an afterthought, you will need to uncomment this, and change all the "./filenames" and "filename" references to "$OwnDir/filename" anyway, or specify full path as a parameter even if the file is in the directory you're calling the script from...)
# Another good practice is usin "$OwnDir/filename" instead of $OwnDir/filename everywhere to specify a file, cause using quotation marks everywhere kinda gets rid of the space in file name or path problems... Like so: echo "string" >> "$/home/user/Directory with space in the name/file name" # <-- Mind the space in the file name and path! (...kinda hard to get used to using "" once you got used to not using them. :/ ...from experience. Wildcards in names and path will still be a problem even with "", however less likely to encounter wildcard then spaces.)

# Variables
Answer=""

# Functions

# Execution
while [[ $Answer != "exit" ]]
do
  case $Answer # Messages that need to be displayed shold be here, with ":" (no operation) command in the bottom case statement...
  in
                 "" ) :
                      ;;
             "help" ) echo "help - Shows accepted options."
                      echo "exit - Exits the interactive terminal."
                      echo ""
                      ;;
                   *) echo "Error: $Answer is an unknown command!"
                      Error=false
                      ;;
  esac
  read -p 'Type "help" to list options. Waiting for orders: ' Answer
  clear
done
