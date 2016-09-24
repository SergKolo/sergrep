#!/usr/bin/env python3
# -*- coding: utf-8 -*-

#
# Author: Serg Kolo , contact: 1047481448@qq.com
# Date: Sept 24, 2016
# Purpose: command-line utility for controling the launcher
#          settings
# Tested on: Ubuntu 16.04 LTS
#
#
# Licensed under The MIT License (MIT).
# See included LICENSE file or the notice below.
#
# Copyright © 2016 Sergiy Kolodyazhnyy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

import gi
from gi.repository import Gio
import argparse
import sys

def gsettings_get(schema, path, key):
    """Get value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema, path)
    return gsettings.get_value(key)

def gsettings_set(schema, path, key, value):
    """Set value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema, path)
    if isinstance(value,list ):
        return gsettings.set_strv(key, value)
    if isinstance(value,int):
        return gsettings.set_int(key, value)

def puts_error(string):
    sys.stderr.write(string+"\n")
    sys.exit(1)

def list_items():
    """ lists all applications pinned to launcher """
    schema = 'com.canonical.Unity.Launcher'
    path = None
    key = 'favorites'
    items = list(gsettings_get(schema,path,key))
    for item in items:
        if 'application://' in item:
            print(item.replace("application://","").lstrip())

def append_item(item):
    """ appends specific item to launcher """
    schema = 'com.canonical.Unity.Launcher'
    path = None
    key = 'favorites'
    items = list(gsettings_get(schema,path,key))

    if not item.endswith(".desktop"):
        puts_error( ">>> Bad file.Must have .desktop extension!!!")

    items.append('application://' + item)
    gsettings_set(schema,path,key,items)

def remove_item(item):
    """ removes specific item from launcher """
    schema = 'com.canonical.Unity.Launcher'
    path = None
    key = 'favorites'
    items = list(gsettings_get(schema,path,key))

    if not item.endswith(".desktop"):
       puts_error(">>> Bad file. Must have .desktop extension!!!")
    items.pop(items.index('application://'+item))
    gsettings_set(schema,path,key,items)

def clear_all():
    """ clears the launcher completely """
    schema = 'com.canonical.Unity.Launcher'
    path = None
    key = 'favorites'

    gsettings_set(schema,path,key,[])

def parse_args():
    """parse command line arguments"""

    info="""Copyright 2016. Sergiy Kolodyazhnyy.
    This command line utility allows appending and removing items
    from Unity launcher, as well as listing and clearing the
    Launcher items.
 
    --file option is required for --append and --remove 
    """
    arg_parser = argparse.ArgumentParser(
                 description=info,
                 formatter_class=argparse.RawTextHelpFormatter)
    arg_parser.add_argument('-f','--file',action='store',
                            type=str,required=False)
    arg_parser.add_argument('-a','--append',
                            action='store_true',required=False)
    
    arg_parser.add_argument('-r','--remove',
                            action='store_true',required=False)
    arg_parser.add_argument('-l','--list',
                            action='store_true',required=False)

    arg_parser.add_argument('-c','--clear',
                            action='store_true',required=False)
    return arg_parser.parse_args()

def main():
    """ Defines program entry point """
    args = parse_args()
     
    if args.list:
       list_items()
       sys.exit(0)

    if args.append:
       if not args.file:
          puts_error(">>>Specify .desktop file with --file option")

       append_item(args.file)
       sys.exit(0)

    if args.remove:
       if not args.file:
          puts_error(">>>Specify .desktop file with --file option")

       remove_item(args.file)
       sys.exit(0)

    if args.clear:
       clear_all()
       sys.exit(0)

    sys.exit(0)

if __name__ == '__main__':
    main()
