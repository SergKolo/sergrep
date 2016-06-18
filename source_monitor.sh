#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: June 18th 2016
# Purpose: Script that remembers and sets brightness
#  	   depending on power sources
# 
# Written for: http://askubuntu.com/q/788383/295286
# Tested on: Ubuntu 16.04 LTS , Ubuntu Kylin 16.04 LTS
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
wait_ac_connect()
{
  while ! on_ac_power ; do : ; sleep 0.25 ; done
  $VERBOSE && echo "<<< adapter plugged in"
}

wait_ac_disconnect()
{
  while on_ac_power ; do : ; sleep 1.25 ; done 
  $VERBOSE && echo "<<< adapter unplugged"
}

change_brightness()
{
  qdbus org.gnome.SettingsDaemon \
       /org/gnome/SettingsDaemon/Power \
      org.gnome.SettingsDaemon.Power.Screen.SetPercentage "$1"
}

get_brightness()
{
  qdbus org.gnome.SettingsDaemon \
        /org/gnome/SettingsDaemon/Power \
        org.gnome.SettingsDaemon.Power.Screen.GetPercentage
}

print_usage()
{
cat <<EOF

source_monitor.sh [-a INT] [-b INT] [-v] [-h]

-a set initial brightness on AC adapter
-b set initial brightness on batter
-v enable verbose output
-h prints this help text

Copyright Serg Kolo , 2016
EOF
}

parse_args()
{
 # boiler-pate code for reusing, options may change
 local OPTIND opt  # OPTIND must be there, 
                   # opt can be renamed to anything
 # no leading : means errors reported(which is what i want)
 # : after letter means options takes args, no :  - no args
 while getopts "a:b:vh" opt
 do
   case ${opt} in
      a)  AC_PERCENTAGE="${OPTARG}"
        ;;
      b) BAT_PERCENTAGE="${OPTARG}"
        ;;
      v) VERBOSE=true
        ;;
      h) print_usage && exit 0
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

    # default values, if -a,-b, or -v options given
    # they will be changed
    local BAT_PERCENTAGE=50
    local AC_PERCENTAGE=90
    local VERBOSE=false # for debugging
  
    parse_args "$@"
  
    while true
    do
  
      if on_ac_power ; then
         wait_ac_disconnect
          AC_PERCENTAGE=$(($(get_brightness)+1)) # too long to explain why +1
  					     # just try it for yourself
          sleep 0.25
          change_brightness "$BAT_PERCENTAGE" > /dev/null
      else
          wait_ac_connect
          BAT_PERCENTAGE=$(($(get_brightness)+1))
          sleep 0.25
          change_brightness "$AC_PERCENTAGE" > /dev/null
      fi
  
      sleep 0.25

    done

}

main "$@"
