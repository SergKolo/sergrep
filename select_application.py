#!/usr/bin/env python
#
###########################################################
# Author: Serg Kolo , contact: 1047481448@qq.com 
# Date: July 11, 2016 
# Purpose: Alternative "Open With" software for Nautilus
#          filemanager
# 
# Written for: http://askubuntu.com/q/797571/295286
# Tested on: Ubuntu 16.04 LTS
###########################################################
# Copyright: Serg Kolo , 2016
#    
#     Permission to use, copy, modify, and distribute this software is 
#     hereby granted without fee, provided that  the copyright notice 
#     above and this permission statement appear in all copies.
#
#     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
#     EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
#     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#     IN NO EVENT SHALL  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
#     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
#     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
#     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


import subprocess
import sys
import os
import getpass

def extract_command(desktop_file):
    # read .desktop file , return command it  runs
    command=""
    with open(desktop_file) as file:
        for line in file:
            if "Exec=" in line:
                for string in  line.split('Exec=')[1].split():
                    if "%" not in string:
                      command = command + string + " "
                break
    return  command

def set_as_default( mime , desk_file  ):
    # add the .desktop file to list of apps assigned to 
    # mime types in mimeapps.list file
    # TODO : find out if Nautilus automatically creates this file
    #        or do we need to ensure that it exists ?
    defaults_file = '/home/' + getpass.getuser() \
                    + '/.local/share/applications/mimeapps.list'
    temp_file = '/tmp/new_files'
    write_file = open(temp_file,'w')
    
    defaults_found = False
    mime_found = False
    with open(defaults_file) as read_file:
        for line in read_file:
            if '[Default Applications]' in line:
                defaults_found = True
            if defaults_found and mime in line:
                write_file.write( mime + '=' + desk_file + "\n" )
                mime_found = True
            else:
                write_file.write( line.strip() + "\n" )
    
        
    if not mime_found :
       write_file.write( mime_type + '=' + desktop_file + "\n" )
    
    write_file.close()
    os.rename(temp_file,defaults_file) 

#--------------

def main():
    
    # Open file dialog, let user choose program by its .desktop file
    try:
        filepath = subprocess.check_output([
                   'zenity', '--file-selection',
                   '--file-filter=' + '*.desktop',
                   '--filename=/usr/share/applications/' 
                    ] ).strip()
    except subprocess.CalledProcessError:
        sys.exit(1)

    
    # Get the program user wants to run
    program = extract_command(filepath)
    
    # Find out the mimetype of the file user wants opened
    mime_type = subprocess.check_output([
                          'file', '--mime-type', sys.argv[1] 
                          ]).strip().split(':')[1].strip()
    print mime_type
    
    # Extract just the .desktop filename itself
    desktop_file = filepath.split('/')[-1]
    
    # Check if user wants this program as default
    try:
        subprocess.check_call( [ 'zenity', '--question', '--title=""',
                      '--text="Would you like to set this app as' + \
                       ' default for this filetype?"'])
    
    except subprocess.CalledProcessError :
           	pass
    else:
         set_as_default( mime_type , desktop_file )
    
    # Finally, launch the program with file user chose
    # Can't use run_sh() because it expects stdout
    proc = subprocess.Popen( program + " " + sys.argv[1] , shell=True)
       
if __name__ == "__main__" :
    main()
