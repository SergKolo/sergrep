#!/usr/bin/env python
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: August 1st , 2016
# Purpose: Disable Super key that calls Unity Dash, when any 
#          X11 window is in fullscreen state
# 
# Written for: http://askubuntu.com/q/805807/295286
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
from __future__ import print_function
import gi
gi.require_version('Gdk', '3.0')
from gi.repository import  Gdk,Gio
import subprocess
import signal
import time
import sys

debug = False

def gsettings_get(schema,path,key):
    """ fetches value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema,path)
    return gsettings.get_value(key)

def gsettings_set(schema,path,key,value):
    """ sets value of gsettings schema """
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema,path)
    return gsettings.set_string(key,value)


def gsettings_reset(schema,path,key):
    """ resets schema:key value to default"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema,path)
    return gsettings.reset(key)

def run_cmd(cmdlist):
    """ reusable function for running shell commands"""
    try:
        stdout = subprocess.check_output(cmdlist)
    except subprocess.CalledProcessError:
        pass
    else:
        if stdout:
            return stdout


def main():
    """ defines entry point of the program """
    screen = Gdk.Screen.get_default()
    while True:
        
        key_state = str(gsettings_get('org.compiz.unityshell', 
                                  '/org/compiz/profiles/unity/plugins/unityshell/', 
                                  'show-launcher'))
        active_xid = str(screen.get_active_window().get_xid())
        wm_state =  run_cmd( ['xprop', '-root', '-notype','-id',active_xid, '_NET_WM_STATE'])  
        
        if debug : print(key_state,wm_state)

        if 'FULLSCREEN' in wm_state:
            if "Super" in  key_state:    
                gsettings_set('org.compiz.unityshell', 
                              '/org/compiz/profiles/unity/plugins/unityshell/',
                              'show-launcher', 
                              'Disabled')
        
        else:
            if "Disabled" in key_state :
               gsettings_reset( 'org.compiz.unityshell', 
                                '/org/compiz/profiles/unity/plugins/unityshell/',
                                'show-launcher')
    
    
        time.sleep(0.25)


def sigterm_handler(*args):
    """ ensures that Super key has been reset upon exit"""
    gsettings_reset( 'org.compiz.unityshell', 
                     '/org/compiz/profiles/unity/plugins/unityshell/',
                     'show-launcher')
    if debug: print('CAUGHT SIGTERM')
    sys.exit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGTERM,sigterm_handler)
    main()
