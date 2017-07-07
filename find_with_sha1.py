#!/usr/bin/env python3
import os
import sys
from hashlib import sha1

def get_sha1sum(file_path):
    sha1sum = sha1()
    with open(file_path, 'rb') as fd:
        data_chunk = fd.read(1024)
        while data_chunk:
              sha1sum.update(data_chunk)
              data_chunk = fd.read(1024)
    return str(sha1sum.hexdigest())
            
def find_files(treeroot):
    for dir,subdirs,files in os.walk(treeroot):
         for f in files: 
             full_path = os.path.join(dir,f)
             path_sha1sum = get_sha1sum( full_path  )
             if path_sha1sum in sys.argv[1:]:
                 print(path_sha1sum,full_path)

def main():
    find_files('.')

if __name__ == '__main__': main()
