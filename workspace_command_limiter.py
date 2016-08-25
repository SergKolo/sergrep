#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Author: Serg Kolo , contact: 1047481448@qq.com 
Date: August 24th, 2016
Purpose: Runs user-requested command only on specific workspaces
Tested on: Ubuntu 16.04 LTS , Unity desktop

The MIT License (MIT)

Copyright © 2016 Sergiy Kolodyazhnyy <1047481448@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
"""


# Just in case the user runs 
# the script with python 2, import
# print function
from __future__ import print_function
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import Gio,Gdk
from time import sleep
import subprocess
import argparse 
import os

"""Set debug=True to see errors and verbose output"""
debug=False

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
        if debug: print(">>> subprocess:",cmdlist)
        sys.exit(1)
    else:
        if stdout:
            return stdout

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


def parse_args():
    intro="""
    Runs user-defined command __upon__ entering user-defined set of
    workspaces. For instance 
    ./workspace_command_limiter.py -w 1,2,3 -c "python /home/user/some_script.py"
    This is intended to serve only as launcher for a command when user switches
    to their desired workspace, so consider carefully which command you want to use.
    NOTE: This script does run everything from shell, so you are here implicitly trusted
    not to use any command that may break your system. I'm not responsible for your 
    stupidity :) 
    """
    parser = argparse.ArgumentParser(description=intro)
    parser.add_argument(
           "-w","--workspaces",
           action='store',
           type=str, 
           help="coma-separated list(without spaces) of workspaces",
           required=True
           )
    
    parser.add_argument(
           "-c","--command",
           action='store',
           type=str, 
           help="quoted command to be spawned,when switch to workspace occurs",
           required=True
           )
    return parser.parse_args()


def main():
   """ Defines entry point of the program """
   args = parse_args()
   workspaces = [ int(wp) for wp in args.workspaces.split(',') ]
   if debug: print('User requested workspaces:',workspaces)
   pid = None
   proc = None

   while True:
       sleep(0.25)
       viewports_dict=enumerate_viewports()
       current_viewport = get_current_viewport()
       current_vp_number = viewports_dict[current_viewport]
       try:
           if current_vp_number in workspaces:
               if not pid:
                   proc = subprocess.Popen(args.command,shell=True)
                   pid = proc.pid
                   if debug: print('PID:',pid,'Spawned:',args.command)
           else:
               if pid:
                   if debug: print('killing pid:',pid)
                   proc.terminate()
                   proc = None
                   pid = None
       except:
             if debug: print("Unexpected error:", sys.exc_info()[0])
             if proc:
                proc.terminate()
           
if __name__ == '__main__':
    main()
