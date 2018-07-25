BashTool
Version 1.0

Interactive script for adding IDE functionality to gedit or any other text editor capable of recognizin changed content and asking to reload... Only for bash scripts...

Features:
- Adding if, if-else, case
- Adding for, while loops
- Adding function
- Hiding/unhiding/commenting/uncommenting/indenting lines
- Quick list of insertable useful command structures
- Bash script templates

Operation:
- Create an empty file
- Open gedit on one side of the screen
- Open a terminal and run the BashTool.sh script on the other side of the screen.
- The script will ask for a file to work with, give it the empty file you opened in gedit.
- Type "templates" and hit enter, to see the template options. Pick one, type the name and hit enter.
- Click on the gedit window... It should detect that the file has been changed, and ask if you want to reload it. Click reload...
- Typing "help" in the terminal and hitting enter will give you another list of options, and the rest is pretty self explanatory...

Some things to note:
- The script may not be able to do anything else but add templates with single line files... The edited file needs to have at least 2 files to function properly... (This may be fixed later...)
- You must unhide hidden lines before running your script. That's because it actually replaces the lines with the marker saving them in the "Hidden" directory within the BashTool folder... Typing "unhide" with no marker specified will reconstruct the file recursively till there are no markers left. That should work even with hidden markers...
- You must save the file before typing in the terminal, so that you don't loose the changes when you reload the file!
- You can't edit this script by itself, I've tried... It will mess up itself by removing some lines describing conditions for removing marker comments...
