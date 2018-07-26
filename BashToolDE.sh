#! /bin/bash

# Finding roots
PWDir="$(pwd)"
cd $(cd "$(dirname "$0")"; pwd -P)
OwnDir="$(pwd)"
cd "$PWDir"

# Variables
File="$@"
Version="1.0"
Answer=""
Done=false
RandomNumber=""
Mark=true
OFile=""
KeepFlag=false

# Functions
function UnindentLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      X=0
      LineContent=$(sed "${LN}q;d" "$File")
      while [[ $X -lt $(( $Indent * 2 )) ]]
      do
        LineContent="${LineContent:1:10000}"
        X=$(( $X + 1 ))
      done
      echo "$LineContent" >> "${File}Temp"
    else
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

function IndentLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      X=0
      while [[ $X -lt $Indent ]]
      do
        echo -n "  " >> "${File}Temp"
        X=$(( $X + 1 ))
      done
      sed "${LN}q;d" "$File" >> "${File}Temp"
    else
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

function CommentLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      echo -n "#" >> "${File}Temp"
      sed "${LN}q;d" "$File" >> "${File}Temp"
    else
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

function UncommentLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      LineContent=$(sed "${LN}q;d" "$File")
      if [[ ${LineContent:0:1} == "#" ]]
      then
        echo "${LineContent:1:100000}" >> "${File}Temp"
      else
        echo "$LineContent" >> "${File}Temp"
      fi
    else
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

function LineCount
{
  LC=0
  while read -r p
  do
    LC=$(( $LC + 1 ))
  done < "$File"
}

function Disassemble
{
  if [[ $(echo $(sed "${AtLine}q;d" "$File" | grep ":")) == ":" ]] # Just a nice touch... if the entire $AtLine line only contains a single ":" it will be removed, as it's only a no op command used to avoid errors...
  then
    LineCount
    touch "${File}Temp"
    LN=1
    while [[ $LN -le $LC ]]
    do
      if [[ $LN -ne $AtLine ]]
      then
        sed "${LN}q;d" "$File" >> "${File}Temp"
      fi
      LN=$(( $LN + 1 ))
    done
    cp -f "${File}Temp" "$File"
    rm "${File}Temp"
  fi
  FromLine=$AtLine
  LineCount
  ToLine=$LC
  Mark=false
  HideLines
}

function Reassemble
{
  echo "# X line(s) hiddebn by BashToolDE! Marker: $RandomNumber" >> "$File"
  Marker=$RandomNumber
  UnhideLines
  Mark=true
}

function DoIndent
{
  X=0
  while [[ $X -lt $Indent ]]
  do
    echo -n "  " >> "$File"
    X=$(( $X + 1 ))
  done
}

