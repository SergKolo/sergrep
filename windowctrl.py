#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Program name: windowctrl.py
Author: Sergiy Kolodyazhnyy
Date:  Sept 18, 2016
Written for: http://askubuntu.com/q/826310/295286
Tested on Ubuntu 16.04 LTS
"""
from __future__ import print_function
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import Gio,Gdk
import sys
import dbus
import subprocess
import argparse

def gsettings_get(schema,path,key):
    """Get value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema,path)
    return gsettings.get_value(key)

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

def new_window():
    screen = Gdk.Screen.get_default()
    active_xid = int(screen.get_active_window().get_xid())
    app_path = get_dbus( 'session',
                         'org.ayatana.bamf',
                         '/org/ayatana/bamf/matcher',
                         'org.ayatana.bamf.matcher',
                         'ApplicationForXid',
                         active_xid
                         )

    desk_file  = get_dbus('session',
                          'org.ayatana.bamf',
                          str(app_path),
                          'org.ayatana.bamf.application',
                          'DesktopFile',
                          None
                          )

    # Big credit to Six: http://askubuntu.com/a/664272/295286
    Gio.DesktopAppInfo.new_from_filename(desk_file).launch_uris(None)

    

def enumerate_viewports():
    """ generates enumerated dictionary of viewports and their
        indexes, counting left to right """
    schema="org.compiz.core"
    path="/org/compiz/profiles/unity/plugins/core/"
    keys=['hsize','vsize']
    screen = Gdk.Screen.get_default()
    screen_size=[ screen.get_width(),screen.get_height()]
    grid=[ int(str(gsettings_get(schema,path,key))) for key in keys]
    x_vals=[ screen_size[0]*x for x in range(0,grid[0]) ]
    y_vals=[screen_size[1]*x for x in range(0,grid[1]) ]
    
    viewports=[(x,y)  for y in y_vals for x in x_vals ]
    
    return {vp:ix for ix,vp in enumerate(viewports,1)}


def get_current_viewport():
    """returns tuple representing current viewport, 
       in format (width,height)"""
    vp_string = run_cmd(['xprop', '-root', 
                         '-notype', '_NET_DESKTOP_VIEWPORT'])
    vp_list=vp_string.decode().strip().split('=')[1].split(',')
    return tuple( int(i)  for i in vp_list )

def maximize():

    screen = Gdk.Screen.get_default()
    window = screen.get_active_window()
    window.maximize()
    screen.get_active_window()
    window.process_all_updates()
   
def unmaximize():

    screen = Gdk.Screen.get_default()
    window = screen.get_active_window()
    window.unmaximize()
    screen.get_active_window()
    window.process_all_updates()

def minimize():

    screen = Gdk.Screen.get_default()
    window = screen.get_active_window()
    window.iconify()
    window.process_all_updates()

def window_move(viewport):

    # 1. grab window object
    # 2. jump viewport 0 0 so we can move only
    #    in positive plane
    # 3. move the window.
    # 4. set viewport back to what it was

    # Step 1
    screen = Gdk.Screen.get_default()
    screen_size=[ screen.get_width(),screen.get_height()]
    window = screen.get_active_window()

    viewports = enumerate_viewports()
    current = get_current_viewport()
    current_num = viewports[current]
    destination = [ 
                   key for  key,val in viewports.items() 
                   if val == int(viewport)
                   ][0]
    # Step 2.
    run_cmd([
            'xdotool',
            'set_desktop_viewport',
            '0','0'
            ]) 
    # Step 3.
    window.move(destination[0],destination[1])
    window.process_all_updates()

    run_cmd([
            'xdotool',
            'set_desktop_viewport',
            str(current[0]),
            str(current[1])
            ]) 

def move_right():
    sc = Gdk.Screen.get_default()
    width = sc.get_width()
    win = sc.get_active_window()
    pos = win.get_origin()
    win.move(width,pos.y)
    win.process_all_updates()

def move_down():
    sc = Gdk.Screen.get_default()
    height = sc.get_height()
    win = sc.get_active_window()
    pos = win.get_origin()
    win.move(pos.x,height)
    win.process_all_updates()

def new_tab():
    run_cmd(['xdotool','key','ctrl+shift+t'])

def parse_args():
    """ Parse command line arguments"""

    info="""Copyright 2016. Sergiy Kolodyazhnyy.

    Window control for terminal emulators. Originally written
    for gnome-terminal under Ubuntu with Unity desktop but can 
    be used with any other terminal emulator that conforms to 
    gnome-terminal keybindings. It can potentially be used for 
    controlling other windows as well via binding this script
    to a keyboard shortcut.

    Note that --viewport and --tab options require xdotool to be
    installed on the system. If you don't have it installed, you 
    can still use the other options. xdotool can be installed via
    sudo apt-get install xdotool.
    """
    arg_parser = argparse.ArgumentParser(
                 description=info,
                 formatter_class=argparse.RawTextHelpFormatter)
    arg_parser.add_argument(
                '-w','--window', action='store_true',
                help='spawns new window',
                required=False)
    arg_parser.add_argument(
                '-t','--tab',action='store_true',
                help='spawns new tab',
                required=False)
    arg_parser.add_argument(
                '-m','--minimize',action='store_true',
                help='minimizes current window',
                required=False)
    arg_parser.add_argument(
                '-M','--maximize',action='store_true',
                help='maximizes window',
                required=False)
    arg_parser.add_argument(
                '-u','--unmaximize',action='store_true',
                help='unmaximizes window',
                required=False)
    arg_parser.add_argument(
               '-v','--viewport',action='store',
               type=int, help='send window to workspace number',
               required=False)
    arg_parser.add_argument(
               '-r','--right',action='store_true',
               help='send window to workspace right',
               required=False)
    arg_parser.add_argument(
               '-d','--down',action='store_true',
               help='send window to workspace down',
               required=False)
    return arg_parser.parse_args()
    
def main():

    args = parse_args()

    if args.window:
       new_window()
    if args.tab:
       new_tab()
    if args.down:
       move_down()
    if args.right:
       move_right()       
    if args.viewport:
       window_move(args.viewport)
    if args.minimize:
       minimize()
    if args.maximize:
       maximize()
    if args.unmaximize:
       unmaximize()

if __name__ == '__main__':
    main()
