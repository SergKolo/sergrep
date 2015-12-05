#!/bin/bash
# Author : Serg Kolo
# Date: Dec 5, 2015
# Description: Script to render image and set it as background
# in conjunction with fbterm
# Depends: fbterm,fbi, awk
# Written for: http://askubuntu.com/q/701874/295286

function printUsage
{
  echo "<<< Script to set background image in TTY console"
  echo "<<< Written by Serg Kolo, Dec 5 , 2015"
  echo "<<< Usage: scriptName.sh /path/to/image"
  echo "<<< Must be ran with root privileges, in TTY only"
  echo "exiting"
  
}

# check if we're root, if there's at least one ARG, and it is a TTY

if [ "$(whoami)" != "root"   ] || [ "$#" -eq 0  ] ||  [ "$( tty | awk '{gsub(/[[:digit:]]/,""); gsub(/\/dev\//,"");print}' )" != "tty"  ] ;then

   printUsage
   exit 1
fi



# read the full path of the image

IMAGE="$( readlink -f "$@" )"

# Launch fbi with whatever image was supplied as command line arg
# then take out whatever is the data in framebuffer;
# Store that data to /tmp folder
 
( sleep 1; cat /dev/fb0 > /tmp/BACKGROUND.fbimg ; sleep 1; pkill fbi ) & fbi -t 2 -1 --noverbose -a  "$IMAGE"

# This portion is really optional; you can comment it out 
# if you choose so

echo "LAUNCH FBTERM ?(y/n)"
read ANSWER

if [ "$ANSWER" != "y"  ] ; then
   echo exiting
   exit 1
fi

# The man page states that fbterm takes screenshot of 
# what is currently in framebuffer and sets it as background
# if FBTERM_BACKGROUND_IMAGE is set to 1
# Therefore the trick is to send the framebuffer data captured
# in the last step (which will display the image on screen)
# and then launch fbterm. Note, that I send output from the command
# send to background in order to avoid the extra text displayed on 
# screen. That way we have clear image in framebuffer, without 
# the shell text, when we launch fbterm

export FBTERM_BACKGROUND_IMAGE=1 
clear
( cat /tmp/BACKGROUND.fbimg  > /dev/fb0 &) > /dev/null; sleep 0.25; fbterm 




