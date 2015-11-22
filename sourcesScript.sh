#!/bin/bash
#
###########################################################
# Author: Serg Kolo
# Date: Nov 22,2015
# Purpose: A script that enables/disables 4 ubuntu sources
# (namely updates, backports, proposed, and security )  
# much in a way like software-properties-gtk does
# Written for:  http://paste.ubuntu.com/13434218/
###########################################################
#
# Permission to use, copy, modify, and distribute this software is hereby granted 
# without fee, provided that  the copyright notice above and this permission statement
# appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.



###########################################################
#
# FUNCTIONS
# 
###########################################################


# This one checks for sudo access
function checkUID 
{
  if [ "$(id -u)" -ne 0  ]; then  
      echo "E: must run as root" ; exit 1 
  fi
}

# Check if all arguments are present and 
# correctly spelled; exit if something wrong
function checkArgs
{

  # Uncomment for debugging
  # echo "ARG1 "$1
  # echo "ARG2 "$2

   # Check number of parameters, if user has both parameters,
   # if they are misplaced,or  
   if [ "$#" -eq 0  ]; then

	echo "E: Usage: sourcesScript.sh sourceName enable/disable" && exit 1;

   elif [ "$1" = "enable" -o "$1" = "disable"  ];then

	echo "E: Missing source parameter: only action specified" && exit 1;

   # Probably redundant, first if statement checks $1 presence already
   # elif [ -z "$1"  ] ; then

	#echo "E: Missing enable/disable action" && exit 1;
   fi

   case "$1" in
         "updates") ;&
         "proposed") ;&
         "backports") ;&
         "security") echo "Source parameter OK" ;;
          *) echo "E: source parramenter incorrect" && exit 1;  
   esac

   case "$2" in
         "enable" ) ;&
         "disable" ) echo "Action parameter OK";;
         *) echo "E: action paramter incorrect" && exit 1;;
   esac

 # If something is wrong, preceeding tests would cause 
 # the the script to exit
 # If we get up to this part in the script, args are OK 
 echo "Args OK";

}




# Basic idea for checker functions: string found == item enabled
# string not found = item disabled

# This function is called before disabling an item.
# The basic idea: awk goes through file; the lines are in format 
#   deb URI source component1 component2 . . .
# As you can see, field 3 is the source. We check if any of fileds 3 in lines that
# match pattern ^deb.* have string that matches user defined source. If it doesn't,
# the RESULT is blank; that means the function is already disabled, not no need to disable.
# If we pass the if statement, that means the string is there for deletion.
function checkDisabled
{ 
 RESULT="$(awk -v source="$1" '/^deb.*/ && $3~source{ print "enabled";exit }' "$2")"
  if [ -z "$RESULT" ] ; then
	echo "W: $1 is already disabled; exiting" && exit 1
  fi
  echo "$1 not disabled, proceeding to disable it"
} 

# This function does the same as the preceeding function, but in opposite way:
# If user requested to enable a source, the function checks if it's already enabled 
function checkEnabled
{
  RESULT="$(awk -v source="$1" '$3~source{ print "enabled";exit }' "$2")"
  if [ "$RESULT" = "enabled" ] ; then
	echo "W: $1 is already enabled; exiting" && exit 1
  fi
  echo "$1 not enabled, proceeding"
}


# Some of the sources require local URI, for instance http://us.archive.ubuntu.com/ubuntu 
# Instead of basing this on user's locale, we base it on user's already existing 
# /etc/apt/sources.list, particularly on the first matched URI , which typically is
# the main Ubuntu repository
# AWK helps us to take out first item before dot, errase "deb", "http://", and any blank
# spaces from that string
function getCountry
{
  COUNTRY="$(awk -F'.' '/^deb.*/{sub(/^deb/,"");
             sub(/http\:\/\//,""); sub(/[[:blank:]]/,"");print $1;exit}' "$1" )"
 if [ "$COUNTRY" = "security" ] || [ "$COUNTRY" = "archive" ] || [ "$COUNTRY" = "extras" ];then 
     echo ""
 else 
     echo "$COUNTRY."
 fi
}

# This function simply extracts the components: main,universe,multiverse,restricted
# 
function getComponents
{
  awk '/^deb.*/{ for(i=4;i<=NF;i++) printf $i" ";exit}' "$1"
}


# This is the actual function that removes the appropriate line
# from file
function removeItem
{ 
  sed  -i  "s/^deb.*$1.*$/## REMOVED WITH sourcesScript.sh/g" "$2"  > /dev/null
  echo "$2 edited, exiting now"
  exit 0 
}



# The function appends new source
# to the sources.list
# according to the format deb URI SOURCE COMPONENTS
function appendItem
{

 # Head to append to file; 
 # presence of the header also designates whether
 # the file has been edited before with this script

 HEADER="## THIS PART IS GENERATED BY sourcesScript.sh"
 grep -q "$HEADER" "$4"

 if [ "$?" -ne 0 ]; then 
    echo "" >> "$4"
    echo "$HEADER" >> "$4"
 fi

# Append new source to sources.list


  echo "deb " "$1" " "   "$2" " " "$3" >>  "$4"

  echo "deb-src " "$1" " " "$2" " "  "$3" >>  "$4"

  echo "Sources appended, exiting" && exit 0

}

# Function for creating the URI string
function buildString
{
 case "$1" in
	"security") uri="http://security.ubuntu.com/ubuntu/";;
	*) uri="http://$(getCountry "$2" )archive.ubuntu.com/ubuntu";;
 esac
 echo "$uri"
}

###########################################################
# MAIN
###########################################################

# Define the file we're working on, /etc/apt/sources.list
# Check if the file exists. Redundant, but just to be safe
SOURCESFILE="/etc/apt/sources.list"
[ -f "$SOURCESFILE" ] || ( echo "$SOURCESFILE doesn't exist: copy /usr/share/doc/apt/examples/sources.list " && exit 1 )

# Check if user runs the script properly
checkUID
checkArgs "$@"

# Build-up variables specific to the user system
# Entries must adhere to the format
#   deb URI SOURCE COMPONENT1 COMPONENT2 COMPONENT3
# The components extracted from
RELEASE="$(lsb_release -c | awk '{print $2}' )"
SOURCE="$RELEASE"-"$1"
URI="$(buildString "$1" "$SOURCESFILE" )"
COMPONENTS="$(getComponents "$SOURCESFILE" )"

# Start checking if what user requested is enabled/disabled
#  
echo checking if "$SOURCE" is "$2"d

case "$2" in
  "enable") checkEnabled "$SOURCE" "$SOURCESFILE";
	    # inserter functin here
	    appendItem "$URI" "$SOURCE" "$COMPONENTS" "$SOURCESFILE"
		 ;;
  "disable") checkDisabled "$SOURCE" "$SOURCESFILE"; 
             removeItem "$SOURCE" "$SOURCESFILE" ;;
esac
###############################################################
#
# End of Script
#
###############################################################
