#!/usr/bin/env python
"""
Author: Serg Kolo <1047481448@qq.com>
Date:   Nov 3rd , 2016
Purpose:Brightness control depending on
        presence of ac adapter
Written for: http://askubuntu.com/q/844193/295286 
"""
import argparse
import dbus
import time
import sys

def get_dbus_property(bus_type, obj, path, iface, prop):
    """ utility:reads properties defined on specific dbus interface"""
    if bus_type == "session":
        bus = dbus.SessionBus()
    if bus_type == "system":
        bus = dbus.SystemBus()
    proxy = bus.get_object(obj, path)
    aux = 'org.freedesktop.DBus.Properties'
    props_iface = dbus.Interface(proxy, aux)
    props = props_iface.Get(iface, prop)
    return props

def get_dbus_method(bus_type, obj, path, interface, method, arg):
    """ utility: executes dbus method on specific interface"""
    if bus_type == "session":
        bus = dbus.SessionBus()
    if bus_type == "system":
        bus = dbus.SystemBus()
    proxy = bus.get_object(obj, path)
    method = proxy.get_dbus_method(method, interface)
    if arg:
        return method(arg)
    else:
        return method()

def on_ac_power():
    adapter = get_adapter_path()
    call = ['system','org.freedesktop.UPower',adapter,
            'org.freedesktop.UPower.Device','Online'
    ]
 
    if get_dbus_property(*call): return True

def get_adapter_path():
    """ Finds dbus path of the ac adapter device """
    call = ['system', 'org.freedesktop.UPower',
            '/org/freedesktop/UPower','org.freedesktop.UPower',
            'EnumerateDevices',None
    ]
    devices = get_dbus_method(*call)
    for dev in devices:
        call = ['system','org.freedesktop.UPower',dev,
                'org.freedesktop.UPower.Device','Type'
        ]
        if get_dbus_property(*call) == 1:
            return dev

def set_brightness(*args):
    call = ['session','org.gnome.SettingsDaemon.Power', '/org/gnome/SettingsDaemon/Power', 
            'org.gnome.SettingsDaemon.Power.Screen', 'SetPercentage', args[-1]
    ]
    get_dbus_method(*call)

def parse_args():
    info = """
    Simple brightness control for laptops,
    depending on presense of AC power supply
    """
    arg_parser = argparse.ArgumentParser(
                 description=info,
                 formatter_class=argparse.RawTextHelpFormatter)
    arg_parser.add_argument(
               '-a','--adapter',action='store',
               type=int, help='brightness on ac',
               default=100,
               required=False)

    arg_parser.add_argument(
               '-b','--battery',action='store',
               type=int, help='brightness on battery',
               default=10,
               required=False)
    return arg_parser.parse_args()

def main():
    args = parse_args()

    while True:
        if on_ac_power():
            set_brightness(args.adapter)
            while on_ac_power():
                time.sleep(1)
        else:
            set_brightness(args.battery)
            while not on_ac_power():
                time.sleep(1)

if __name__ == "__main__": main()
