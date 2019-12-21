#! /bin/bash

### Instructions ###
# The template should run as is, but it does nothing. Comments will tell you where to insert your code.
# WDir should not exist it will be created, (if running as root ram will be mounted) and files copied there when the scipt runs, and it should normally be a location in RAM. This way it's faster to read/write files, and does not hurt solid state drive either... The point is if you're calling another script, WDir should be passed as a variable to it if it has anything to do with data in WDir.
# Threads can read the same variables/input files, but they must only write their own output files, and variables to avoid interference, and data corruption.

### Finding roots ###
PWDir="$(pwd)"
cd $(cd "$(dirname "$0")"; pwd -P)
OwnDir="$(pwd)"
cd "$PWDir"

### Variables ###
LogFile="$OwnDir/LastRun.log"
ConfigFile="$OwnDir/MTConfig.conf" # This file will be copied into WDir when it's created, and that copy will be used further on for the fastest possible operation. The location will be placed in the $OwnDir/Feedback file. Your interface can read that file, and thus find the config file.
Order=""
ThreadLimit=""
BatchSize=""

### Functions ###
function Message # $2 => "message"; $2 => E/W/I (Message Level: Error/Warning/Info); $3 => L (Optional flag: Add message to logfile)
{
  Level=""
  case $2
  in
                 [Ee]* ) Level="Error:"
                      ;;
                 [Ww]* ) Level="Warning:"
                      ;;
                   *) Level="Info:"
                      ;;
  esac
  if [[ $Output == "Silent" ]]
  then
    if [[ $3 == [Ll]* ]]
    then
      echo "$(date -Iseconds) $Level $1" >> "$LogFile"
    fi
  else
    if [[ $3 == [Ll]* ]]
    then
      echo "$(date -Iseconds) $Level $1" | tee -a "$LogFile"
    else
      echo "$(date -Iseconds) $Level $1"
    fi
  fi
}


function Listen # Listening to user input
{
  # This function is called by the Main process loads variables for the Main process only...
  if [[ ! -f $ConfigFile ]]
  then
    Message "$ConfigFile file does not exist... Aborting!" E L
    exit
  else
    Order=$(grep "Order" "$ConfigFile" | awk '{ print $2 }')
    ThreadLimit=$(grep "ThreadLimit" "$ConfigFile" | awk '{ print $2 }')
    BatchSize=$(grep "BatchSize" "$ConfigFile" | awk '{ print $2 }')
  fi
  if [[ $ThreadLimit -gt $ThreadCount ]]
  then
    ThreadNumber=$ThreadCount
    Message "Thread limit ignored! Your CPU only has $ThreadCount threads!" W L
  else
    ThreadNumber=$ThreadLimit
  fi
}

function Unload
{
  Y=""
  X=1
  while [[ $Y != "Done" ]]
  do
    if [[ -f "$WDir/T$1D$X" ]]
    then
      cat "$WDir/T$1D$X" >> "$WDir/Results"
      rm "$WDir/T$1D$X"
    else
      Y="Done"
    fi
    X=$(( $X + 1 ))
  done
}

function Feed # $1 - Number of thread
{
  for i in $(seq $BatchSize)
  do
    touch "$WDir/T$1D$i"
    # Prepare data necessary for the thread. Don't forget to mark the data to be able to post process it in the correct order... Threads may not finish in the correct order...
    # save the data to "$WDir/T$1D$i" file(a file in a RAM drive for the fastest possible processing).
    # Mark the piece "in progress".
    :
  done
  echo "State R" > "$WDir/Thread$1"
}

function Thread # $1 - Number of thread
{
  while [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') != "C" ]]
  do
    if [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') == "R" ]]
    then
      DeepSleep[$1]=0
      Y=""
      X=1
      while [[ $Y != "Done" ]]
      do
        if [[ -f "$WDir/T$1D$X" ]]
        then
          # Load data from "$WDir/T$1D$X"
          # Process it (All threads can read a variable, but they shouldn't write anything to a common variable, the output should always be separate from all threads to avoid data corruption.)
          echo -n "" > "$WDir/T$1D$X"
          # Write results back to "$WDir/T$1D$X" Don't forget to attach the post processing order mark.
        else
          Y="Done"
        fi
        X=$(( $X + 1 ))
      done
      echo "State I" > "$WDir/Thread$1"
    else
      if [[ ${DeepSleep[$1]} -lt $(grep "SleepAfter" "$ConfigFile" | awk '{ print $2 }') ]] # Deep sleep means only checking for job less often
      then
        DeepSleep[$1]=$(( ${DeepSleep[$1]} + 1 ))
        sleep $(grep "FeedFrequency" "$ConfigFile" | awk '{ print $2 }')
      else
        Message "Thread$1 is sleeping..." I L
        sleep $(grep "SleepFor" "$ConfigFile" | awk '{ print $2 }')
      fi
    fi
  done
  echo "State Offline" > "$WDir/Thread$1"
}

### Initialization ###
Output=""
while [[ ! -z $@ ]]
do
  case $1
  in
           "--help" ) echo "--silent            Only outputs to the log file."
                      echo "--help              Shows this help."
                      echo ""
                      echo ""
                      exit
                      ;;
         "--silent" ) Output="Silent"
                      ;;
                   *) echo "Error: Unknown option $1!"
                      exit
                      ;;
  esac
  shift
