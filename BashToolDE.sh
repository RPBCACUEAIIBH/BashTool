#! /bin/bash

# Finding roots
PWDir="$(pwd)"
cd $(cd "$(dirname "$0")"; pwd -P)
OwnDir="$(pwd)"
cd "$PWDir"

# Variables
FirstStart=false # Keep this in line 10
Version="1.0"
File="$@"
Answer=""
Done=false
RandomNumber=""
Mark=true
OFile=""
KeepFlag=false

# Functions
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

function CountDM
{
  for i in $(grep "# Debug" "$File" | awk '{ print $1 }')
  do
    DebugNum=$(( $DebugNum + 1 ))
  done
  X=true
  for i in $(grep "line(s) hiddebn by BashToolDE! Marker:" "$File" | awk '{ print $8 }' )
  do
    for n in $(grep "# Debug" "$OwnDir/Hidden/Hidden$i" | awk '{ print $1 }')
    do
      DebugNum=$(( $DebugNum + 1 ))
    done
    if [[ ! -z $(grep "line(s) hiddebn by BashToolDE! Marker:" "$OwnDir/Hidden/Hidden$i") && $X == true ]]
    then
      echo "Warning: BashToolDE detected more then 1 level of hidden lines. Debug messages are only counted 1 level deep. Keep in mind that you may have debug message with this numer in more then 1 location in your code!"
      X=false
    fi
  done
  DebugNum=$(( $DebugNum + 1 ))
}

function MarkLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      LineContent=$(sed "${LN}q;d" "$File")
      echo -n "$LineContent" >> "${File}Temp"
      echo " # DMark" >> "${File}Temp"
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

function UnmarkLines
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ $LN -ge $FromLine && $LN -le $ToLine ]]
    then
      LineContent=$(sed "${LN}q;d" "$File")
      NewContent=""
      for i in $(seq 0 100000)
      do
        if [[ "${LineContent:$i:8}" != " # Debug" && "${LineContent:$i:8}" != " # DMark" ]]
        then
          NewContent="$NewContent${LineContent:$i:1}"
        else
          break
        fi
      done
      echo "$NewContent" >> "${File}Temp"
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

function Cleanup
{
  LineCount
  touch "${File}Temp"
  LN=1
  while [[ $LN -le $LC ]]
  do
    if [[ -z $(sed "${LN}q;d" "$File" | grep "# Debug") && -z $(sed "${LN}q;d" "$File" | grep "# DMark") ]]
    then
      sed "${LN}q;d" "$File" >> "${File}Temp"
    fi
    LN=$(( $LN + 1 ))
  done
  cp -f "${File}Temp" "$File"
  rm "${File}Temp"
  FromLine=""
  ToLine=""
}

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
      if [[ ! -z $(sed "${LN}q;d" "$File" | grep "line(s) hiddebn by BashTool! Marker:") ]]
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
if [[ $FirstStart == true && -z $(grep "bashtoolde" ~/.bashrc) ]]
then
  read -p 'Wold you like BashToolDE to set an alias for itself? (y/n): ' Yy
  if [[ $Yy == [Yy]* ]]
  then
    echo "" >> ~/.bashrc
    echo "# BashToolDE entry" >> ~/.bashrc
    echo "alias bashtoolde=\"$OwnDir/BashToolDE.sh\"" >> ~/.bashrc
    echo 'You can now run BashToolDE by typing "bashtoolde". (You may need to re-open the terminal.)'
    sed -i "10s/FirstStart=true/FirstStart=false/" "$OwnDir/BashToolDE.sh"
  else
    sed -i "10s/FirstStart=true/FirstStart=false/" "$OwnDir/BashToolDE.sh"
  fi
