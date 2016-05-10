#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: May 10th 2016
# Purpose: Notification blocker for Ubuntu
# Written for: 
# Tested on:  Ubuntu 14.04 LTS
###########################################################
# Copyright: Serg Kolo ,2016 
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

mute_notifications()
{ 
  set -x
  self=${ARGV0##*/}
  CHECK_PID_NUMS=$(pgrep -f  "$self -m" | wc -l )
  if [ "$CHECK_PID_NUMS" -gt 2 ]; then
     zenity --info --text "Notifications already disabled"
     exit 0
  else  
     killall notify-osd 2> /dev/null # ensure we have PID
     notify-send 'All notifications will be muted after this one' 
     sleep 1
     while true 
     do 
        PID=$(pgrep notify-osd)
        [  "x$PID" != "x" ]  && 
        kill -TERM $PID 
     done
  fi
}

unmute()
{
  echo $0
  self=${0##*/}
  
  MUTE_PID=$(pgrep -f  "$self -m" ) #match self with -m option
  if [ "x$MUTE_PID" != "x"   ];then
     kill -TERM "$MUTE_PID" &&
     sleep 1 && # ensure the previous process exits
     notify-send "UNMUTED"
     exit 0
  else 
     notify-send "NOTIFICATIONS ALREADY UNMUTED"
     exit 0
  fi  
}

print_usage()
{
  cat > /dev/stderr <<EOF
  usage: notify-block.sh [-m|-u]
EOF
exit 1
}
main()
{
  [ $# -eq 0  ] && print_usage
  
  while getopts "mu" options
  do
  
     case ${options} in
          m) mute_notifications & ;;
          u) unmute ;;
          \?) print_usage ;;
     esac
  
  done
}
main "$@"
