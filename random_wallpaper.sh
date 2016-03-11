#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: March 10th 2016 
# Purpose: Set random wallpaper
#	   To make it start automatically, add it as one of 
#          the Startup Applications in Ubuntu's Unity 
#          or Gnome 
# 
# Written for: http://askubuntu.com/q/744464/295286
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
change_background()
{
    FILE="'file://$(readlink -f "$1" )'" 
    echo changing to "$FILE" 
    gsettings set org.gnome.desktop.background picture-uri "$FILE"
}

make_list()
{
  # -max-depth may be optional , if you want to 
  # traverse subdirectories,too
  find "$1" -maxdepth 1 -type f > "$2"
}

main()
{
  # Variables
  local DISPLAY=:0 # ensure this is set
  local DIR="$1"
  local LIST="/tmp/wallpaper.list"
  local TIME="$2"
  # cat $LIST # for debugging only
  make_list "$DIR" "$LIST"
  while true 
  do
     change_background $( shuf $LIST | head -n 1   )
     sleep 5 #     
  done
}

main "$@"
