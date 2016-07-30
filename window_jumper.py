#!/usr/bin/env python
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import GdkX11, Gdk, Gtk


def main():

    DEBUG = False

    screen = GdkX11.X11Screen.get_default()
    monitors = []
    for monitor in range(screen.get_n_monitors()):
        monitors.append(
            [screen.get_monitor_geometry(monitor).x,
             screen.get_monitor_geometry(monitor).y])

    if DEBUG:
        print monitors

    active_window = screen.get_active_window()
    active_window_location = screen.get_monitor_at_window(active_window)

    new_location = None
    new_location = active_window_location + 1
    if active_window_location + 1 >= monitors.__len__():
        new_location = 0
    new_screen = monitors[new_location]
    if DEBUG:
        print new_screen

    active_window.move(new_screen[0], new_screen[1])
    screen.get_active_window()
    # TODO: add resizing window routine in cases where
    # a window is larger than the size of the screen
    # to which we're moving it.

if __name__ == "__main__":
    main()
