#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 2nd , 2016
# Purpose:  Close all windows of the active application
# Written for: http://askubuntu.com/q/753033/295286
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
get_running_apps()
{
  qdbus org.ayatana.bamf /org/ayatana/bamf/matcher org.ayatana.bamf.matcher.RunningApplications
}

list_children()
{
 qdbus org.ayatana.bamf "$1"  org.ayatana.bamf.view.Children
}

get_pid()
{
 qdbus org.ayatana.bamf "$1"  org.ayatana.bamf.window.GetPid
}

main()
{
  local ACTIVE
  local apps_list
  apps_list=( $( get_running_apps | tr '\n' ' ' ) )

  for app in ${apps_list[@]} ; do
      ACTIVE=$(qdbus org.ayatana.bamf $app org.ayatana.bamf.view.IsActive)
      if [ "x$ACTIVE" = "xtrue"   ] ; then
         windows=( $( list_children $app | tr '\n' ' ' ) )
      fi
  done

for window in ${windows[@]} ; do
    PIDS+=( $(get_pid $window) )
done

if zenity --question \
   --text="Do you really want to kill ${#PIDS[@]} windows ?" ; 
   then
   kill ${PIDS[@]}
fi

}
main
