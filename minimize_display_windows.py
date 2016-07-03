from gi.repository import GdkX11,Gdk
import subprocess
#print Gdk.Screen.get_default().get_active_window().get_xid()


def run_sh(cmd):
    # run shell commands
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    out = p.stdout.read().strip()
    return out 


user_selected = ""
for item in run_sh("xwininfo -int").split("\n"):
    if "Window id" in item:
       user_selected = item.split()[3]


screen =  Gdk.Screen.get_default()

for window in screen.get_window_stack():
    #if screen.get_monitor_at_window(window) == 0 :
    #print window.get_xid()
    if str(window.get_xid()) == user_selected:
       close_screen = int(screen.get_monitor_at_window(window))


for window in screen.get_window_stack():
    if screen.get_monitor_at_window(window) == close_screen :
       window.iconify()


# print Gdk.Screen.get_default().get_active_window().hide()
# that ^ hides active window, very interesting !!!

#print Gdk.Screen.get_display().get_window_stack()
