#! /bin/bash

##########################
# AUTHOR: Serg Kolo 
# Date: Saturday, December 26th, 2015
# Description: Script to notify user and prevent 
#	shutdown or reboot
#	if any update or package manager
#	are running. 
# TESTED ON: 14.04.3 LTS, Trusty Tahr
# WRITTEN FOR: http://askubuntu.com/q/702156/295286
# VERSION: 2, removed xdotool, using dbus method
#          changed to C-style of organizing code
#########################

# Copyright (c) 2015 Serg Kolo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal in 
# the Software without restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all 
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Uncomment the line bellow if needed for debugging
# set -x
###########################
# VARIABLES
###########################

DISPLAY=:0 # has to be set since we are using notify-send


###########################
# MAIN
###########################
#
#	 Basic idea : This runs dbus-monitor which waits for
# "RebootRequested" memberf from com.canonical.Unity.Session ,
# which apprears only when the user clicks the shutdown option 
# from the Unity's top right drop down box. Why RebootRequested ?
# Because this message is guaranteed to pop up once user presses
# the shutdown button.
# 	The while loop with read command does the big job.
# dbus-monitor sends initial message , so we want to filter only
# The output that contains the string we need, hence the case...esac
# structure employed here. Once we get the proper message.
# we check whether update-manager or package managers are running
# If there is one instance, then call CancelAction method
# and send notification to the user.
# 	Both dbus-monitor and while loop run continuously. This
# can be launcher as script in `/etc/rc.local` or `/etc/rc2.d`
# or preferably (!) in `/etc/xdg/autostart/` . 
# 	Here is sample /etc/xdg/autostart/preventShutdown.desktop file
# 
# [Desktop Entry]
# Type=Application
# Name=Prevent-Update
# Exec=/home/$USER/bin/preventShutdown.sh
# OnlyShowIn=GNOME;Unity;
# Terminal=false
# 
# Remember to make this file  as well as script be root-owned with 
# chmod +x /path/to/Script.
# It is preferred to store the script in user's personal $HOME/bin
# folder.
# Make sure to edit $HOME/.profile file to include that into $PATH
# variable

interrupt()
{
 qdbus com.canonical.Unity /com/canonical/Unity/Session com.canonical.Unity.Session.CancelAction
 notify-send "<<< UPDATE IN PROGRESS; DO NOT SHUT DOWN>>>"
 wall <<< "<<< UPDATE IN PROGRESS; DO NOT SHUT DOWN>>>"
}

main()
{
 dbus-monitor --profile "interface='com.canonical.Unity.Session',type=signal" |
 while read -r line;
 do
  case "$line" in
   *RebootRequested*)
       pgrep update-manager || pgrep apt-get || pgrep dpkg
	if [ $? -eq 0 ]; then
           interrupt
        fi
     ;;
   esac
 done
}

main
