#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: May 14th , 2016 
# Purpose: Ensure that user closes all or specific
#          running windows and exits without any work
#          lost
# Written for: http://askubuntu.com/q/771227/295286
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

_notify_user()
{
 # Close the shutdown dialog and display
 # graphical popup which will ask user's shutdown 
 # confirmation. If user clicks OK , we shutdown.
 # If cancel - no action.
 qdbus com.canonical.Unity \
       /com/canonical/Unity/Session \
       com.canonical.Unity.Session.CancelAction

 if zenity --question --title='WARNING!' \
      --text="You have running apps. Shutdown anyway ?" \
      2> /dev/null
 then
      qdbus com.canonical.Unity  \
           /com/canonical/Unity/Session \
           com.canonical.Unity.Session.Shutdown
 fi
}

_get_running_apps()
{
  # Gets list of .desktop files for each
  # running app
  qdbus org.ayatana.bamf \
       /org/ayatana/bamf/matcher \
       org.ayatana.bamf.matcher.RunningApplicationsDesktopFiles 
        
}

_check_any_running()
{
   # Among the running apps there's always one
   # .desktop file, which is compiz.desktop. 
   # We want to know if there's anything besides that
   if [ $( _get_running_apps | wc -l ) -gt 1  ]; 
   then
         _notify_user
   fi
}

_check_specific_running()
{
  # Get list of running apps and see if
  # the .desktop file we got is on the list
  if _get_running_apps | grep -q "$1"
  then
       _notify_user
  fi
}

_select_app()
{
  # xwininfo provides nice interface which allows selecting
  #  a window. The rest is just simple parsing and passing 
  # around the XID of the app.
  notify-send 'Select a window you would like to monitor '
  XID=$(xwininfo -int | awk '/xwininfo: Window id/{print $4}')
  APP=$(qdbus org.ayatana.bamf \
       /org/ayatana/bamf/matcher \
       org.ayatana.bamf.matcher.ApplicationForXid  $XID )
  qdbus org.ayatana.bamf \
        "$APP" org.ayatana.bamf.application.DesktopFile
}


_print_usage()
{
 cat <<EOF
 safe_shutdown.sh [-a | -c |-s DESKTOP_FILE | -h  ]
 
 Options:
 -a Monitor any open applications.
 -c Graphically select an app
 -s specify .desktop file for app on command line
 -h print this text
 
  Copyright Serg Kolo , 2016
EOF
}

parse_args()
{
 if [ $ARGC -eq 0 ] ; then
   printf "%s: No option specified\n Usage:\n" ${ARGV0##*/} 
   _print_usage 
   exit 1
 fi
 
 local OPTIND opt
 while getopts "acs:" opt
 do
   case ${opt} in
      a) FUNCTION="_check_any_running"
        break
        ;;
      c)
        DESK_FILE=$(_select_app  )
        FUNCTION=" _check_specific_running $DESK_FILE   "
        break
        ;;

      s) DESK_FILE=${OPTARG}
         FUNCTION=" _check_specific_running $DESK_FILE   "
         break
        ;;
      h) _print_usage
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
 # Basic idea is to let user chose what to do
 # then monitor dbus for appropriate signal
 # Once the RebootRequested signal is received 
 # then perform appropriate checks ( for a specific
 # or all apps ). 
 local FUNCTION
 parse_args  "$@"
 dbus-monitor --profile \
      "interface='com.canonical.Unity.Session',type=signal" |
 while read -r line;
 do
  case "$line" in
       *RebootRequested*)  $FUNCTION ;;
  esac
 done
}

main "$@"
