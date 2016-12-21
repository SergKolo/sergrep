#!/usr/bin/env python3
"""
Author: Serg Kolo , <1047481448@qq.com>
Date: December, 21,2016
Purpose: Sets random wallpaper from a given directory
Written for: http://askubuntu.com/q/851705/295286
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

def select_random_uri(dir_path):

    selection = random.choice(os.listdir(dir_path))
    selection_path = os.path.join(dir_path,selection)
    while not os.path.isfile(selection_path):
        selection = random.choice(os.listdir(dir_path))
        selection_path = os.path.join(dir_path,selection)

    selection_uri = Gio.File.new_for_path(selection_path).get_uri()
    return selection_uri

def main():
    """ Program entry point"""
    if len(sys.argv) != 2:
       error_and_exit('>>> Script requires path to a directory as single argument')
    if not os.path.isdir(sys.argv[1]):
       error_and_exit('>>> Argument is not a directory')   
    img_dir = os.path.abspath(sys.argv[1])
    uri = select_random_uri(img_dir)
    try:
        gsettings_set('org.gnome.desktop.background',None,'picture-uri',uri)
    except Exception as ex:
       error_and_exit(ex.repr()) 

if __name__ == '__main__': main()
