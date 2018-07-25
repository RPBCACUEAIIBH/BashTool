#! /bin/bash
Version="1.0"
Answer=""
Error=false
Done=false
RandomNumber=""
Mark=true

function IndentLines
{
  LineCount
  touch ${File}Temp
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      X=0
      while [[ $X -lt $Indent ]]
      do
        echo -n "  " >> ${File}Temp
        X=$(( $X + 1 ))
      done
      sed "${LN}q;d" $File >> ${File}Temp
    else
      sed "${LN}q;d" $File >> ${File}Temp
    fi
    LN=$(( $LN + 1 ))
  done
  mv ${File}Temp ${File}
  FromLine=""
  ToLine=""
}

function CommentLines
{
  LineCount
  touch ${File}Temp
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      echo -n "#" >> ${File}Temp
      sed "${LN}q;d" $File >> ${File}Temp
    else
      sed "${LN}q;d" $File >> ${File}Temp
    fi
    LN=$(( $LN + 1 ))
  done
  mv ${File}Temp ${File}
  FromLine=""
  ToLine=""
}

function UncommentLines
{
  LineCount
  touch ${File}Temp
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      LineContent=$(sed "${LN}q;d" $File)
      if [[ ${LineContent:0:1} == "#" ]]
      then
        echo "${LineContent:1:100000}" >> ${File}Temp
      else
        echo "$LineContent" >> ${File}Temp
      fi
    else
      sed "${LN}q;d" $File >> ${File}Temp
    fi
    LN=$(( $LN + 1 ))
  done
  mv ${File}Temp ${File}
  FromLine=""
  ToLine=""
}

function LineCount
{
  LC=0
  while read -r p
  do
    LC=$(( $LC + 1 ))
  done < $File
}

function Disassemble
{
  if [[ $(echo $(sed "${AtLine}q;d" $File | grep ":")) == ":" ]] # Just a nice touch... if the entire $AtLine line only contains a single ":" it will be removed, as it's only a no op command used to avoid errors...
  then
    LineCount
    touch ${File}Temp
    LN=1
    while [[ $LN -le $LC ]]
    do
      if [[ $LN -ne $AtLine ]]
      then
        sed "${LN}q;d" $File >> ${File}Temp
      fi
      LN=$(( $LN + 1 ))
    done
    mv ${File}Temp ${File}
  fi
  FromLine=$AtLine
  LineCount
  ToLine=$LC
  Mark=false
  HideLines
}

function Reassemble
{
  Marker=$RandomNumber
  UnhideLines
  Mark=true
}

function DoIndent
{
  X=0
  while [[ $X -lt $Indent ]]
  do
    echo -n "  " >> $File
    X=$(( $X + 1 ))
  done
}

function HideLines
{
  RandomSelection=true
  while [[ $RandomSelection == true ]]
  do
    RandomNumber=$RANDOM
    if [[ ! -e ./Hidden/Hidden$RandomNumber ]]
    then
      RandomSelection=false
    fi
  done
  touch ./Hidden/Hidden$RandomNumber
  LN=$FromLine
  while [[ $LN -le $ToLine ]]
  do
    sed "${LN}q;d" $File >> ./Hidden/Hidden$RandomNumber
    LN=$(( $LN + 1 ))
  done
  LineCount
  touch ${File}Temp
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      if [[ $LN -eq $FromLine && $Mark == true ]]
      then
        echo "# $(( $ToLine - $FromLine + 1 )) line(s) hiddebn by BashTool! Marker: $RandomNumber" >> ${File}Temp
      fi
    else
      sed "${LN}q;d" $File >> ${File}Temp
    fi
    LN=$(( $LN + 1 ))
  done
  mv ${File}Temp ${File}
  FromLine=""
  ToLine=""
}

function UnhideLines
{
  if [[ $Marker == "all" ]]
  then
    while [[ ! -z $(grep 'line(s) hiddebn by BashTool! Marker:' $File) ]]
    do
      LineCount
      LN=1
      touch ${File}Temp
      while [[ $LN -le $LC ]]
      do
        if [[ ! -z $(sed "${LN}q;d" $File | grep 'line(s) hiddebn by BashTool! Marker:') ]]
        then
          ThisMarker=$(sed "${LN}q;d" $File | awk '{ print $8 }')
          cat "./Hidden/Hidden$ThisMarker" >> "${File}Temp"
          rm ./Hidden/Hidden$ThisMarker
        else
          sed "${LN}q;d" $File >> ${File}Temp
        fi
        LN=$(( $LN + 1 ))
      done
      mv ${File}Temp ${File}
    done
  else
    LineCount
    LN=1
    touch ${File}Temp
    while [[ $LN -le $LC ]]
    do
      if [[ ! -z $(sed "${LN}q;d" $File | grep 'line(s) hiddebn by BashTool! Marker:') ]]
      then
        ThisMarker=$(sed "${LN}q;d" $File | awk '{ print $8 }')
        if [[ $ThisMarker -eq $Marker ]]
        then
          cat ./Hidden/Hidden$ThisMarker >> ${File}Temp
          rm ./Hidden/Hidden$ThisMarker
        else
          sed "${LN}q;d" $File >> ${File}Temp
        fi
      else
        sed "${LN}q;d" $File >> ${File}Temp
      fi
      LN=$(( $LN + 1 ))
    done
    mv ${File}Temp ${File}
  fi
  Marker=""
}

