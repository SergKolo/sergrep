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
#set -x
print_usage()
{
  printf "\n!!! %s\n%s\n" "Usage:" "sudo script.sh /path/to/image"
  exit 1
}

create_override_file()
{
  # ensure image is readable
  chmod +r "$image_file"

  # Ensure file exists with required information
  { printf "%s\n" "[com.canonical.unity-greeter]" ;
    printf "%s\n" "draw-user-backgrounds=false" ;
    printf "%s\n" "background='$2'" ;
  } > "$1"

  glib-compile-schemas "$3"
}

main()
{

    ARGC=$#
    ARGV="$@"

    local image_file="$(readlink -e "$ARGV" 2>/dev/null )" 
    local schemas_dir="/usr/share/glib-2.0/schemas/"
    local override_file="$schemas_dir/99_unity_greeter_background.gschema.override" 
    
    if [ -z $ARGV ];then 
        image_file="$(zenity --file-selection --filename='/home' )"
    fi
    
    if [ -z "$image_file" ] || ! [ -f "$image_file"  ] ;then
        exit 1
    fi
    
    create_override_file "$override_file" "$image_file" "$schemas_dir"
    
    text="Done. Preview changes with 'dm-tool switch-to-greeter' command"
    if [ $? -eq 0  ] && [ -z "$ARGV"   ];then
        zenity --info --text="$text"
    else
        printf "\n%s\n" "$text"
    fi
}

# check if we're root, else quit
if [ $( id -u ) -eq 0 ];then
    main "$@" 
else
    # calling script without arguments spawns GUI dialog
    if [ $ARGC -eq 0   ];then
        zenity --password | \
               sudo -S "$(readlink -e  $0)" -p "" \
               || exit 1
    else
        sudo "$(readlink -e $0)" "$(readlink -q -e "$@" )"
    fi
fi

