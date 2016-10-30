# !/usr/bin/env python
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com
# Date: July 16,2012
# Purpose: Simple indicator of Caps, Num, and Scroll Lock
#          keys for Ubuntu
#
# Written for: http://askubuntu.com/q/796985/295286
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


import gi
gi.require_version('AppIndicator3', '0.1')

from gi.repository import GLib as glib
from gi.repository import AppIndicator3 as appindicator
from gi.repository import Gtk as gtk

import subprocess
import signal


def quit(item=None):
    gtk.main_quit()


def run_cmd(cmdlist):
    # function for running
    try:
        stdout = subprocess.check_output(cmdlist, universal_newlines=True)
    except subprocess.CalledProcessError:
        stdout = ""
    return stdout


def key_status():
    label = ""
    status = []
    keys = {'3': 'C', '7': 'N', '11': 'S'}

    for line in run_cmd(['xset', 'q']).splitlines():
        if "Caps Lock:" in line:
            status = line.split()

    for index in (3, 7, 11):
        if status[index] == "on":
            label += " [" + keys[str(index)] + "] "
        else:
            label += keys[str(index)]

    return label


def update_label():
    app.set_label(key_status(), "")
    glib.timeout_add_seconds(1, update_label)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, lambda sig, frame: quit())
    app = appindicator.Indicator.new('LKS', '/usr/share/unity-greeter/cof.png',
                             appindicator.IndicatorCategory.APPLICATION_STATUS)
    app.set_status(appindicator.IndicatorStatus.ACTIVE)

    app_menu = gtk.Menu()
    quit_app = gtk.MenuItem('Quit')
    quit_app.connect('activate', quit)
    quit_app.show()
    app_menu.append(quit_app)

    app.set_menu(app_menu)

    update_label()

    gtk.main()
