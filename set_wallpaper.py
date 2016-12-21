#!/usr/bin/env python3
"""
Author: Serg Kolo , <1047481448@qq.com>
Date: December, 21,2016
Purpose: script for setting wallpaper, the pythonic way
Written for: http://askubuntu.com/q/66914/295286
"""
from gi.repository import Gio
import os,sys,random

def gsettings_set(schema, path, key, value):
    """Set value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema, path)
    if isinstance(value, list):
        return gsettings.set_strv(key, value)
    if isinstance(value, int):
        return gsettings.set_int(key, value)
    if isinstance(value,str): 
        return gsettings.set_string(key,value)

def error_and_exit(message):
    sys.stderr.write(message + "\n")
    sys.exit(1)

def main():
    gschema='org.gnome.desktop.background'
    key='picture-uri'
    if len(sys.argv) != 2:
        error_and_exit('>>> Path to a file is required')
    if not os.path.isfile(sys.argv[1]):
        error_and_exit('>>> Path "' + sys.argv[1] + \
                       '" isn\'t a file or file doesn\'t exit')
    full_path = os.path.abspath(sys.argv[1])
    uri = Gio.File.new_for_path(full_path).get_uri()
    gsettings_set(gschema,None,key,uri)
    

if __name__ == '__main__': main()
