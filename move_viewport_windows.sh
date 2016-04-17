#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 17 2016
# Purpose: Move all windows on the current viewport
#          to a user-defined one
# Written for:
# Tested on: Ubuntu 14.04 LTS , Unity 7.2.6
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

get_active_viewport()
{
  xprop -root -notype _NET_DESKTOP_VIEWPORT
}

get_screen_geometry()
{
 xwininfo -root | awk '/-geometry/{gsub(/+|x/," ");print $2,$3}'  
}

current_wins()
{
   wmctrl -lG | \
   awk -v xlim="$XMAX" -v ylim="$YMAX" \
      '$3>0 && $3<xlim  && $4>0 && $4<ylim \
      {winid=sprintf("%d",strtonum($1));$1=winid;print}'
}

gui_selection()
{
  SCHEMA="org.compiz.core:/org/compiz/profiles/unity/plugins/core/"
  read swidth sdepth  <<< "$(get_screen_geometry)"
  vwidth=$(gsettings get $SCHEMA hsize)
  vheight=$(gsettings get $SCHEMA vsize)
  
 width=0
 for horizontal in $(seq 1 $vwidth); do
    height=0 
    for vertical in $(seq 1 $vheight);  do

      array+=( FALSE  )
      array+=( $(echo "$width"x"$height") )

    height=$(($height+$sdepth))
    done
 width=$(($width+$swidth))
 done

 zenity --list --radiolist --column="" --column "CHOICE" ${array[@]} --width 350 --height 350

}

print_usage()
{
cat << EOF
move_viewport_windows.sh [-v 'XPOS YPOS' ] [-g] [-f ] [-h]

Copyright Serg Kolo , 2016

The script gets list of all windows on the current Unity 
viewport and moves them to user-specified viewport. If
ran without flags specified, script prints this text

-g flag brings up GUI dialog with list of viewports

-v allows manually specifying viewoport. Argument must be
   quoted, X and Y position space separated

-f if set, the viewport will switch to the same one where
   windows were sent

-h prints this text

** NOTE ** 
wmctrl and xdotool are required for this script to work
properly. You can install them via sudo apt-get install
xdotool and wmctrl
 
EOF
}

parse_args()
{
  if [ $# -eq 0  ];then
    print_usage
    exit
  fi
  while getopts "v:ghf" opt
 do
   case ${opt} in
     v) NEWVP=${OPTARG}
        ;;
     g) NEWVP="$(gui_selection | tr 'x' ' ' )"
        ;;
     f) FOLLOW=true
        ;; 
     h) print_usage
        exit 0
        ;;
     \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    esac
  done
  shift $((OPTIND-1))
}

main()
{
 # Basic idea:
 #-------------------
 # 1. get current viewport and list of windows
 # 2. go to viewport 0 0 and move all windows from list
 #    to desired viewport
 # 3. go back to original viewport or follow the windows,
 #    depending on user choice
 # 4. Tell the user where they are currently

 local FOLLOW
 local NEWVP # coordinates of desired viewport
 local XMAX YMAX # must be two vals for awk to work
 local OLDVP=$(get_active_viewport | awk -F '=' '{sub(/,/," ");print $2}' )

 parse_args "$@"

 read XMAX YMAX  <<< "$(get_screen_geometry)" # move to getopts

 windows=( $(current_wins | awk '{ printf "%s ",$1 }') )

 xdotool set_desktop_viewport 0 0 
 for win in ${windows[@]} ; do
    echo "$win"
    xdotool windowmove $win $NEWVP
 done
 # sleep 0.25 # uncomment if necessary

 if [ $FOLLOW  ]; then
     xdotool set_desktop_viewport $NEWVP
 else
     xdotool set_desktop_viewport $OLDVP
 fi

 sleep 0.25 # delay to allow catching active viewport
 notify-send "current viewport is $(get_active_viewport | awk -F '=' '{sub(/,/," ");print $2}' )"
 exit 0
}

main "$@"
