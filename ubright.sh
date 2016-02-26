#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: February 25th, 2016
# Purpose: Simple brightness control for Ubuntu Unity
# Written for: http://askubuntu.com/q/583863/295286
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


# set -x
ARGV0="$0"
ARGC="$#"

main ()
{
  local DISPLAY=:0 
 getPercentage | setBrightness > /dev/null
 # echo $(getPercentage)
}

setBrightness()
{
  local PERCENTAGE
  read PERCENTAGE
  dbus-send --session --print-reply\
    --dest=org.gnome.SettingsDaemon.Power\
    /org/gnome/SettingsDaemon/Power \
    org.gnome.SettingsDaemon.Power.Screen.SetPercentage uint32:"$PERCENTAGE"
}

getPercentage()
{
  local PCT
  PCT="$(zenity --scale)" 
  if [[ -n PCT ]]
  then
      echo "${PCT}"
  fi
}

main