fi
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
          "debug" ) LineCount
                    AtLine=$(echo $Answer | awk '{ print $2 }')
                    if [[ $AtLine -gt 0 && $AtLine -le $LC ]]
                    then
                      if [[ ! -z $(echo $Answer | awk '{ print $3 }') && $(echo $Answer | awk '{ print $3 }') -gt 0 ]]
                      then
                        Indent=$(echo $Answer | awk '{ print $3 }')
                      else
                        Indent=0
                      fi
                      DebugNum=0
                      CountDM
                      Disassemble
                      DoIndent
                      echo "echo \"Debug $DebugNum: \" # Debug" >> "$File"
                      Reassemble
                    fi
                    ;;
           "path" ) LineCount
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
                      echo "Path=\"\${PathAndNameWExt%/*}\"" >> "$File"
                      Reassemble
                    fi
                    ;;
           "fnwe" ) LineCount
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
                      echo "NameWExt=\"\${PathAndNameWExt##*/}\"" >> "$File"
                      Reassemble
                    fi
                    ;;
             "fn" ) LineCount
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
                      echo "Name=\"\${NameWExt%.*}\"" >> "$File"
                      Reassemble
                    fi
                    ;;
            "ext" ) LineCount
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
                      echo "Ext=\"\${NameWExt##*.}\"" >> "$File"
                      Reassemble
                    fi
                    ;;
           "lvar" ) LineCount
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
                      echo -n "Var=\$(grep \"VarName\" \"\$File\" | awk " >> "$File"
                      echo -n \' >> "$File"
                      echo -n "{ print \$2 }" >> "$File"
                      echo -n \' >> "$File"
                      echo ")" >> "$File"
                      Reassemble
                    fi
                    ;;
           "svar" ) LineCount
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
                      echo "sed -i \"s/\$(grep \"VarName\" \"\$File\")/VarName\\ \$Var/\" \"\$File\"" >> "$File"
                      Reassemble
                    fi
                    ;;
         "larray" ) LineCount
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
                      echo "X=1" >> "$File"
                      DoIndent
                      echo "for i in \$(grep \"ArrayName\" \"\$File\")" >> "$File"
                      DoIndent
                      echo "do" >> "$File"
                      DoIndent
                      echo "  if [[ \$X -gt 1 ]]" >> "$File"
                      DoIndent
                      echo "  then" >> "$File"
                      DoIndent
                      echo "    Array[\$X]=\"\$i\" # Data starts from 2 in this array." >> "$File"
                      DoIndent
                      echo "    echo \"ArrayName[\$X]: \${Array[\$X]}\" # Debug" >> "$File"
                      DoIndent
                      echo "  fi" >> "$File"
                      DoIndent
                      echo "  X=\$(( \$X + 1 ))" >> "$File"
                      DoIndent
                      echo "done" >> "$File"
                      Reassemble
                    fi
                    ;;
         "sarray" ) LineCount
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
                      echo "LineContent=\"ArrayName\"" >> "$File"
                      DoIndent
                      echo "PreviousContent=\"ArrayName\"" >> "$File"
                      DoIndent
                      echo "X=1" >> "$File"
                      DoIndent
                      echo "for i in \$(grep \"ArrayName\" \"\$File\")" >> "$File"
                      DoIndent
                      echo "do" >> "$File"
                      DoIndent
                      echo "  if [[ \$X -gt 1 ]]" >> "$File"
                      DoIndent
                      echo "  then" >> "$File"
                      DoIndent
                      echo "    PreviousContent=\"\$PreviousContent\\ \$i\"" >> "$File"
                      DoIndent
                      echo "    LineContent=\"\$LineContent \${Array[\$X]}\"" >> "$File"
                      DoIndent
                      echo "  fi" >> "$File"
                      DoIndent
                      echo "  X=\$(( \$X + 1 ))" >> "$File"
                      DoIndent
                      echo "done" >> "$File"
                      DoIndent
                      echo "sed -i \"s/\$PreviousContent/\$LineContent/\" \"\$File\"" >> "$File"
                      Reassemble
                    fi
                    ;;
         "ltable" ) LineCount
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
                      echo -n "DynaVarNames=\$(cat \"\$File\" | awk " >> "$File"
                      echo -n \' >> "$File"
                      echo -n "{ print \$1 }" >> "$File"
                      echo -n \' >> "$File"
                      echo ")" >> "$File"
                      DoIndent
                      echo "for n in \$DynaVarNames" >> "$File"
                      DoIndent
                      echo "do" >> "$File"
                      DoIndent
                      echo "  X=1" >> "$File"
                      DoIndent
                      echo "  for i in \$(grep \"\$n\" \"\$File\")" >> "$File"
                      DoIndent
                      echo "  do" >> "$File"
                      DoIndent
                      echo "    if [[ \$X -gt 1 ]]" >> "$File"
                      DoIndent
                      echo "    then" >> "$File"
                      DoIndent
                      echo "      eval \$n[\$X]=\"\$i\" # Data starts from 2 in all these arrays." >> "$File"
                      DoIndent
                      echo "    fi" >> "$File"
                      DoIndent
                      echo "    X=\$(( \$X + 1 ))" >> "$File"
                      DoIndent
                      echo "  done" >> "$File"
                      DoIndent
                      echo "done" >> "$File"
                      Reassemble
                    fi
                    ;;
         "stable" ) LineCount
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
                      echo "for n in \$DynaVarNames" >> "$File"
                      DoIndent
                      echo "do" >> "$File"
                      DoIndent
                      echo "  LineContent=\"\$n\"" >> "$File"
                      DoIndent
                      echo "  PreviousContent=\"\$n\"" >> "$File"
                      DoIndent
                      echo "  X=1" >> "$File"
                      DoIndent
                      echo "  for i in \$(grep \"\$n\" \"\$File\")" >> "$File"
                      DoIndent
                      echo "  do" >> "$File"
                      DoIndent
                      echo "    if [[ \$X -gt 1 ]]" >> "$File"
                      DoIndent
                      echo "    then" >> "$File"
                      DoIndent
                      echo "      PreviousContent=\"\$PreviousContent\\ \$i\"" >> "$File"
                      DoIndent
                      echo "      cmd=\"LineContent=\\\"\$LineContent \\\${\$n[\$X]}\\\"\"" >> "$File"
                      DoIndent
                      echo "      eval \$cmd" >> "$File"
                      DoIndent
                      echo "    fi" >> "$File"
                      DoIndent
                      echo "    X=\$(( \$X + 1 ))" >> "$File"
                      DoIndent
                      echo "  done" >> "$File"
                      DoIndent
                      echo "  sed -i \"s/\$PreviousContent/\$LineContent/\" \"\$File\"" >> "$File"
                      DoIndent
                      echo "done" >> "$File"
                      Reassemble
                    fi
                    ;;
         "dtable" ) LineCount
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
                      echo "for n in \$DynaVarNames" >> "$File"
                      DoIndent
                      echo "do" >> "$File"
                      DoIndent
                      echo "  LineContent=\"\$n\"" >> "$File"
                      DoIndent
                      echo "  X=1" >> "$File"
                      DoIndent
                      echo "  for i in \$(grep \"\$n\" \"\$File\")" >> "$File"
                      DoIndent
                      echo "  do" >> "$File"
                      DoIndent
                      echo "    if [[ \$X -gt 1 ]]" >> "$File"
                      DoIndent
                      echo "    then" >> "$File"
                      DoIndent
                      echo "      cmd=\"LineContent=\\\"\$LineContent \\\${\$n[\$X]}\\\"\"" >> "$File"
                      DoIndent
                      echo "      eval \$cmd" >> "$File"
                      DoIndent
                      echo "    fi" >> "$File"
                      DoIndent
                      echo "    X=\$(( \$X + 1 ))" >> "$File"
                      DoIndent
                      echo "  done" >> "$File"
                      DoIndent
                      echo "  echo \"\$LineContent\"" >> "$File"
                      DoIndent
                      echo "done" >> "$File"
                      Reassemble
                    fi
                    ;;
        "dynavar" ) LineCount
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
                      echo "eval \$n[\$X]=\$(( \$(eval \"echo \\\"\\\${\$n[\$X]}\\\"\") + 1 ))" >> "$File"
                      Reassemble
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
           "mark" ) FromLine=$(echo $Answer | awk '{ print $2 }')
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
                        MarkLines
                      fi
                    fi
                    ;;
         "unmark" ) FromLine=$(echo $Answer | awk '{ print $2 }')
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
                        UnmarkLines
                      fi
                    fi
                    ;;
        "cleanup" ) Cleanup
                    ;;
            "MIN" ) cp -af "$OwnDir/Templates/Minimalistic.sh" "$File"
                    ;;
          "INTER" ) cp -af "$OwnDir/Templates/Interactive.sh" "$File"
                    ;;
