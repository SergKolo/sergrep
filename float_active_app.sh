#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 9 , 2016
# Purpose: Make the icon of currently active app float to
#          the top of unity launcher
# Written for: 
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
get_active_app()
{
  qdbus org.ayatana.bamf /org/ayatana/bamf/matcher \
      org.ayatana.bamf.matcher.ActiveApplication 
}

get_active_desktop_file()
{
  active_app=$(get_active_app)
  if [ -n "$active_app"  ];then
     qdbus org.ayatana.bamf "$active_app" \
        org.ayatana.bamf.application.DesktopFile | \
        awk -F '/' '{print "application://"$NF}'
  fi
}

get_launcher_items()
{
  gsettings get com.canonical.Unity.Launcher favorites | \
     awk '{ gsub(/,|\[|\]/,""); print}'
}

make_new_list()
{
 
 array=( $( get_launcher_items ) )
 printf "%s, " "$active"
 COUNT=0
 for item in ${array[@]} ; do
   COUNT=$(($COUNT+1))

   if [ "$item" = "$active"   ];then
     continue
   fi

   if [ $COUNT -eq ${#array[@]}  ];then
      printf "%s " "$item"
   else
      printf "%s, " "$item"
   fi
 done
}

set_launcher_items()
{
  gsettings set com.canonical.Unity.Launcher favorites "$1"
}

main()
{
  local active=""
  while true;
  do 
    active="'$(get_active_desktop_file)'"
    if [ "$active" = "'application://compiz.desktop'" ] || [ -z "$active"   ] ;then
       continue
    fi
    new_list="[$(make_new_list)]"
    set_launcher_items "$new_list"
  sleep 0.25
  done
}

main

