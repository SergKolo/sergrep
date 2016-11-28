#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk,Gdk
import subprocess
import psutil
import os

class  GreeterWindow(Gtk.Window):

    def __init__(self):
        Gtk.Window.__init__(self,title="Welcome")
        name = self.get_os_name()
        grid = Gtk.Grid()
        grid.set_border_width(25)
        self.add(grid)

        greeting = Gtk.Label("Welcome to "+name+"!\n\n")
        grid.add(greeting)

        sysinfo = [ str(i) for i in self.get_system_info()]
        fields =  ['Load Avg:','Memory %:','Swap %:',
                            '/ usage %:','Process count:','User count:'
        ]
        lines = [ fields[i] + " " + sysinfo[i] for i in range(len(sysinfo))]

        lines.append( '\nIP addresses:\n' + self.get_ip_addresses()  )
        lines.append('\n\n' + self.get_updates())

        label1 = Gtk.Label("\n".join(lines))

        grid.attach_next_to(label1,greeting,Gtk.PositionType.BOTTOM,1,2)
        #grid.add(label1)
        button = Gtk.Button(label="Got it !")
        button.connect("clicked", self.on_button_clicked)
        grid.attach_next_to(button,label1,Gtk.PositionType.BOTTOM,1,2)

    def get_updates(self,*args):
        cmd = "/usr/lib/update-notifier/apt-check --human-readable".split()
        return self.run_cmd(cmd).decode().strip()

    def on_button_clicked(self,*args):
        Gtk.main_quit()

    def get_ip_addresses(self,*args):
        cmd = ['ip','-o','addr','show']
        result = self.run_cmd(cmd)
        ipaddr = ipaddr_str = None
        
        if result:
            ipaddr = [ (i.split()[1],i.split()[3])
                       for i in result.decode().strip().split('\n')
                       
            ]
            ipaddr_str = "\n".join([str(i[0]) + " " + str(i[1])
                                    for i in ipaddr
            ])
        return ipaddr_str

    def get_os_name(self,*args):
        with open('/etc/os-release') as f:
             for line in f:
                 if line.startswith('PRETTY_NAME'):
                     return line.split('=')[1].replace('"','').strip()

    def run_cmd(self, cmdlist):
        """ utility: reusable function for running external commands """
        try:
            stdout = subprocess.check_output(cmdlist)
        except subprocess.CalledProcessError:
            pass
        else:
            if stdout:
                return stdout


    def get_system_info(self,*args):
        load = os.getloadavg()
        virtmem = psutil.virtual_memory().percent
        swapmem = psutil.swap_memory().percent
        disk_usage = psutil.disk_usage('/').percent
        num_procs = len(psutil.pids())
        user_count = len(set([ i.name for i in  psutil.users()]))
        return [load,virtmem,swapmem,
                disk_usage,num_procs,user_count
        ]


win = GreeterWindow()
win.connect("delete-event", Gtk.main_quit)
win.set_position(Gtk.WindowPosition.CENTER_ON_PARENT)
#win.override_background_color(Gtk.StateType.NORMAL, Gdk    .RGBA(225,225,0,1))
win.resize(350,350)
win.show_all()
Gtk.main()
