#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: April 12 , 2016
# Purpose: Disable super key that brings up Unity Dash
#          per specific application
# 
# Written for: http://askubuntu.com/q/754884/295286
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
enable_dash_key()
{
  gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ show-launcher '<Super>'
}

disable_dash_key()
{
gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ show-launcher 'Disabled'
}



get_active_app()
{
   qdbus org.ayatana.bamf \
        /org/ayatana/bamf/matcher \
        org.ayatana.bamf.matcher.ActiveApplication
}

get_active_app_name()
{
  qdbus org.ayatana.bamf \
   $(get_active_app)   \
   org.ayatana.bamf.view.Name
}

check_active_app()
{
active_name=$(get_active_app_name)
#echo $active_name and  $1
case "$active_name" in
  "$1") disable_dash_key ;;
   *) enable_dash_key ;;
esac
}

main()
{
while true 
do
  check_active_app "$1"
  sleep 0.25
done
}

main "$@"
