#!/usr/bin/env python3
# Author: Serg Kolo
# Date: 10/21/2016
# Written for: http://askubuntu.com/q/759058/295286
from __future__ import print_function
import subprocess
import os

def run_cmd(cmdlist,workdir):
     """ utility: reusable function for 
         running external commands """
     new_env = dict(os.environ)
     new_env['LC_ALL'] = 'C'
     try:
         stdout = subprocess.check_output(
                    cmdlist, 
                    env=new_env,
                    cwd=workdir
         )
     except subprocess.CalledProcessError:
         pass
     else:
         if stdout:
             return stdout

def is_behind(cwd):
    """ simple wrapper for checking
        git status output
    """
    fetch = run_cmd(['git','fetch','origin','master'],cwd)
    status = run_cmd(['git','status'],cwd)
    if 'Your branch is behind' in status.decode():
        return True

def update(cwd):
    print('> previous commit:')
    print(run_cmd(['git','--no-pager','log','-1'],cwd).decode())
    print(run_cmd(['git','pull'],cwd).decode())
    print('> latest commit:')
    print(run_cmd(['git','--no-pager','log','-1'],cwd).decode())

def main():
    root_dir = os.path.join(os.path.expanduser('~'),'bin/')
    base_cmd = ['git','--no-pager']
    first_args = ['status']
    second_args = ['log','-1']
    third_args = ['pull']

    for root,dirs,files in os.walk(root_dir):
        for dir in dirs:
            top_dir = os.path.join(root,dir)
            git_dir = os.path.join(top_dir,'.git')
            if os.path.exists(git_dir):
                print('WORKING REPOSITORY:' + top_dir)
                if is_behind(top_dir):
                    print('repository is behind, will update')
                    update(top_dir)
                else:
                    print('not behind, skipped')
                print('-'*80)

if __name__ == '__main__': main()
