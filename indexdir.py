#!/usr/bin/env python3
# Author: Serg Kolo
# Date: November 19, 2016
# Written for: http://askubuntu.com/q/842038/295286
from gi.repository import Gtk
from gi.repository import Gio
from gi.repository import GLib
import urllib.parse
import signal
import time
import sys
import os

class Indexer(object):
    def __init__(self):
        self.callback()

    def callback(self,*args):
         self.indexdir(sys.argv[1:])
         time.sleep(3)
         GLib.idle_add(Gtk.main_quit)

    def get_file_uri(self,*args):
        file = Gio.File.new_for_path(args[-1])
        if not file.query_exists(): return None
        return file.get_uri()

    def indexdir(self,*args):
        mgr = Gtk.RecentManager().get_default()
        recent = [i.get_uri() for i in mgr.get_items()]
        for dir in args[-1]:
            full_path = os.path.realpath(dir)
            for file in os.listdir(full_path):
                file_path = os.path.join(full_path,file)
                file_uri = self.get_file_uri(file_path)
                if not file_uri: continue
                if file_uri in recent: continue
                print('>>> adding: ',file_uri)
                mgr.add_item(file_uri)

    def run(self,*args):
        Gtk.main()     

def quit(signum,frame):
    Gtk.main_quit()
    sys.exit()

def main():

    while True:
        signal.signal(signal.SIGINT,quit)
        indexer = Indexer()
        indexer.run()

if __name__ == '__main__': main()
