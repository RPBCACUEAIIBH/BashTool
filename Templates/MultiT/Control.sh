#! /bin/bash

# This script can control the multi threaded script by finding and editing the current config file.
# By giving commands while the multi threaded script is not launched you can edit defaults...

# Finding roots
PWDir="$(pwd)"
cd $(cd "$(dirname "$0")"; pwd -P)
OwnDir="$(pwd)"

# Variables
Answer=""

# Functions
function AdvOption
{
  Var="$(echo "$Answer" | awk '{ print $1 }'): $(grep "$(echo "$Answer" | awk '{ print $1 }')" "$ConfigFile" | awk '{ print $2 }')"
  if [[ -z $(echo "$Answer" | awk '{ print $2 }') ]]
  then
    read -p "Value: " Value
  else
    Value=$(echo "$Answer" | awk '{ print $2 }')
  fi
  sed -i "s/$Var/$(echo "$Answer" | awk '{ print $1 }'):\ $Value/" "$ConfigFile"
}

# Execution
while [[ $Answer != "exit" ]]
do
  case $(echo "$Answer" | awk '{ print $1 }') # Messages that need to be displayed shold be here, with ":" (no operation) command in the bottom case statement...
  in
              "run" ) Var="Order: $(grep "Order" "$ConfigFile" | awk '{ print $2 }')"
                      sed -i "s/$Var/Order:\ Run/" "$ConfigFile"
                      ;;
            "pause" ) Var="Order: $(grep "Order" "$ConfigFile" | awk '{ print $2 }')"
                      sed -i "s/$Var/Order:\ Pause/" "$ConfigFile"
                      ;;
             "stop" ) Var="Order: $(grep "Order" "$ConfigFile" | awk '{ print $2 }')"
                      sed -i "s/$Var/Order:\ Stop/" "$ConfigFile"
                      exit
                      ;;
      "ThreadLimit" ) AdvOption
                      ;;
    "FeedFrequency" ) AdvOption
                      ;;
       "SleepAfter" ) AdvOption
                      ;;
         "SleepFor" ) AdvOption
                      ;;
        "BatchSize" ) AdvOption
                      ;;
            "MSize" ) AdvOption
                      ;;
                 "" ) :
                      ;;
             "help" ) echo "Basic Options:"
                      echo "-> run - Commands the script to run."
                      echo "-> pause - Commands the script to pause."
                      echo "-> exit - Exits the interactive terminal without stopping the other script."
                      echo "-> stop - Commands the script to stop and exits the interactive terminal."
                      echo "-> help - Shows this list."
                      echo ""
                      echo "Advanced Options:"
                      echo "-> ThreadLimit [value] - Load limiting...(positive integer, adjustable on the fly)(Bash doesn't do multi threading as other languages, this script creates parallel tasks, one for each detected cpu core, but those tasks are not assigned to a specific core, so system monitor or htop may say that all CPU cores are working but at a lower percentage when you limit the number of cores instead of showing 1 less core in action, but the script actually gives job only to the specified number of \"threads\", so load limiting works anyway.)"
                      echo "-> FeedFrequency [value] - This controls how often the main process checks for idling threads... This must be in balance with the batch size. The point is to spend the least time checking threads, and most time actually solving problem, but there is no problem solving without giving job to idling threads... The lower the number the more often idling threads are checked... (positive float, 0.001 rezolution, -gt 0, adjustable on the fly)"
                      echo "-> SleepAfter [value] - Amount of idle cycles before entering deep sleep. (positive integer, -gt 0, adjustable on the fly)"
                      echo "-> SleepFor [value] - How long to sleep in seconds when threads and/or main process enters deep sleep. (positive float, 0.001 rezolution, -gt 0, Should be at least 0.5, -ge Feed Frequency, adjustable on the fly)"
                      echo "-> BatchSize [value] - Controls load distribution... the smaller the batch size the better the load distribution, but the threads also finish faster, so more frequently they are idling... The higher the BatchSize the more you occasionally have to wait for 1-2 thread that didn't finish yet before you can start post processing... (positive integer, -gt 0, adjustable on the fly)"
                      echo "-> MSize [value] - Value in MiB. The minimum necessary memory for execution. Changing this value requires restarting the script. This must be at least 2 time to threadcount+1 time the size of the data you're processing depending on how your part of the script is written... (positive integer, -gt 0, requires restart)"
                      echo ""
                      ;;
                   *) echo "Error: $Answer is an unknown command!"
                      Error=false
                      ;;
  esac
  read -p 'Type "run", "pause", "exit" or "help". Waiting for orders: ' Answer
  ConfigFile=$(cat $OwnDir/Feedback)
  if [[ $ConfigFile == "Offline" ]]
  then
    ConfigFile="$OwnDir/MTConfig.conf"
  fi
  clear
done
