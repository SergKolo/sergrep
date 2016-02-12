#!/bin/bash
# Author: Serg Kolo
# Date: Feb 11, 2016
# Description: battery monitoring script used
# with Ubuntu Linux. Tested on 14.04 release
# Can be used when you are working form TTY only or 
# don't notice battery capacity indicator in the Unity's
# top bar

# Copyright (c) 2016 Serg Kolo
# Permission is hereby granted, free of charge, to any person 
# obtaining a copy of this software and associated documentation 
# files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, 
# publish, distribute, sublicense, and/or sell copies of the Software, 
# and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
# The above copyright notice and this permission notice shall
# be included in all copies or substantial portions of the Software
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN 
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.





# BASIC IDEA:
# Polling for ac power source
# using /sbin/on_ac_power
# Keep polling if were on ac.
# Otherwise go get battery percentage;
# if it's bellow 10 ( up to user to set )
# Send a message everywhere that we're low on power
# Depending on battery discharge , one may want to 
# repeat this message every minute or every ten.
# My batter holds up pretty well , so I've set
# it to poll for 10% and repeat message every 5 mins
# Why _____EOF ? Just to keep everything aligned nicely

##########################
# VARIABLES
##########################
DISPLAY=:0

# ---
##########################
# FUNCTIONS
##########################
function getCapacity
{
  awk -F'=' '$1=="POWER_SUPPLY_CAPACITY"{print $2}' \
      /sys/class/power_supply/BAT1/uevent 
}

function broadcast
{
  printf \
 "\t\tWarning: Battery is at $BATPOWER  percent \n\t\tConnect the charger"\
  | wall
}
# ---
##########################
# MAIN
##########################

# set -x
while : ;do
    if on_ac_power ; then
    sleep 3; continue;
  fi
  
  BATPOWER="$(getCapacity)"

  if [ $BATPOWER -lt 10   ]; then
     broadcast
  fi
  sleep 300
  # sleep 60
done
# EOF