function HideLines
{
  RandomSelection=true
  while [[ $RandomSelection == true ]]
  do
    RandomNumber=$RANDOM
    if [[ ! -e "$OwnDir/Hidden/Hidden$RandomNumber" ]]
    then
      RandomSelection=false
    fi
  done
  touch "$OwnDir/Hidden/Hidden$RandomNumber"
  LN=$FromLine
  while [[ $LN -le $ToLine ]]
  do
    sed "${LN}q;d" "$File" >> "$OwnDir/Hidden/Hidden$RandomNumber"
    LN=$(( $LN + 1 ))
  done
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      if [[ $LN -eq $FromLine && $Mark == true ]]
      then
        echo "# $(( $ToLine - $FromLine + 1 )) line(s) hiddebn by BashToolDE! Marker: $RandomNumber Your notes: (eg. specify what is hidden)" >> "${File}Temp"
      fi
    else
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

function UnhideLines
{
  if [[ $Marker == "all" ]]
  then
    while [[ ! -z $(grep "line(s) hiddebn by BashToolDE! Marker:" "$File") ]]
    do
      LineCount
      LN=1
      touch "${File}Temp"
      while [[ $LN -le $LC ]]
      do
        if [[ ! -z $(sed "${LN}q;d" "$File" | grep "line(s) hiddebn by BashToolDE! Marker:") ]]
        then
          ThisMarker=$(sed "${LN}q;d" "$File" | awk '{ print $8 }')
          cat "$OwnDir/Hidden/Hidden$ThisMarker" >> "${File}Temp"
          if [[ $KeepFlag == false ]]
          then
            rm "$OwnDir/Hidden/Hidden$ThisMarker"
          fi
        else
          sed "${LN}q;d" "$File" >> "${File}Temp"
        fi
        LN=$(( $LN + 1 ))
      done
      cp -f "${File}Temp" "$File"
      rm "${File}Temp"
    done
  else
    LineCount
    LN=1
    touch "${File}Temp"
    while [[ $LN -le $LC ]]
    do
      if [[ ! -z $(sed "${LN}q;d" "$File" | grep "line(s) hiddebn by BashToolDE! Marker:") ]]
      then
        ThisMarker=$(sed "${LN}q;d" "$File" | awk '{ print $8 }')
        if [[ $ThisMarker -eq $Marker ]]
        then
          cat "$OwnDir/Hidden/Hidden$ThisMarker" >> "${File}Temp"
          rm "$OwnDir/Hidden/Hidden$ThisMarker"
        else
          sed "${LN}q;d" "$File" >> "${File}Temp"
        fi
      else
        sed "${LN}q;d" "$File" >> "${File}Temp"
      fi
      LN=$(( $LN + 1 ))
    done
    cp -f "${File}Temp" "$File"
    rm "${File}Temp"
  fi
  Marker=""
}

# Execution
if [[ -f "$File" ]]
then
  Done=true
fi
while [[ $Done == false ]]
do
  read -p 'Please specify the file you want to work with: ' File
  if [[ -f "$File" ]]
  then
    Done=true
  fi
done
echo "Editing: $File"
while [[ $Answer != "exit" ]]
do
  case $(echo $Answer | awk '{ print $1 }')
  in
           "hide" ) FromLine=$(echo $Answer | awk '{ print $2 }')
                    ToLine=$(echo $Answer | awk '{ print $3 }')
                    LineCount
                    if [[ -z $FromLine || $FromLine -gt 0 && $FromLine -le $LC ]]
                    then
                      if [[ -z $ToLine || $ToLine -gt $FromLine && $ToLine -le $LC ]]
                      then
                        if [[ -z $ToLine ]]
                        then
                          ToLine=$FromLine
                        fi
                        HideLines
                      fi
                    fi
                    ;;
         "unhide" ) if [[ -z $(echo $Answer | awk '{ print $2 }') || $(echo $Answer | awk '{ print $2 }') == "all" ]]
                    then
                      Marker="all"
                      if [[ ! -z "$OFile" ]]
                      then
                        cp -af "$File" "$OFile"
                        KeepFlag=true
                        TFile="$File"
                        File="$OFile"
                        UnhideLines
                        File="$TFile"
                        KeepFlag=false
                      else
                        UnhideLines
                      fi
                    else
                      Marker=$(echo $Answer | awk '{ print $2 }')
                      if [[ $Marker -gt -1 ]]
                      then
                        UnhideLines
                      fi
                    fi
                    ;;
           "file" ) Done=false
                    while [[ $Done == false ]]
                    do
                      read -p 'Please specify the file you want to work with or type "cancel" not to change anything!: ' X
                      if [[ -f "$X" || $X == "cancel" ]]
                      then
                        if [[ $X != "cancel" ]]
                        then
                          File="$X"
                          Done=true
                          echo "Editing: $File"
                        fi
                      fi
                    done
                    ;;
          "ofile" ) Done=false
                    while [[ $Done == false ]]
                    do
                      read -p 'Please specify the file you want to work with or type "cancel" not to change anything!: ' X
                      if [[ -f "$X" || $X == "cancel" || -z $X ]]
                      then
                        if [[ $X != "cancel" ]]
                        then
                          OFile="$X"
                          Done=true
                          echo "Output File: $OFile"
                          if [[ ! -z "$OFile" ]]
                          then
                            echo "The unhide command with no argument will now use this file to re-build the file instead of the original. (You can undo this with ofile command, and no file specified...)"
                            echo ""
                          else
                            echo "The unhide command with no argument will now reconstruct the original."
                            echo ""
                          fi
                        fi
                      fi
                    done
                     ;;
             "if" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'if [[ -z $Null ]]' >> "$File"
                      DoIndent
                      echo 'then' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo 'fi' >> "$File"
                      Reassemble
                    fi
                    ;;
            "ife" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'if [[ -z $Null ]]' >> "$File"
                      DoIndent
                      echo 'then' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo 'else' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo 'fi' >> "$File"
                      Reassemble
                    fi
                    ;;
            "for" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'for $i in $This' >> "$File"
                      DoIndent
                      echo 'do' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo 'done' >> "$File"
                      Reassemble
                    fi
                    ;;
          "while" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'while [[ ! -z $Null ]]' >> "$File"
                      DoIndent
                      echo 'do' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo '# X=$(( $X + 1 ))' >> "$File"
                      DoIndent
                      echo 'done' >> "$File"
                      Reassemble
                    fi
                    ;;
           "case" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'case $X' >> "$File"
                      DoIndent
                      echo 'in' >> "$File"
                      DoIndent
                      echo '               "" ) :' >> "$File"
                      DoIndent
                      echo '                    ;;' >> "$File"
                      DoIndent
                      echo '                 *) echo "Error: Unknown option at: case $X!"' >> "$File"
                      DoIndent
                      echo '                    ;;' >> "$File"
                      DoIndent
                      echo 'esac' >> "$File"
                      Reassemble
                    fi
                    ;;
             "nc" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo '               "" ) :' >> "$File"
                      DoIndent
                      echo '                    ;;' >> "$File"
                      Reassemble
                    fi
                    ;;
       "function" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      Disassemble
                      DoIndent
                      echo 'function RENAME' >> "$File"
                      DoIndent
                      echo '{' >> "$File"
                      DoIndent
                      echo '  :' >> "$File"
                      DoIndent
                      echo '}' >> "$File"
                      DoIndent
                      echo '' >> "$File"
                      Reassemble
                    fi
                    ;;
        "comment" ) FromLine=$(echo $Answer | awk '{ print $2 }')
                    ToLine=$(echo $Answer | awk '{ print $3 }')
                    LineCount
                    if [[ $FromLine -gt 0 && $FromLine -le $LC ]]
                    then
                      if [[ -z $ToLine || $ToLine -gt $FromLine && $ToLine -le $LC ]]
                      then
                        if [[ -z $ToLine ]]
                        then
                          ToLine=$FromLine
                        fi
                        CommentLines
                      fi
                    fi
                    ;;
      "uncomment" ) FromLine=$(echo $Answer | awk '{ print $2 }')
                    ToLine=$(echo $Answer | awk '{ print $3 }')
                    LineCount
                    if [[ $FromLine -gt 0 && $FromLine -le $LC ]]
                    then
                      if [[ -z $ToLine || $ToLine -gt $FromLine && $ToLine -le $LC ]]
                      then
                        if [[ -z $ToLine ]]
                        then
                          ToLine=$FromLine
                        fi
                        UncommentLines
                      fi
                    fi
                    ;;
         "indent" ) FromLine=$(echo $Answer | awk '{ print $2 }')
                    ToLine=$(echo $Answer | awk '{ print $3 }')
                    LineCount
                    if [[ $FromLine -gt 0 && $FromLine -le $LC ]]
                    then
                      if [[ -z $ToLine || $ToLine -gt $FromLine && $ToLine -le $LC ]]
                      then
                        if [[ -z $ToLine ]]
                        then
                          ToLine=$FromLine
                        fi
                        if [[ ! -z $(echo $Answer | awk '{ print $4 }') && $(echo $Answer | awk '{ print $4 }') -gt 0 ]]
                        then
                          Indent=$(echo $Answer | awk '{ print $4 }')
                        else
                          Indent=0
                        fi
                        IndentLines
                      fi
                    fi
                    ;;
       "unindent" ) FromLine=$(echo $Answer | awk '{ print $2 }')
                    ToLine=$(echo $Answer | awk '{ print $3 }')
                    LineCount
                    if [[ $FromLine -gt 0 && $FromLine -le $LC ]]
                    then
                      if [[ -z $ToLine || $ToLine -gt $FromLine && $ToLine -le $LC ]]
                      then
                        if [[ -z $ToLine ]]
                        then
                          ToLine=$FromLine
                        fi
                        if [[ ! -z $(echo $Answer | awk '{ print $4 }') && $(echo $Answer | awk '{ print $4 }') -gt 0 ]]
                        then
                          Indent=$(echo $Answer | awk '{ print $4 }')
                        else
                          Indent=0
                        fi
                        UnindentLines
                      fi
                    fi
                    ;;
            "MIN" ) cp -af "$OwnDir/Templates/Minimalistic.sh" "$File"
                    ;;
          "INTER" ) cp -af "$OwnDir/Templates/Interactive.sh" "$File"
                    ;;
            "MTT" ) cp -af "$OwnDir/Templates/MultiThreaded.sh" "$File"
                    ;;
        "version" ) echo "Version $Version"
                    ;;
             "ql" ) echo "Sorry! ...not implemented yet."
                    echo ""
                    ;;
      "templates" ) echo "MIN - Minimalistic template... (With basic functionality only...)"
                    echo "INTER - Interactive template (Base template of this tool. It is useful for controlling another scipt by editing variables in config files, testing tools, editors, etc.)"
                    echo "MTT - Multi threaded template (Capable of detecting preparing, starting and controlling multiple simultaneous tasks to use all CPU cores. Additionally it also checks for root user and sets higher priority if runs as root to maximize efficiency...)"
                    echo ""
                    ;;
           "help" ) echo "if [line number] [indent depth (number)] - Inserts an if statement."
                    echo "ife [line number] [indent depth (number)] - Inserts an if-else statement."
                    echo "for [line number] [indent depth (number)] - Inserts a for loop."
                    echo "while [line number] [indent depth (number)] - Inserts a while loop."
                    echo "case [line number] [indent depth (number)] - Inserts a case statement."
                    echo "nc [line number] [indent depth (number)] - Inserts a new entry for case statement."
                    echo "function [line number] - Inserts an empty function."
                    echo ""
                    echo "hide [from line number] [to line number] - Hide lines and replace with a marker."
                    echo "unhide [Number of marker] - Unhides lines marked by that marker only."
                    echo "unhide - Unhides all hidden lines. (Run this before trying to run your script!)"
                    echo "comment [from line number] [to line number] - Comment lines"
                    echo "uncomment [from line number] [to line number] - Uncomment lines"
                    echo "indent [from line number] [to line number] [indent depth (number)] - Indents lines"
                    echo "unindent [from line number] [to line number] [indent depth (number)] - Reduces indentation of lines"
                    echo ""
                    echo "ql - Quick list of useful command structures available for insertion."
                    echo "templates - Lists the available templates. (This can be useful when starting new script.)"
                    echo ""
                    echo "version - Shows current version."
                    echo "help - Shows these options."
                    echo "exit - Ends the loop..."
                    echo "file - Change file"
                    echo "ofile - Optional output file (If an output file is specified running the unhide command without a marker specified will compile the script into the output file, and leave the original and it's parts intact.)"
                    echo ""
                    ;;
               "" ) : #Otherwise it gives the error below when it's null...
                    ;;
                 *) echo "Error: $Answer is an unknown command!"
                    ;;
  esac
  read -p 'Type "help" to list options. Waiting for orders: ' Answer
  clear
done