#            "MTT" ) cp -af "$OwnDir/Templates/MultiThreaded.sh" "$File"
#                    ;;
        "version" ) echo "Version $Version"
                    ;;
             "ql" ) echo "Get path, file name, and extension:"
                    echo "-> path [line number] [indent depth (number)] - Get path from /path/filename.ext"
                    echo "-> fnwe [line number] [indent depth (number)] - Get filename.ext from /path/filename.ext"
                    echo "-> fn [line number] [indent depth (number)] - Get filename from /path/filename.ext"
                    echo "-> ext [line number] [indent depth (number)] - Get extension from /path/filename.ext"
                    echo ""
                    echo "I/Os:"
                    echo "-> lvar [line number] [indent depth (number)] - Load variable from file"
                    echo "-> svar [line number] [indent depth (number)] - Save variable to file"
                    echo "-> larray [line number] [indent depth (number)] - Load array from file"
                    echo "-> sarray [line number] [indent depth (number)] - Save array to file"
                    echo "-> ltable [line number] [indent depth (number)] - Load data table from file"
                    echo "-> stable [line number] [indent depth (number)] - Save data table to file"
                    echo "-> dtable [line number] [indent depth (number)] - Display data table"
                    echo "-> dynavar [line number] [indent depth (number)] - Dynamic variable read/write demo operation. Tricky operation in bash, but you need to understand how to read/write a dynamic variable(who's name was not pre-defined but generated or loaded from a file) to be able to work with tables... (I figured that incrementation is simple yet requires both reading and writing a value to/from the same variable...)"
                    echo ""
                    echo "Planned but not yet available:"
                    echo "Options:"
                    echo "-> --help [line number] [indent depth (number)] - Simple help option"
                    echo "-> rop [line number] [indent depth (number)] - Recursive option processing"
                    echo "Info gathering:"
                    echo "-> minfo [line number] [indent depth (number)] - Machine info... CPU cores, available memory, OS, kernel, etc."
                    echo "-> ninfo [line number] [indent depth (number)] - Network info... IP address, MAC address, online machines, etc."
                    echo "And maybe some other extras..."
                    echo ""
                    ;;
      "templates" ) echo "Available templates:"
                    echo "-> MIN - Minimalistic template... (With basic functionality only...)"
                    echo "-> INTER - Interactive template (Base template of this tool. It is useful for controlling another scipt by editing variables in config files, testing tools, editors, etc.)"
                    echo ""
                    echo "Planned but not yet available:"
                    echo "-> MTT - Multi threaded template (Capable of detecting preparing, starting and controlling multiple simultaneous tasks to use all CPU cores. Additionally it also checks for root user and sets higher priority if runs as root to maximize efficiency...)"
                    echo ""
                    ;;
           "help" ) echo "Insertables:"
                    echo "-> if [line number] [indent depth (number)] - Inserts an if statement."
                    echo "-> ife [line number] [indent depth (number)] - Inserts an if-else statement."
                    echo "-> for [line number] [indent depth (number)] - Inserts a for loop."
                    echo "-> while [line number] [indent depth (number)] - Inserts a while loop."
                    echo "-> case [line number] [indent depth (number)] - Inserts a case statement."
                    echo "-> nc [line number] [indent depth (number)] - Inserts a new entry for case statement."
                    echo "-> function [line number] - Inserts an empty function."
                    echo "-> debug [line number] - An echo statement with auto-numbered debug message, marked for removal by cleanup"
                    echo ""
                    echo "Editing functionalities:"
                    echo "-> hide [from line number] [to line number] - Hide lines and replace with a marker."
                    echo "-> unhide [number of marker] - Unhides lines marked by that marker only."
                    echo "-> unhide - Unhides all hidden lines. (Run this before trying to run your script!)"
                    echo "-> comment [from line number] [to line number] - Comment lines"
                    echo "-> uncomment [from line number] [to line number] - Uncomment lines"
                    echo "-> indent [from line number] [to line number] [indent depth (number)] - Indents lines"
                    echo "-> unindent [from line number] [to line number] [indent depth (number)] - Reduces indentation of lines"
                    echo "-> mark [from line number] [to line number] - Mark lines for cleanup"
                    echo "-> unmark [from line number] [to line number] - Unmark marked/debug lines"
                    echo "-> cleanup - Removes debug messages and marked lines (Only what you can see... This way you can hide a message you don't yet want removed.)"
                    echo ""
                    echo "Generic functionalities:"
                    echo "-> file - Edit another file"
                    echo "-> ofile - Optional output file (If an output file is specified running the unhide command without a marker specified will compile the script into the output file, and leave the original and it's parts intact.)"
                    echo "-> version - Shows current version."
                    echo "-> help - Shows these options."
                    echo "-> exit - Ends the loop..."
                    echo ""
                    echo "Lists of other functionalities:"
                    echo "-> ql - Quick list of useful command structures available for insertion."
                    echo "-> templates - Lists the available templates. (This can be useful when starting new script.)"
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
echo "Bye! :)"
