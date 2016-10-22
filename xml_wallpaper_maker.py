#!/usr/bin/env python3
# -*- coding: utf-8 -*- 

#
# Author: Serg Kolo , contact: 1047481448@qq.com
# Date: September 2 , 2016
# Purpose: A program that creates and launches XML slideshow
#      
# Tested on: Ubuntu 16.04 LTS
#
#
# Licensed under The MIT License (MIT).
# See included LICENSE file or the notice below.
#
# Copyright © 2016 Sergiy Kolodyazhnyy
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


from gi.repository import Gio
import xml.etree.cElementTree as ET
import lxml.etree as etree
import argparse
import sys
import os

def gsettings_set(schema, path, key, value):
    """Set value of gsettings schema"""
    if path is None:
        gsettings = Gio.Settings.new(schema)
    else:
        gsettings = Gio.Settings.new_with_path(schema, path)
    if isinstance(value,list ):
        return gsettings.set_strv(key, value)
    if isinstance(value,int):
        return gsettings.set_int(key, value)
    if isinstance(value,str):
        return gsettings.set_string(key,value)

def parse_args():
        """ Parses command-line arguments """
        arg_parser = argparse.ArgumentParser(
        description='Serg\'s XML slideshow creator',
        )

        arg_parser.add_argument(
                                '-d', '--directory',
                                help='Directory where images stored. Required',
                                type=str,
                                required=True
                                )

        arg_parser.add_argument(
                                '-t','--transition', 
                                type=float,
                                default=2.5,
                                help='transition time in seconds, default 2.5',
                                required=False
                                )


        arg_parser.add_argument(
                                '-l','--length', 
                                type=float,
                                default=1800.0,
                                help='Time length in seconds per image, default 1800',
                                required=False
                                )

        arg_parser.add_argument(
                                '-o','--overlay', 
                                action='store_true',
                                help='Enables use of overlay transition',
                                required=False
                                )

        arg_parser.add_argument(
                                '-s','--size', 
                                type=str,
                                help='wallpaper,zoom,centered,scaled,stretched,or spanned',
                                default='scaled',
                                required=False
                                )
        return arg_parser.parse_args()
        


def main():
    """ Program entry point"""
    args = parse_args()
    xml_file = os.path.join(os.path.expanduser('~'),'.local/share/slideshow.xml')
    path = os.path.abspath(args.directory)
    duration = args.length
    transition_time = args.transition

    if not os.path.isdir(path):
       print(path," is not a directory !")
       sys.exit(1)
    
    filepaths = [os.path.join(path,item) for item in os.listdir(path) ]
    images = [ img for img in filepaths if os.path.isfile(img)]
    filepaths = None
    images.sort()
    root = ET.Element("background")
    previous = None
    
    # Write the xml data of images and transitions
    for index,img in enumerate(images):
    
        if index == 0:
           previous = img
           continue
        
        image = ET.SubElement(root, "static")
        ET.SubElement(image,"duration").text = str(duration)
        ET.SubElement(image,"file").text = previous
  
        if args.overlay: 
            transition = ET.SubElement(root,"transition",type='overlay')
        else:
            transition = ET.SubElement(root,"transition")
        ET.SubElement(transition,"duration").text = str(transition_time)
        ET.SubElement(transition, "from").text = previous
        ET.SubElement(transition, "to").text = img
    
        previous = img
    
    # Write out the final image
    image = ET.SubElement(root, "static")
    ET.SubElement(image,"duration").text = str(duration)
    ET.SubElement(image,"file").text = previous
    
    # Write out the final xml data to file
    tree = ET.ElementTree(root)
    tree.write(xml_file)
    
    # pretty print the data
    data = etree.parse(xml_file)
    formated_xml = etree.tostring(data, pretty_print = True)
    with open(xml_file,'w') as f:
        f.write(formated_xml.decode())
    
    
    gsettings_set('org.gnome.desktop.background',None,'picture-options', args.size)
    gsettings_set('org.gnome.desktop.background',None,'picture-uri','file://' + xml_file)

if __name__ == '__main__':
    main()
