#!/usr/bin/awk -f
#
###########################################################
# Author: Serg Kolo
# Date: Nov 27,2015
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

function printUsage() {
    print "Usage: sudo ./add-update.awk -v ACTION=[enable|disable|help] -v SOURCE=[updates|backports|security|proposed]";
    exit
}

function checkSourceEnabled()
{
    if ( $3 ~ SOURCE) {
        print SOURCE" is enabled; exiting"
        VAL = 1
    }
    else {
        VAL = 0
    }
    return VAL
}

function disableSource()
{
    if ( $0 ~ SOURCE ) $0="# removed";
    j++;
    newLines[j]=$0;
}

function listStuff () {
    for(k=4; k<=NF; k++) if ( $k~/#/  ) {break} else {
            COMPONENTS=COMPONENTS" "$k
        };
    gsub(/\-.*/,"",$3);
    STRING=$1" "$2" "$3APPEND" "COMPONENTS;
    COMPONENTS=""
               return STRING;
}

function replaceFile()
{
    command="mv  /tmp/sources.list "ARGV[1]
            system(command);
}

############
#  MAIN
#############
BEGIN {

# argument checking sequence
# must remain written in if-else
# structure rather than case,
# to consider users who may not be able
# to install gawk due to broken sources.list
# which is what this script should be aimed at

# actions checked first so that 
# help message can be printed 
 if ( ACTION ==  "enable" ||
      ACTION == "disable" ||
      ACTION == "default"  ) {

    print "<<< ACTION ARG OK" 
  }
  else if (ACTION == "help" ){
    printUsage()
    exit
  }


  if ( SOURCE == "update" || 
       SOURCE == "security" || 
       SOURCE == "backports" || 
       SOURCE == "proposed" ) { 
       print "<<< SOURCE ARG OK"
       
  }
   
   else if ( ACTION != "default"  || ACTION != "help" ) {  
        print "<<< E: SOURCE ARG INCORRECT"; 
        printUsage(); 
        exit 1   }

    # static filename to operate on
    ARGV[ARGC++]="/etc/apt/sources.list";

    if (ACTION == "enable" ) {
        APPEND="-"SOURCE;
    } else{
        APPEND="";
    }

} # END OF BEGIN

$0~/^deb*/ && $0!~/partner/ && $0!~/extra/ {

    if ( ACTION == "enable" ) {
        j++;
        ARRAY[j]=$0
        ENABLED=checkSourceEnabled();

        if ( ENABLED ) {
            exit 1
        }
        else {
            j++;
            ARRAY[j]=listStuff();
        }

    }
    else if ( ACTION == "disable" ){
        disableSource() ;
    }
    else if ( ACTION == "default" && SOURCE == "default" ) {
        j++;
        defaultsArray[j]=$0;
        j++;
        defaultsArray[j]=listStuff();
    }
}

END {
    print "<<< Script finished processing" ;
    if ( ACTION =="enable" && ENABLED == 0 ){
     for(i=1;i<=j;i++)
        print ARRAY[i] |  "sort -u > /tmp/sources.list ";
     replaceFile();
     }
     else if ( ACTION == "disable" ) {
       for ( i=1;i<=j;i++  ) print newLines[i] | "sort -u > /tmp/sources.list"
       replaceFile();
     }
     else if (ACTION == "default" ){
        for ( i=1;i<=j;i++  ) print defaultsArray[i] | "sort -i -u > /tmp/sources.list"
        replaceFile();
     }
}

# END OF MAIN
