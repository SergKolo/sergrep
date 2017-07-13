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


def puke(message, status_code):
    """ Print to stderr and exit with given code """
    sys.stderr.write('>>> OOOPS. Something is wrong:\n')
    sys.stderr.write(message + '\n')
    sys.exit(status_code)


def run_cmd(cmdlist):
    """ Reusable function for running external commands """
    try:
        stdout = subprocess.check_output(cmdlist)
    except subprocess.CalledProcessError as cpe:
        puke('Called command failed with ' + str(cpe.returncode) +
             ' exit status\n' + repr(cpe), 4)
    else:
        if stdout:
            return stdout


def set_icon(directory, icon_type, image):
    """ Wrapper function that specifies command and calls run_cmd()"""
    key = 'metadata::' + icon_type
    meta = {'metadata::custom-icon': 'string',
            'metadata::emblems': 'stringv'}

    # Because custom-icons and emblems type are mutually
    # exclusive, we need to unset custom-icon to enable emblems
    if icon_type == 'emblems':
        cmd = ['gvfs-set-attribute', '-t', 'unset',
               directory, 'metadata::custom-icon']
        run_cmd(cmd)

    cmd = ['gvfs-set-attribute', '-t', meta[key],
           directory, key, image]
    return run_cmd(cmd)


def unset_all(directory):
    for key in ['metadata::custom-icon', 'metadata::emblems']:
        run_cmd(['gvfs-set-attribute', '-t', 'unset', directory, key])


def find_directories(tree_root):
    """ Does the job of recursive traversal of given directory tree,
        starting at the specified tree root directory. If condition for
        given subdirectory is met, calls set_icon() function"""
    for current_dir, subdirs, files in os.walk(tree_root):
        # This check can be adapted to other cases
        if '.git' in subdirs:
            print('Found', current_dir)
            yield current_dir


def parse_args():
    """ Parses command-line arguments """

    text = ['Finds and sets github repository icons.',
            'Choose either --icon or --emblem. Without either'
            ' the script exists with 0 exit status.',
            'For --icons, use absolute or relative path.',
            'For --emblem use single string of text.',
            'Emblem pathnames are in the format',
            ' emblem-name.extension.', 'The script then can be',
            'called with -e <name>.Use ~/.local/share/icons folder',
            ' for custom emblems (if it does not ',
            'exist - create it. Store filenames in specified format']

    arg_parser = argparse.ArgumentParser(description="".join(text))
    arg_parser.add_argument('-i', '--icon', help='path to image to set',
                            type=str, required=False)
    arg_parser.add_argument('-e', '--emblem', help='single-string emblem name',
                            type=str, required=False)
    arg_parser.add_argument('-r', '--root', help='where search starts,' +
                            'default - current working directory',
                            default='.', type=str, required=False)
    arg_parser.add_argument('-u', '--unset', help='unset both emblem ' +
                            'and icon. Cannot be used with -e or -i options',
                            action='store_true', required=False)
    return arg_parser.parse_args()


def main():
    """ Script entry point """
    # Parse command-line arguments and check their correctness
    args = parse_args()
    status_code = {'icon_missing': 1, 'root_missing': 2,
                   'root_isnt_dir': 3, 'exclusion': 4,
                   'not_string': 5, 'conflict': 6}

    if args.unset and (args.icon or args.emblem):
        puke('Conflicting options', status_code['conflict'])
    if not args.unset:
        # both or none are given
        if not args.icon and not args.emblem:
            sys.exit(0)
        if args.icon and args.emblem:
            puke('Can only use either --icon or --emblem',
                 status_code['exclusion'])
        # Verify correctness of either one
        if args.icon and not os.path.exists(args.icon):
            puke('Icon pathname does not exist',
                 status_code['icon_missing'])
        if args.emblem:
            if '/' in args.emblem:
                puke('Emblem must be a single string of text,no paths',
                     status_code['not_string'])
            if not isinstance(args.emblem, str):
                puke('Given argument for emblem is not a string',
                     stats_code['not_string'])

        # Verify correctness of the path
        if not os.path.exists(args.root):
            puke('Root pathname does not exist',
                 status_code['root_missing'])
        if not os.path.isdir(args.root):
            puke('Root pathname is not a directory',
                 status_code['root_isnt_dir'])

    if args.unset:
        for directory in find_directories(args.root):
            print('Unsetting', directory)
            unset_all(directory)
        sys.exit(0)

    # Everything should be OK past this point

    if args.icon:
        meta_type = 'custom-icon'
        icon = 'file://' + urllib.parse.quote(os.path.abspath(args.icon))
    if args.emblem:
        meta_type = 'emblems'
        icon = args.emblem

    # Now do the actual traversal and icon-setting
    for directory in find_directories(args.root):
        set_icon(directory, meta_type, icon)

if __name__ == '__main__':
    main()
