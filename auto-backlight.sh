#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: February 26 2016 
# Purpose: Brightness control that polls for
#          ac adapter presence. Uses
# Dependencies: on_ac_power script, dbus, Unity/Gnome 
# Written for: http://askubuntu.com/q/739617/295286
# Tested on: Ubuntu 14.04 LTS
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
set -x

ARGV0="$0"
ARGC=$#


main()
{

  # defaults
  local DISPLAY=:0
  local DECREASE=30
  local INCREASE=75
  local RCFILE="$HOME/.auto-backlightrc"
  #---

  # Check the settings
  if [ -f $RCFILE ]
  then 
       source $RCFILE 
  else
       create_rcfile $DECREASE $INCREASE
  fi
  #---

  # now actually test if we're using ac adapter
  if ! on_ac_power 
  then 
        change_brightness $DECREASE
  # The two lines bellow are optional for 
  # setting brightness if on AC. remove # 
  # if you want to use these two

  # else 
       # change_brightness $INCREASE
  fi

}

change_brightness()
{
  dbus-send --session --print-reply\
    --dest=org.gnome.SettingsDaemon.Power\
    /org/gnome/SettingsDaemon/Power \
    org.gnome.SettingsDaemon.Power.Screen.SetPercentage uint32:"$1"
}

create_rcfile()
{
  echo "DECREASE="$1 >  "$RCFILE"
  echo "INCREASE="$2 >> "$RCFILE"
}


while true
do
   main
   sleep 0.25
done


