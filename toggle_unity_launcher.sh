#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 8th , 2016
# Purpose: Set Unity launcher to show up only on
#          specific viewport. By default - viewport 0,0
# Written for: http://askubuntu.com/q/349247/295286
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

ARGV0="$0"
ARGC=$#

print_usage()
{
  cat << EOF

Copyright 2016 Serg Kolo
Usage: toggle_unity_launcher.sh [-x INT -y INT] [-h]

The script toggles Unity Launcher on user-defined viewport
By default - launcher appears only on 0, 0

-x and -y flags serve to set custom viewport 

Use 'xprop -root -notype _NET_DESKTOP_VIEWPORT' to find
the exact coordinates of a viewport you want to set
EOF
}

get_viewport() 
{
	xprop -root -notype _NET_DESKTOP_VIEWPORT | awk -F '=' '{printf "%s",substr($2,2)}'
} 

set_launcher_mode()
{
  dconf write /org/compiz/profiles/unity/plugins/unityshell/launcher-hide-mode $1

}

poll_viewport_change()
{
  while [ "$(get_viewport)" = "$VIEWPORT" ]  
  do
    set_launcher_mode 0
    sleep 0.25
  done
}

parse_args()
{
  local OPTIND opt
  while getopts "x:y:h" opt
  do
   case ${opt} in
      x) XPOS=${OPTARG} 
        ;;
      y) YPOS=${OPTARG}
        ;;
      h) print_usage
         exit 0
        ;;
     \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    esac
  done
  shift $((OPTIND-1))
}

main()
{
 local XPOS=0
 local YPOS=0
 parse_args "$@"
 local VIEWPORT=$(printf "%s, %s" "$XPOS" "$YPOS"  )  
 while true
 do
  poll_viewport_change 
  set_launcher_mode 1 # happens only when 
                      # previous function exits
  sleep 0.25
 done
}

main "$@"
