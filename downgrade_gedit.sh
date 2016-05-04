#!/bin/bash
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: 
# Purpose: 
#    A script to install version 3.10.4 of gedit on Ubuntu
#    16.04 . Some users are unhappy with new gedit design
#    while others want to downgrade in order to use plugins
#    not available in the new gedit. This script simplifies
#    the downgarde process and building from source.
#    The source is obtained from Gnome's official ftp channels
#    The 3.10.4 is installed separatelly, so if you want to go
#    back to the newer version or used along-side 3.10.4 , you
#    can do so, as the newer version is not uninstalled
# Written for: http://askubuntu.com/q/766055/295286
# Tested on: Ubuntu 16.04
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

set -e 
download_gedit()
{
  # Here gnome's official ftp channel is used 
  # feel free to use something else
  # just keep in mind you'd need to make changes to script accordingly
  wget http://ftp.gnome.org/pub/GNOME/sources/gedit/3.10/gedit-3.10.4.tar.xz
}

extract_gedit()
{
 ARCHIVE="gedit-3.10.4.tar.xz"
 tar --extract --xz --verbose --file "$ARCHIVE" && \
 rm "$ARCHIVE"
}


resolve_depends()
{
 apt-get install intltool libenchant-dev libxml2-dev libgtksourceview-3.0-dev gsettings-desktop-schemas-dev  libpeas-dev  itstool libxml2-utils 
}

make_desktop_file()
{
cat > /usr/share/applications/gedit_downgraded.desktop  <<EOF
[Desktop Entry]
Name=Gedit(downgraded)
Type=Application 
Terminal=false
Exec=/usr/local/bin/gedit %U
EOF
}

make_install_gedit()
{

 cd gedit-3.10.4
 ./configure #PKG_CONFIG_PATH="$(pkg-config --variable pc_path pkg-config)"
 make
 make install
}

install()
{
  # If /opt/gedit-3.10.4 doesn't exist, that's a first run
  # otherwise - create the directory, download and extract
  cd /opt
  if [ ! -d "gedit-3.10.4" ] ; then
      mkdir gedit-3.10.4
      download_gedit
      extract_gedit 
  fi
  resolve_depends
  make_install_gedit
  make_desktop_file
  #mark gedit to be held back
  dpkg --set-selections <<< "gedit hold"
}
uninstall()
{
  cd /opt/gedit-3.10.4
  make uninstall
  hash -r
  [ -e /usr/share/applications/gedit_downgraded.desktop  ] && \
     rm /usr/share/applications/gedit_downgraded.desktop
}

parse_args()
{
  local OPTIND option
  while getopts "iu" option
  do
    case ${option} in
         i) install && exit 0 ;;
         u) uninstall && exit 0 ;; 
         \?) echo "Invalid option -${option}" > /dev/stderr  
    esac
  done
}

main()
{

  if [ $# -eq 0 ] ; then
     echo "Must specify -i or -u option" > /dev/stderr
     exit 1
  fi

  if [ $( id -u ) -ne 0 ] ; then
    echo "Must run as root" > /dev/stderr
    exit 1
  else
     parse_args "$@"
  fi
}

main "$@"

