#!/usr/bin/env python

'''
 Author: Serg Kolo , contact: 1047481448@qq.com
 Date: July 3, 2016
 Purpose:  Minimize windows on a display which user clicks
 Written for: http://askubuntu.com/q/793195/295286
 Tested on: Ubuntu 16.04 LTS,Lubuntu 16.04 Virtual Machine

 Copyright: Serg Kolo , 2016

     Permission to use,copy,modify,and distribute this software is hereby granted
     without fee, provided that  the copyright notice above and this permission statement
     appear in all copies.

     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
     THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
     DEALINGS IN THE SOFTWARE.

     https://opensource.org/licenses/MIT
'''

from gi.repository import GdkX11, Gdk
import subprocess


def run_sh(cmd):
    '''
    reusable function to
    run shell commands
    Returns stdout of the
    process
    '''
    proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    out = proc.stdout.read().strip()
    return out


def _main():
    # First,let the user click on any window
    # on the monitor which they want to minimize.
    # For that we need to extract integer XID of
    # the window from xwininfo output.
    # Basically,same as xwininfo -int | awk '/Window id/{print $4}'

    user_selected = ""
    for item in run_sh("xwininfo -int").split("\n"):
        if "Window id" in item:
            user_selected = item.split()[3]

    # Here we basically get all the windows on the screen,
    # and check if their XID matches the one user selected
    # Once we find that window, we need to know to what display
    # that window belongs.
    screen = Gdk.Screen.get_default()
    for window in screen.get_window_stack():
        if str(window.get_xid()) == user_selected:
            close_screen = int(screen.get_monitor_at_window(window))

    # We know which display to close now. Loop over all
    # windows again, and if they're on the same display
    # the one that user chose - iconify it ( in X11 terminology
    # that means minimize the window  )
    for window in screen.get_window_stack():
        if screen.get_monitor_at_window(window) == close_screen:
            window.iconify()

if __name__ == '__main__':
    _main()
