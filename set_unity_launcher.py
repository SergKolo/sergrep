#!/usr/bin/env python
'''
@Author: Serg Kolo
Date: April 22, 2016
Purpose:  programmatically set Unity launcher items
        by reading a file. The file can have either
	full path to a .desktop file or just the file
	name itself
Written for: http://askubuntu.com/q/760895/295286
Tested on: Ubuntu 14.04 LTS
'''
import sys
import subprocess

command="""gsettings set com.canonical.Unity.Launcher favorites """ # schema to alter
def run_command(cmd):
    '''
    Runs a shell command passed as string argument
    '''
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
    output = p.stdout.read().strip()
    return output  


__items=""
with open(sys.argv[1]) as __file:
  for __line in __file:
      __temp = "'" + __line.strip().split('/')[-1] + "'"
      __items = ",".join([__items,__temp])

__items = '"[ ' + __items[1:] + ' ]"'

print run_command(command + " " + __items)
