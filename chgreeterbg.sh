#!/bin/bash
#
# Author: Serg Kolo
# Date: Nov 17, 2015
# Script Description: changes background of 
# the unity greeter, throught creating/modifying 
# appropriate glib schema override file
#
# Copyright Sergiy Kolodyazhnyy 2015
#
# Permission to use, copy, modify, and distribute this software is hereby granted 
# without fee, provided that  the copyright notice above and this permission statement
# appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL 
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.


function printUsage
{
  printf "\n!!! %s\n" "Usage: sudo script.sh /path/to/image"
  exit 1
}

function createOR
{
  touch $1
  printf "%s\n" "[com.canonical.unity-greeter]" >> $1
  printf "%s\n" "draw-user-backgrounds=false" >> $1
  printf "%s\n" "background=" >> $1
}

function changeBG
{
   printf "Changing background to $1\n"
   sed -i "s;background=.*;background=\'"$1"\';g" "$2"
   printf "Recompiling schemas\n"
   glib-compile-schemas /usr/share/glib-2.0/schemas/  
   printf "Done. Preview changes with dm-tool switch-to-greeter command"
}


###################
# MAIN
###################
[ $( id -u ) -eq 0 ] || { echo ">>> Error: Must run as root "; printUsage; exit 1;}

[ $# -eq 0 ] && printUsage

# override file for unity greeter glib schema
ORFILE="/usr/share/glib-2.0/schemas/10_unity_greeter_background.gschema.override"
# full path to the image
IMAGE="$(readlink -f "$@")"

# make sure image is readable by non-owner

chmod +x "$IMAGE"

# check if the override file exists, else create it
[ -f $ORFILE ] || createOR "$ORFILE"

changeBG "$IMAGE" "$ORFILE"