# Program starts here
while [[ $Done == false ]]
do
  read -p 'Please specify the file you want to work with: ' File
  if [[ -f "$File" ]]
  then
    Done=true
    echo "$File Selected!"
  fi
done
while [[ $Answer != "exit" ]]
do
  if [[ $Error == true ]]
  then
    echo "Error: $Answer is an unknown command!"
    Error=false
  fi
  if [[ $Answer == "help" ]]
  then
    echo "if [line number] [indent depth (number)] - Inserts an if statement."
    echo "ife [line number] [indent depth (number)] - Inserts an if-else statement."
    echo "for [line number] [indent depth (number)] - Inserts a for loop."
    echo "while [line number] [indent depth (number)] - Inserts a while loop."
    echo "case [line number] [indent depth (number)] - Inserts a case statement."
    echo "function [line number] - Inserts an empty function."
    echo ""
    echo "hide [from line number] [to line number] - Hide lines and replace with a marker."
    echo "unhide [Number of marker] - Unhides lines marked by that marker only."
    echo "unhide - Unhides all hidden lines. (Run this before trying to run your script!)"
    echo "comment [from line number] [to line number] - Comment lines"
    echo "uncomment [from line number] [to line number] - Uncomment lines"
    echo "indent [from line number] [to line number] [indent depth (number)] - Indents lines"
    echo ""
    echo "ql - Quick list of useful command structures available for insertion."
    echo "templates - Lists the available templates. (This can be useful when starting new script.)"
    echo ""
    echo "version - Shows current version."
    echo "help - Shows these options."
    echo "exit - Ends the loop..."
    echo ""
  fi
  if [[ $Answer == "ql" ]]
  then
    echo "Sorry! ...not implemented yet."
    echo ""    
  fi
  if [[ $Answer == "templates" ]]
  then
    echo "BMIN - Bare minimum template..."
    echo "DIRBT - Directory backtracking template (Finds it's own directory no matter where it is called. You can simply use ./filename to point to another file from the directory where the script is.)"
    echo "INTER - Interactive template (like this one. It's useful for controlling another scipt by editing variables in config files.)"
    echo "MTT - Multi threaded template (Capable of detecting preparing, starting and controlling multiple simultaneous tasks to use all CPU cores. Additionally it also checks for root user and sets high priority if runs as root to maximize efficiency...)"
    echo "- Interactive (Like this tool... it can be useful for controling another script by changing variables in control files...)"
    echo "- MultiThreaded (An advanced template that detects cpu cores and user, launches and manages threads, and if it's running as root it also sets task priority for higher efficiency.)"
    echo ""
  fi
  read -p 'Type "help" to list options. Waiting for orders: ' Answer
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
                     UnhideLines
                   else
                     Marker=$(echo $Answer | awk '{ print $2 }')
                     if [[ $Marker -gt -1 ]]
                     then
                       UnhideLines
                     fi
                   fi
                   ;;
          "File" ) Done=false
                   while [[ $Done == false ]]
                   do
                     read -p 'Please specify the file you want to work with or type "cancel" not to change anything!: ' X
                     if [[ -f "$X" || $X == "cancel" ]]
                     then
                       if [[ $X != "cancel" ]]
                       then
                         File="$X"
                         Done=true
                         echo "$File Selected!"
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
                     echo 'if [[  ]]' >> $File
                     DoIndent
                     echo 'then' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo 'fi' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
                     echo 'if [[  ]]' >> $File
                     DoIndent
                     echo 'then' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo 'else' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo 'fi' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
                     echo 'for $i in $This' >> $File
                     DoIndent
                     echo 'do' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo 'done' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
                     echo 'while [[  ]]' >> $File
                     DoIndent
                     echo 'do' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo '# X=$(( $X + 1 ))' >> $File
                     DoIndent
                     echo 'done' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
                     echo 'case $X in' >> $File
                     DoIndent
                     echo '          "" ) :' >> $File
                     DoIndent
                     echo '               ;;' >> $File
                     DoIndent
                     echo '            *) echo "Error: Unknown option at: case $X!"' >> $File
                     DoIndent
                     echo '               ;;' >> $File
                     DoIndent
                     echo 'esac' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
                     echo 'function RENAME' >> $File
                     DoIndent
                     echo '{' >> $File
                     DoIndent
                     echo '  :' >> $File
                     DoIndent
                     echo '}' >> $File
                     echo "# X line(s) hiddebn by BashTool! Marker: $RandomNumber" >> $File
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
         "DIRBT" ) cp -f ./Templates/Backtracking.sh $File
                   ;;
           "INT" ) cp -f ./Templates/Interactive.sh $File
                   ;;
          "BMIN" ) cp -f ./Templates/BareMinimum.sh $File
                   ;;
           "MTT" ) cp -f ./Templates/MultiThreaded.sh $File
                   ;;
            "ql" ) :
                   ;;
     "templates" ) :
                   ;;
       "version" ) echo "Version $Version"; sleep 2
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
