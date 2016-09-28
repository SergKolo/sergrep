#!/usr/bin/env python3

# Author: Serg Kolo
# Date: Sept 28, 2016
# Purpose: activates
# Depends: python3-gi
#          xdotool
# Written for: http://askubuntu.com/q/651188/295286

# just in case user runs this with python 2
from __future__ import print_function
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import Gdk,Gio
import sys
import dbus
import subprocess

def run_cmd(cmdlist):
    """ Reusable function for running shell commands"""
    try:
        stdout = subprocess.check_output(cmdlist)
    except subprocess.CalledProcessError:
        print(">>> subprocess:",cmdlist)
        sys.exit(1)
    else:
        if stdout:
            return stdout

def gsettings_get(schema,path,key):
    """Get value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema,path)
    return gsettings.get_value(key)


def get_launcher_object(screen):
    
    # Unity allows launcher to be on multiple
    # monitors, so we need to account for all 
    # window objects of the launcher
    launchers = []

    for window in screen.get_window_stack():
        xid = window.get_xid()
        command = ['xprop','-notype',
                   'WM_NAME','-id',str(xid)
        ]
        xprop = run_cmd(command).decode()
        title = xprop.replace("WM_NAME =","")
        if title.strip()  == '"unity-launcher"':
           launchers.append(window)
           #return window
    return launchers

def get_dbus(bus_type,obj,path,interface,method,arg):
    # Reusable function for accessing dbus
    # This basically works the same as 
    # dbus-send or qdbus. Just give it
    # all the info, and it will spit out output
    if bus_type == "session":
        bus = dbus.SessionBus() 
    if bus_type == "system":
        bus = dbus.SystemBus()
    proxy = bus.get_object(obj,path)
    method = proxy.get_dbus_method(method,interface)
    if arg:
        return method(arg)
    else:
        return method() 
 

def main():


    previous_xid = int()
    screen = Gdk.Screen.get_default()

    while True:

        current_xid = screen.get_active_window().get_xid()
        if  int(current_xid) == previous_xid:
            continue
        previous_xid = int(current_xid)
        icon_size = gsettings_get(
                        'org.compiz.unityshell',
                        '/org/compiz/profiles/unity/plugins/unityshell/',
                        'icon-size')
        icon_size = int(str(icon_size))
        position = str(gsettings_get(
                       'com.canonical.Unity.Launcher',
                       None,
                       'launcher-position'))
        screen = Gdk.Screen.get_default()
        launcher_objs = get_launcher_object(screen)

        # for faster processing,figure out which launcher is used
        # first before running xdotool command. We also need
        # to account for different launcher positions (available since 16.04)
        pointer_on_launcher = None
        for launcher in launcher_objs:
            if 'Left' in position and  \
               abs(launcher.get_pointer().x) <= icon_size:
                  pointer_on_launcher = True
            elif 'Bottom' in position and \
               abs(launcher.get_pointer().y) <= icon_size:
                  pointer_on_launcher = True
            else:
               continue


        active_xid = int(screen.get_active_window().get_xid())
        
        application = get_dbus('session',
                               'org.ayatana.bamf',
                               '/org/ayatana/bamf/matcher',
                               'org.ayatana.bamf.matcher',
                               'ApplicationForXid',
                               active_xid)

        # Apparently desktop window returns empty application
        # we need to account for that as well
        if application:
            xids = list(get_dbus('session',
                            'org.ayatana.bamf',
                            application,
                            'org.ayatana.bamf.application',
                            'Xids',None))

        if pointer_on_launcher and\
           len(xids) == 1:
               run_cmd(['xdotool','key','Ctrl+Super+W'])


if __name__ == '__main__':
    main()