done

# Creating or clearing $LogFile
if [[ ! -f "$LogFile" ]]
then
  touch "$LogFile"
fi
echo -n "" > "$LogFile"
Message "Beggining log" I L
# Root check
Permission=false
Message "Running as: $(whoami)" I L
if [[ $(whoami) == "root" ]]
then
  Message "Setting higher process priority for improved efficiency!" I L
  renice -10 -p $BASHPID
  Permission=true
else
  Message "Setting higher process priority requires root permissions! This may affect efficiency!" W L
fi
# Loading variables
X=$(lscpu | grep 'CPU(s):' | awk '{ print $2 }')
ThreadCount=$(echo $X | awk '{ print $1 }')
if [[ $Permission == true ]]
then
  AMem=$(cat "/proc/meminfo" | grep "MemAvailable" | awk '{ print $2 }')
else
  AMem=$(df | grep "/run/user/$(id -u $USER)" | awk '{ print $4 }')
fi
MSize=$(( $(grep "MSize" $ConfigFile | awk '{ print $2 }') * 1024 )) # The available memory is in KiB, MSize should also be in KiB (This can't change on the fly...)
Message "Thread(s) detected: $ThreadCount" I L
Message "Available memory: $(( $AMem / 1024 )) MiB" I L
Message "Assigned memory: $(( $MSize / 1024 )) MiB" I L
Listen # Initialization of values from config file...
Message "Initial Order: $Order" I L
Message "Thread limit: $ThreadLimit" I L
Message "Feed frequency: $(grep "FeedFrequency" "$ConfigFile" | awk '{ print $2 }')" I L
Message "Batch size: $BatchSize" I L
Message "Sleeping after: $(grep "SleepAfter" "$ConfigFile" | awk '{ print $2 }')" I L
Message "Sleeping for: $(grep "SleepFor" "$ConfigFile" | awk '{ print $2 }')" I L
# WDir
if [[ $Permission == true ]]
then
  if [[ ! -z $SUDO_USER && $SUDO_USER != "root" ]]
  then
    WDir="/run/user/$(id -u $SUDO_USER)/WDir$RANDOM"
  else
    if [[ ! -d "/run/user/$(id -u $USER)" ]]
    then
      mkdir /run/user/$(id -u $USER)
    fi
    WDir="/run/user/$(id -u $USER)/WDir$RANDOM"
  fi
else
  WDir="/run/user/$(id -u $USER)/WDir$RANDOM"
fi
if [[ -d "$WDir" ]]
then
  if [[ ! -z $(df | grep $WDir) ]]
  then
    umount $WDir
  fi
  rm -Rf "$Wdir"
fi
Message "Preparing WDir! ($WDir)" I L
mkdir "$WDir"
if [[ ! -d "$WDir" ]]
then
  Message "Work direcotry couldn not be created at $WDir Aborting!" E L
  exit
else
  if [[ $Permission == true ]]
  then
    if [[ $AMem -gt $MSize ]]
    then
      Message "Mounting $(( $MSize / 1024 )) MiB RAM to $WDir" I L
      mount -t tmpfs -o rw,noatime,nodiratime,size=$(( $MSize * 1024 )) tmpfs "$WDir"
    else
      # You may want aborting execution by default without asking in case there is not enough memory...
      Message "Not enough available memory! Should the script try running with available memory?" W L
      read -t 15 -p "There is only $(( $AMem / 1024 )) MiB available memory. The config file specifies: $(( $MSize / 1024 )) MiB. Should the script try running with the available memory? (Running out of memory can cause malfunction, crash or slow operation in case you have swap space. y/n)" Yy
      Message "Response: $Yy" I L
      if [[ $Yy != [Yy]* ]]
      then
        Message "Aborting..." I L
        rm -Rf $WDir
        exit
      else
        MSize=$(cat "/proc/meminfo" | grep "MemAvailable" | awk '{ print $2 }')
        Message "Mounting $(( $MSize / 1024 )) MiB RAM to $WDir" I L
        mount -t tmpfs -o rw,noatime,nodiratime,size=$(( $MSize * 1024 )) tmpfs "$WDir"
      fi
    fi
  else
    AMem=$(df | grep "/run/user/$(id -u $USER)" | awk '{ print $4 }')
    if [[ $AMem -lt $MSize ]]
    then
      Message "Insufficient memory at /run! Try running as root, that may solve the problem! Aborting... (Usually only 10% memory is mounted to /run directory by the system, which is accessible to the user. The script can mount a different amount to it's work dir, but only if runs as root.)" E L
      rm -Rf $WDir
      exit
    fi
  fi
  cp -a "$ConfigFile" "$WDir/MTConfig.conf"
  ConfigFile="$WDir/MTConfig.conf"
  echo "$ConfigFile" > "$OwnDir/Feedback"
  cp "$LogFile" "$WDir/LastRun.log"
  LogFile="$WDir/LastRun.log"
