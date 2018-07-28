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
- Open a terminal and run the BashTool.sh script on the other side specifying the empty file of the screen.
- If you have not specified anything the script will ask for a file to work with, give it the empty file you opened in gedit. It will also ask you(at first start only) if you want to create an alias for BashTool or not.
- Type "templates" and hit enter, to see the template options. Pick one, type the name and hit enter.
- Click on the gedit window... It should detect that the file has been changed, and ask if you want to reload it. Click reload...
- Typing "help" in the terminal and hitting enter will give you another list of options, and the rest is pretty self explanatory. Just type the commands, line number(s) and indent separated by spaces... then hit enter, and repeat it till your script is working... :D

Some things to note:
- The script may not be able to do anything else but add templates with single line files... The edited file needs to have at least 2 files to function properly...
- You must save the file before typing in the terminal, so that you don't loose the changes when you reload the file!
- You can't edit this script by itself, I've tried... It will mess up itself by removing some lines describing conditions for removing marker comments...
- You can hide and unhide lines, if you want to test the script there's an ofile command, which will ask for another file... give it just another empty file. After that if you run unhide without specifying a marker it will not unhide the main one, nor delete it's parts, instead it will compile the script into the second file you specified... You can run that for testing, that way you don't always have to hide lines again and again... (Keep in mind that it will only remember the files untill exitting.)
- You must unhide hidden lines before running your script. That's because it actually replaces the lines with the marker saving them in the "Hidden" directory within the BashTool folder...
- You can work on multiple projects, it will store all parts in the hidden folder within it's own directory, however the parts are uniquely numbered, and the markers are in your scripts where the parts came from thus it will always assemble them correctly. Theoretically it should be able to handle up to 99999 hidden parts...
- Never delete the long comments containing marker numbers... I's a random number not necessarily in order, if you delete one, you may find yourself analising the entire stack of hidden parts to find the one you need. That's not fun...
- You can have multiple levels of hiding(I mean hiding markers of hidden parts.), there is no limit to that. The unhide command with no markers specified is recursive so it will theoretically unhide everything in the correct order, however it may take longger, as it has to go trough the file several times line by line till there are no parts left hidden.
