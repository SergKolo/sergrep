#!/usr/bin/env python

import glib
import subprocess
import appindicator
import gtk

def quit(item):
        gtk.main_quit()

def run_cmd(cmdlist):
    # function for running 
    try:
        stdout = subprocess.check_output(cmdlist)
    except subprocess.CalledProcessError:
           pass
    else:
        if stdout:
            return  stdout

def key_status():
    status = []
    for line in run_cmd( ['xset','q'] ).split("\n") :
        if "Caps Lock:" in line:
            status = line.split()

    return status[3] + " " + status[7] + " " + status[11]

def update_label():
     app.set_label( key_status() )
     glib.timeout_add_seconds(1,set_app_label )

def set_app_label():
    update_label()
 
app = appindicator.Indicator('LKS', '/usr/share/unity-greeter/cof.png', appindicator.CATEGORY_APPLICATION_STATUS)
app.set_status( appindicator.STATUS_ACTIVE )

update_label()

app_menu = gtk.Menu()
quit_app = gtk.MenuItem( 'Quit' )
quit_app.connect('activate', quit)
quit_app.show()
app_menu.append(quit_app)

app.set_menu(app_menu)

gtk.main()