fi
# Preparing threads
for Thread in $(seq $ThreadCount) # Maximum number of threads must be created even if the limit is lower for the flexibility of activating/deactivating them later
do
  Message "Creating Thread $Thread!" I L
  touch "$WDir/Thread$Thread"
  echo "State: I" >> "$WDir/Thread$Thread"
  DeepSleep[$Thread]=0
  Thread $Thread& # These threads should not be closed, they sleep until they are fed data and their status is set to R. They will exit with the main process.
done
### Execution ###
T1=$(date -Ins)
Message "Done preparing at: $T1" I L
# Here's the place for initial operations.

if [[ ! -f "$WDir/Results" ]]
then
  touch "$WDir/Results"
else
  echo -n "" > "$WDir/Results" # clearing results... you may not want to do that if the operation you're doing is very long, and may be done in more then 1 session...
fi
while [[ $Order != "Stop" ]]
do
  if [[ $Order == "Run" && ${DeepSleep[0]} -ge $(grep "SleepAfter" "$ConfigFile" | awk '{ print $2 }') ]]
  then
    Message "Main process active!" I L
  fi
  for Thread in $(seq $ThreadNumber)
  do
    if [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') == "I" && $Order == "Run" ]]
    then
      Unload $Thread
      Feed $Thread
      if [[ ${DeepSleep[$Thread]} -ge $(grep "SleepAfter" "$ConfigFile" | awk '{ print $2 }') ]] # If it has been paused it must wake the threads
      then
        DeepSleep[$Thread]=0
        Message "Waking Thread$Thread..." I L
      fi
    fi
  done
  if [[ $Order == "Run" ]] # Main process should not go into deep sleep if $Order == "Run"
  then
    DeepSleep[0]=0
  fi
  # You can post process on the fly here, however it may delay threads(unless 1 thread is reserved for post processign on the fly by limiting the threads to ThreadLimit - 1 in the Listen function), and also may not be in the correct order... You may wanna make this step a function, cause you will need to execute this step below, after stopping all threads otherwise data from the last running threads may be lost if Order is set to "Stop". I'd still recommend the entire post processing after all threads ware stopped.
  if [[ ${DeepSleep[0]} -lt $(grep "SleepAfter" "$ConfigFile" | awk '{ print $2 }') ]]
  then
    DeepSleep[0]=$(( ${DeepSleep[0]} + 1 ))
    sleep $(grep "FeedFrequency" "$ConfigFile" | awk '{ print $2 }')
  else
    Message "Main process is sleeping..." I L
    sleep $(grep "SleepFor" "$ConfigFile" | awk '{ print $2 }')
  fi
  Listen
done
# Waiting for all threads to finish
Wait=true
Message "Waiting for threads to finish their job." I L
while [[ $Wait == true ]]
do
  Wait=false
  sleep 1
  for Thread in $(seq $ThreadCount)
  do
    if [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') == "R" ]]
    then
      Wait=true
    else
      if [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') == "I" ]]
      then
        Unload $Thread
        echo "State C" > "$WDir/Thread$Thread"
        Wait=true
      else
        if [[ $(grep "State" "$WDir/Thread$Thread" | awk '{ print $2 }') != "Offline" ]]
        then
          Message "Waiting for Thread$Thread to stop!" I L
          Wait=true
        else
          Message "Thread$Thread is offline!" I L
        fi
      fi
    fi
  done
done
# Here's the place for post processing "$WDir/Results". Beware that it may not be in correct order. You must have marked each piece of data from each thread to be able to put the data in the correct order...

### Finishing ###
T2=$(date -Ins)
Message "Main process exiting!" I L
# Here you can calculate runtime, summary of what's done, maybe percentage if the operation was not entirely finished, etc.
cp "$LogFile" "$OwnDir/LastRun.log"
echo "Offline" > "$OwnDir/Feedback"
if [[ ! -z $(df | grep $WDir) ]]
then
  umount $WDir
fi
rm -Rf $WDir
