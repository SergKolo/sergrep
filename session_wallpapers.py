#!/usr/bin/env python
# -*- coding: utf-8 -*-
from gi.repository import Gio,Notify
import dbus
import sys
import os
import time

###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date:  June 30 , 2016
# Purpose: set wallpaper depending on desktop session
# Written for: http://askubuntu.com/q/146211/295286
# Tested on: Ubuntu 16.04 LTS 
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


def get_dbus(obj,path,interface,method):
    # Reusable function for accessing dbus
    # This basically works the same as 
    # dbus-send or qdbus. Just give it
    # all the info, and it will spit out output
    bus = dbus.SessionBus() 
    proxy = bus.get_object(obj,path)
    method = proxy.get_dbus_method(method,interface)
    return method()

def gsettings_set(schema,key,value):
    gsettings = Gio.Settings.new(schema)
    gsettings.set_string(key,value)

def send_notif(title,message):
    Notify.init("Wallpaper setter")
    content = Notify.Notification.new(title,message)
    content.show()

def set_wallpaper( image  ):
    if os.path.isfile( image ):
        gsettings_set('org.gnome.desktop.background', \
                      'picture-options','zoom' )
        gsettings_set('org.gnome.desktop.background',\
                      'picture-uri', 'file://' + image)    
        send_notif("Session wallpaper set",image)
        sys.exit(0)
    else:
        send_notif( "We have a problem!" ,  
                    "Wallpaper image for this session doesn't exist.")
        sys.exit(1)

def print_usage():
    print  """
session_wallpapers.py [UNITY_WALLPAPER] [GNOME_WALLPAPER]

This script sets wallpaper depending on the desktop
session user chooses. Both images must be given in
their full path form, otherwise the script exists
with  status 1. Upon successful setting, it displays
notification and exists with status 0

Copyright Serg Kolo , 2016
"""

def main(): 
    if len(sys.argv) < 2:
       print_usage()
       sys.exit(0)
    
    # Wait for windows to appear
    windows = ""
    while not windows:
        time.sleep(3)
        windows = get_dbus( 'org.ayatana.bamf',\
                            '/org/ayatana/bamf/matcher' ,\
                            'org.ayatana.bamf.matcher',\
                            'WindowPaths' )
    
    # get list of open windows
    name_list = []
    for window in windows:
        name_list.append( get_dbus( 'org.ayatana.bamf', window, \
                                    'org.ayatana.bamf.view','Name'  ))
    # Do we have unity-dash open ?
    # If so that's unity session,
    # otherwise - that's Gnome or
    # something else.
    if "unity-dash" in  name_list:
        print sys.argv[1]
        set_wallpaper(sys.argv[1])
    else:
        print sys.argv[2]
        set_wallpaper(sys.argv[2])
        
if '__main__' == __name__:
   main() 
