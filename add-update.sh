#!/bin/bash
#
###########################################################
# Author: Serg Kolo
# Date: Nov 26,2015
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
# Functions
###########################################################
SOURCESFILE="/etc/apt/sources.list"
# check if sudo
function checkUID 
{
  if [ "$(id -u)" -ne 0  ]; then  
      echo "E: must run as root" ; exit 1 
  fi
}

# each line in sources.list is in deb URI suite component1 component2 component3 format
# theres 4 of them, so we check for which ones are enabled
function listEnabledComponents
{

for component in "main" "restricted" "universe" "multiverse";do
  egrep -q  "^deb.*$component" $SOURCESFILE
  [  $? -eq 0   ] &&  printf "%s\t" "$component" 
done

}

# listing suites, for intance trusty,trusty-security, trusty-backports
function listSuites
{
  awk '/^deb.*/ {print $3}' $SOURCESFILE | sort -u | awk '{ printf $0" "}'
}

# List the URI of sources with their respective protocols
function listURI
{
  awk '/^deb.*/ && $0!~/partner/ && $0!~/extra/  {print $2}' $SOURCESFILE | sort -u     
}

# check if sources are enabled
function checkSrc
{
   grep -q 'deb-src' $SOURCESFILE 
   [ $? -eq 0  ] && echo 1 || echo 0
}



###########################################################
#  MAIN
###########################################################

# is script running with sudo ?
checkUID
# Check if file is empty
# [ -s FILE ] wont work because it checks in bytes. This solution check in bits
# -c flag of wc is bit count
[  "$( wc -c < $SOURCESFILE )" -eq 1 ] && echo "<<< $SOURCESFILE is empty; exiting" && exit 1

# Variables bellow are the lists of each portion of the format string
# deb URI suite component1 component2
# It's necessary to keep them separated so that we can use nested for loops
# for generating new values, and it's easier to process

# echo messages are for debugging, uncomment as necessary
# echo "<<< Checking enabled components:"
enabledComponents="$(listEnabledComponents)"
# echo $enabledComponents

# echo "<<< Checking enabled suites:"
suitesArray=( $(listSuites) )
#echo "${suitesArray[@]}"

#echo "<<< Checking URI:"
uriArray=( $(listURI) )
#echo "${uriArray[@]}"

# check args from the end
# Do nothing if $2 are correct
# If $2 is blank, check what we have for $1
# Any other thing means error
case "$2" in

 "updates");&
 "proposed");&
 "security");&
 "backports");;
 

  "") if [ "$1" != "default" ] && [ "$1" != "list-enabled" ] && [ "$1" != "help"  ] ; then
         echo "<<< Error: ARG2 incorrect; exiting" && exit 1 
     fi
     ;;
  *) echo "<<< Error: ARG2 incorrect; exiting" && exit 1
esac

# this is the core of the script
# some parts are reused from the original script
# Main idea is to avoid enabling/disabling if it's already done; if not 
# already done, proceed. If user wants to disable, that's simple line
# matching and deletion with sed
# If user wants to enable , generate lines for each URI, and for each URI
# consider suite/source.
#  
case "$1" in
 
  "help" ) echo "add-update.sh:"
           echo "Author: Serg Kolo, Nov 26 2015"
           echo "Usage:  sudo add-update.sh ARG1 [ARG2]"
           echo  ""
           echo "Possible ARG1:"
           echo "list-enabled - list enabled sources"
           echo "help - show this message"
           echo "enable|disable - enables or disables sources specified in ARG2(required)"
           echo "default - enable the default repository, used only when one isn't enabled "
           echo ""
           echo "Possible ARG2:"
           echo "[updates|proposed|security|backports] - one of the Ubuntu sources"
           exit 0
          ;; 
  "list-enabled" ) echo "<<< Enabled suites:"
                  echo "${suitesArray[@]}" 
                  echo "<<< Enabled URIs:"
                  echo "${uriArray[@]}"
                  exit 0
            ;;

  "enable" ) echo "<<< User requested to $1 $2";
	     echo "${suitesArray[@]}" | grep -q "$2" # check if $2 is alredy enabled
	     [   $? -eq 0 ] && echo "<<< $2 is already enabled; exiting" && exit 1
 	     echo "<<< Proceeding to generate new sources.list with $2 enabled"
	     # find out which releases are stored in the sources.list
	     # based on the "default entry", for example deb URI trusty main
	     #      
	     releasesArray=($(echo "${suitesArray[@]}" |  awk '{for(i=1;i<=NF;i++) if($i!~/\-/) print $i}'))
             if [ "${#releasesArray[@]}" -eq 0 ]; then 
                      echo "<<< E:Default entry is not enabled.Re-run with 'default' as ARG1" 
	              exit 1
             fi

	     appendSuites=($(echo "${releasesArray[@]}" | awk -v append="$2"  '{for(i=1;i<=NF;i++) printf $i"-"append" "  }'))
	     HEADER="## THIS PART IS GENERATED BY sourcesScript.sh"
 	     grep -q "$HEADER" $SOURCESFILE
	      if [ "$?" -ne 0 ]; then 
                  echo "" >> $SOURCESFILE
                  echo "$HEADER" >> $SOURCESFILE
              fi
	     SOURCES=$(checkSrc)
	     for URI in "${uriArray[@]}";do		
		for suite in "${appendSuites[@]}";do
		   echo deb "$URI" "$suite" "$enabledComponents"  >> $SOURCESFILE
                   [ "$SOURCES" -eq 1 ] &&  echo deb-src "$URI" "$suite" "$enabledComponents"  >> $SOURCESFILE
                          
		done
             done
	     ;;

  "disable" ) echo "<<< User requested to $1 $2"
	      echo "${suitesArray[@]}" | grep -q "$2" # check if $2 is already disabled
              [  $? -ne 0 ] && echo "<<< $2 is already disabled; exiting" && exit 1
	      echo "<<< Proceeding to generate new sources.list with $2 disabled" 
	      sed  -i  "s/^deb.*$2.*$/## REMOVED WITH add-update.sh/g" $SOURCESFILE  > /dev/null
	      echo "$2 edited, exiting now"
	      exit 0 


	     ;;


   "default")  echo "Default selected"
	    defaultSuites=( $(echo  "${suitesArray[@]}" | tr ' ' "\n" | awk -F '-' '{print $1}' | sort -u | tr "\n" ' ') )
            HEADER="## THIS PART IS GENERATED BY sourcesScript.sh"
             grep -q "$HEADER" "$SOURCESFILE"
              if [ "$?" -ne 0 ]; then 
                  echo "" >> $SOURCESFILE
                  echo "$HEADER" >> $SOURCESFILE
              fi
	    SOURCES="$(checkSrc)"
	    for suite in "${defaultSuites[@]}";do
               for URI in "${uriArray[@]}";do
                  echo "deb" "$URI" "$suite" "$enabledComponents" | tee -a $SOURCESFILE
                  [ "$SOURCES" -eq 1 ] &&  echo deb-src "$URI" "$suite" "$enabledComponents" | tee -a $SOURCESFILE
               done
            done            
              ;;
   *) echo "<<< Error: ARG1 is invalid. Exiting" && exit 1;
esac
