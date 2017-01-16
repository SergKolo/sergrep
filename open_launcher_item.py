#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Author: Serg Kolo , contact: 1047481448@qq.com
# Date: January 15th, 2017
# Purpose: opens applications on Unity launcher according to position
# Tested on: Ubuntu 16.04 LTS
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gio,Gtk
import sys,argparse

class ApplicationOpener(Gtk.Application):

    def __init__(self):
        Gtk.Application.__init__(self,flags=Gio.ApplicationFlags.HANDLES_COMMAND_LINE)
        self.args = None 
        self.schema = 'com.canonical.Unity.Launcher'
        self.key = 'favorites'

    def gsettings_get(self, schema, path, key):
        """Get value of gsettings schema"""
        if path is None:
            gsettings = Gio.Settings.new(schema)
        else:
            gsettings = Gio.Settings.new_with_path(schema, path)
        return gsettings.get_value(key)

    def get_launchers(self):
        return [ i.replace('application://',"")  
                 for i in self.gsettings_get(self.schema,None,self.key)
                     if i.startswith('application://')
        ]

    def do_activate(self):
        position = self.args.item
        launchers = self.get_launchers()

        if position > len(launchers):
            position = -1

        try:
            Gio.DesktopAppInfo.new(launchers[position]).launch_uris(None)
        except Exception as e:
            subprocess.call(['zenity','--error','OOPS! SOMETHING WENT WRONG:\n' + str(e)])
        return 0

    def do_command_line(self, args):
        parser = argparse.ArgumentParser()
        parser.add_argument('-i', '--item',
                            type=int,required=True,
                            help='position of app on the launcher')
        self.args = parser.parse_args(args.get_arguments()[1:])
        self.do_activate()
        return 0

def main():

    app = ApplicationOpener()
    exit_status = app.run(sys.argv)
    sys.exit(exit_status)

if __name__ == '__main__':
    main()
