#!/usr/bin/env bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: March 20,2016
# Purpose: Color changer script for Ubuntu Unity launcher
# Written for: 
# Tested on: Ubuntu 14.04
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
main()
{
  renice -n 10 $$
  num=0;
  while true
  do 
    set_unity_launcher_color   $(printf '%6.6xff' $num)
    num=$(($num+510)) 
    if [ $num -eq 16777215 ]
       then num=0
    fi
    sleep 0.05
    done
}

set_unity_launcher_color()
{
  key="/org/compiz/profiles/unity/plugins/unityshell/background-color"
  hex_string=\'\#$1\'
#  echo $hex_string
  dconf write "$key" "$hex_string"
}

main
