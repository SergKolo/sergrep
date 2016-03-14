#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: March 11, 2016
# Purpose: Script to detect connection/disconnection
#          of the ac adapter
#          
# 
# Written for: http://askubuntu.com/q/542986/295286
# Tested on: Ubuntu 14.04 LTS
# Version: 0.2
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
#set -x
ARGV0="$0"
ARGC=$#

test_presence()
{
  on_ac_power
  echo $?
}

notify_change()
{
   pgrep -f '/usr/bin/X' > /dev/null && GUI=true
   connected='AC adapter connected'
   disconnected='AC adapter disconnected'

   if [ $1 -eq 0 ]
   then
           wall <<< $connected        
           $GUI && DISPLAY=:0 notify-send 'AC adapter connected'
           
   else
           wall <<< $connected
           $GUI && DISPLAY=:0 notify-send 'AC adapter disconnected'
   fi
}

main()
{
  FLAG=$(test_presence)

  while true
  do
     STATUS=$(test_presence)

     if [ $STATUS -eq $FLAG   ]
     then
        continue
     else
        notify_change $STATUS
        FLAG=$STATUS
     fi

  sleep 3 #0.25
  done
}  

main 
