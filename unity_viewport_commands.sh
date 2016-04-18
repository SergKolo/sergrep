#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 18th, 2016
# Purpose: Script that runs a command depending
#          on the current viewport
# Written for: http://askubuntu.com/q/56367/295286
# Tested on: Ubuntu 14.04 , Unity 7.2.6
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
get_screen_geometry()
{
 xwininfo -root | awk '/-geometry/{gsub(/+|x/," ");print $2,$3}'  
}

gui_dialog()
{
  SCHEMA="org.compiz.core:/org/compiz/profiles/unity/plugins/core/"
  read swidth sdepth  <<< "$(get_screen_geometry)" 
  vwidth=$(gsettings get $SCHEMA hsize)
  vheight=$(gsettings get $SCHEMA vsize)
  
 width=0
 for horizontal in $(seq 1 $vwidth); do
    height=0 
    for vertical in $(seq 1 $vheight);  do

      # array+=( FALSE  )
      viewport+=( $(echo "$width"x"$height") )

    height=$(($height+$sdepth))
    done
 width=$(($width+$swidth))
 done

  local fmtstr=""
  for i in ${viewport[@]} ; do
    fmtstr=$fmtstr"$(printf "%s\"%s\" " "--add-entry=" $i)"
  done

  STR=$(zenity --forms --title="Set Viewport Commands" \
           --text='Please avoid using # character' --separator="#" \
           $fmtstr 2>/dev/null) 

  OLDIFS=$IFS
  IFS="#"
  commands=( $STR   )
  IFS=$OLDIFS
 
# for loop done with while loop
  counter=0
  while [ $counter -lt ${#viewport[@]}   ] ;
  do 
    echo "${viewport[$counter]}":"${commands[$counter]}"
    counter=$(($counter+1))
  done
}

get_current_viewport()
{
  xprop -root -notype _NET_DESKTOP_VIEWPORT  | \
      awk -F'=' '{gsub(/\,/,"x");gsub(/\ /,"");print $2}'
}

run_viewport_command()
{
  [ -r "$HOME"/"$DATAFILE"  ] || \
      { printf ">>> ERR: commands file doesn't exit. \
        \nCreate new one using -g flag" > /dev/stderr ; exit 1 ;}
  local VP=$(get_current_viewport)
  cmd=$(awk -v regex="^$VP" -F ':' '$0~regex{ $1="";print }' "$HOME"/"$DATAFILE")
  eval $cmd " &> /dev/null  &"
}


view_current_settings()
{
  if [ -r "$HOME"/"$DATAFILE"   ]; then
     cat "$HOME"/"$DATAFILE"  | \
     zenity --list --height=250 --width=250  \
     --title="current settings"  --column=""  2> /dev/null
  else
      printf ">>> ERR: commands file doesn't exist
      \\nCreate new one using -g flag" > /dev/stderr
      exit 1
  fi

}
 
change_single()
{
  if [ -r "$HOME"/"$DATAFILE"  ] ;then
    NEWLINE="$(zenity --forms --separator='#' \
         --add-entry="viewport to change(XPOSxYPOS):"\
         --add-entry="new command")"
    remove_this=$(awk -F '#' '{ print $1  }' <<< "$NEWLINE")
    sed -i '/^'$remove_this'/d' "$HOME"/"$DATAFILE"
    new_cmd=$(awk -F '#' '{$1="";printf "%s",$0}' <<< "$NEWLINE")
    echo "$remove_this":"$new_cmd" >> "$HOME"/"$DATAFILE"
  fi
}

print_usage()
{
cat << EOF

Usage: viewport_commands.sh [option] 
Copyright Serg Kolo , 2016

-r run a command for current viewport
-g generate new list of commands
-h print this text
-v view current settings
-s change setting for a single viewport

EOF
}



parse_args()
{
  [ $# -eq 0  ] && print_usage && exit 0
  local option OPTIND
  while getopts "grvhs" option ;
  do
     case ${option} in
        g) gui_dialog > "$HOME"/"$DATAFILE"
        ;;
        r) run_viewport_command 
        ;;
        v) view_current_settings
        ;;
        s) change_single
        ;;
        h) print_usage && exit 0
        ;;
        \?) echo "Invalid option: -$OPTARG" >&2
        ;;
     esac
  done
  shift $((OPTIND-1))

}

main()
{
  local DATAFILE=".viewport_commands"
  parse_args "$@"
  exit 0
}

main "$@"
