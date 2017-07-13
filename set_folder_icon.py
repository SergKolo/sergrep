#!/usr/bin/env python3
"""
Author: Sergiy Kolodyazhnyy
Date: 7/12/2017
Purpose: Script to find github repository folders
         and set their icons for Ubuntu. 
Written for: https://askubuntu.com/q/935003/295286
"""
import argparse
import os
import sys
import subprocess
import urllib.parse

def puke(message,status_code):
    """ Print to stderr and exit with given code """
    sys.stderr.write(message + '\n')
    sys.exit(status_code)

def run_cmd(cmdlist):
    """ Reusable function for running external commands """
    try:
        stdout = subprocess.check_output(cmdlist)
    except subprocess.CalledProcessError as cpe:
        puke('Called command failed with '+cpe.returncode+' exit status\n'+repr(cpe),4) 
    else:
        if stdout:
            return stdout

def set_icon(directory,image):
    """ Wrapper function that specifies command and calls run_cmd()"""
    cmd=['gvfs-set-attribute','-t','string',
         directory,'metadata::custom-icon',image]
    return run_cmd(cmd)

def find_git_repositories(tree_root,icon):
  """ Does the job of recursive traversal of given directory tree,
      starting at the specified tree root directory. If condition for
      given subdirectory is met, calls set_icon() function"""
  for current_dir,subdirs,files in os.walk(tree_root):
      if '.git' in subdirs:
         print('Found',current_dir)
         set_icon(current_dir,icon)

def parse_args():
    """ Parses command-line arguments """
    arg_parser = argparse.ArgumentParser(
        description='Finds and sets github repository icons',
    )
    arg_parser.add_argument('-i','--icon',help='image to set,required',
                            type=str,required=True)
    arg_parser.add_argument('-r','--root',help='where search starts,default - current working directory',
                            default='.',type=str,required=False)
    return arg_parser.parse_args()

def main():
   """ Script entry point """
   # Parse command-line arguments and check their correctness
   args = parse_args()
   status_code={'icon_missing':1,'root_missing':2,'root_isnt_dir':3}

   if not os.path.exists(args.icon):
       puke('Icon pathname does not exist',status_code['icon_missing'])
   if not os.path.exists(args.root):
       puke('Root pathname does not exist',status_code['root_missing'])
   if not os.path.isdir(args.root):
       puke('Root pathname is not a directory',status_code['root_isnt_dir'])

   icon = 'file://'+urllib.parse.quote( os.path.abspath(args.icon) )

   # Now do the actual traversal
   find_git_repositories(args.root,icon)

if __name__ == '__main__': main()
