#!/usr/bin/env
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

ARGV0="$0"
ARGC=$#

store()
{
   cat /sys/class/backlight/*/actual_brightness > "$1"
}

restore()
{
  VAL=$(< "$1" )
  echo $VAL > /sys/class/backlight/*/brightness
}

main()
{


  if [ $ARGC -ne 1  ] || [ $(id -u) -ne 0 ]   ; then
     echo "ERR"
     exit 1
  fi

  local DATAFILE="/home/xieerqi/.last_brightness"
  
  if [ "$1" = restore ];then
     restore  $DATAFILE
  else
     store $DATAFILE
  fi
}

main "$@"
