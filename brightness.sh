#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: March 7th, 2016
# Purpose: Script that will remember screen brightness
#          Must be used in conjunction with lightdm
#          Place the following 5 lines into /etc/lightdm/lightdm.conf
#
#           [SeatDefaults]
#           #display-setup-script = Script to run when starting a greeter session (runs as root)
#           display-setup-script = /home/USER/bin/sergrep/brightness.sh restore
#           #display-stopped-script = Script to run after stopping the display server (runs as root)
#           display-stopped-script = /home/USER/bin/sergrep/brightness.sh store
#
#           Basic idea is that you must give full path and either store or restore as an option 
# Written for: http://askubuntu.com/q/739654/295286
# Tested on:  Ubuntu 14.04 LTS
# Version: 1.2 , added brightness limit, file creation
###########################################################
# Copyright: Serg Kolo , 2016
#    
#     Permission to use, copy, modify, and distribute this software is hereby granted
#     without fee, provided that  the copyright notice above and this permission statement
#     appear in all copies.
#
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
#     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#     DEALINGS IN THE SOFTWARE.
ARGV0=$0
ARGC=$#



store()
{
   cat "$SYSDIR"/*/actual_brightness > "$1"
}
#----------

# This function restores brightness. We avoid 
# setting brightness to complete 0, hence
# minimum is 10% that can be restored.

restore()
{
  MAX=$(cat "$SYSDIR"/*/max_brightness  )
  LIMIT=$((MAX/10)) # get approx 10 percent value
  VAL=$(cat "$1" )
  if [ "$VAL" -lt "$LIMIT"  ] ;
  then
       # avoid going bellow 10% of brightness
       # we don't want user's screen to be completely dark
       echo "$LIMIT" > "$SYSDIR"/*/brightness
  else
       echo "$VAL" > "$SYSDIR"/*/brightness
  fi
}
#------------

# This function works for initial run of the script; the script cannot set
# brightness unless datafile exists first, so here we create the file
# Initial value there will be whatever the current brightness on first
# reboot was

create_datafile()
{
  cat "$SYSDIR"/*/actual_brightness > "$1" 
}

puke(){
    printf "%s\n" "$@" > /dev/stderr
    exit 1
}

main()
{
  local DATAFILE="/opt/.last_brightness"
  local SYSDIR="/sys/class/backlight" # sysfs location of all the data

  # Check pre-conditions for running the script
  if [ "$ARGC" -ne 1  ];then
     puke "Script requires 1 argument"
  fi

  if [ $(id -u) -ne 0 ]   ; then
     puke "Script has to run as root"
  fi

  # ensure datafile exists
  [ -f "$DATAFILE"  ] || create_datafile "$DATAFILE"

  # perform storing or restoring function
  case "$1" in
     'restore') restore  $DATAFILE ;;
     'store') store $DATAFILE ;;
     *) puke "Unknown argument";;
  esac

}

main "$@"
