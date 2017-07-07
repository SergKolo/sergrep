#!/usr/bin/env python3
# Script for automatically downloading and verifying sha256 hashsum
# of iso images provided by http://cdimage.ubuntu.com
import urllib.request
import sys
import os
from hashlib import sha256

def download_file(url):
    print(">>> Retrieving ",url)
    save_as = url.split('/')[-1]
    buffer_size=512
    try:
        with urllib.request.urlopen(url) as response, open(save_as,'wb') as out_file:
            print(response.info())
            print(">>> Writing data:")
            has_data=True
            retrieved = 0
            while has_data:
                 data = response.read(buffer_size)
                 retrieved += len(data)
                 # simple progress message which overwrites itself
                 message = "Retrieved "+str(retrieved)+" bytes"
                 print("\r"+" "*len(message)+"\r",end="")
                 print(message,end="")
                 sys.stdout.flush()
                 if data:
                     out_file.write(data)
                 else:
                    has_data=False
    except Exception as e:
        sys.stderr.write('\n>>> Something went wrong\n')
        sys.stderr.write(str(e))
    else:
        print('\n>>> URL retrieved successfully')
        return(save_as)

def get_sha256sum(file_path):
    sha256sum = sha256()
    with open(file_path, 'rb') as fd:
        data_chunk = fd.read(1024)
        while data_chunk:
              sha256sum.update(data_chunk)
              data_chunk = fd.read(1024)
    return str(sha256sum.hexdigest())

def compare_sha256sums(local_file,sha256sum,hashsum_file):
     remote_hashsum = ""
     with open(hashsum_file) as fd:
         for line in fd:
              words = line.strip().split()
              if words[1].replace('*','') == local_file:
                  remote_hashsum = words[0]
         if not remote_hashsum: 
              sys.stderr.write("\n>>> Error: local file not found in list of SHA256SUMS\n")
              sys.exit(1)
     if remote_hashsum == sha256sum:
         print("Local file ",local_file," with sha256 hashsum ",sha256sum,"matches with sha256sum in remote. All OK.")
                  

def main():
    saved_filename = download_file(sys.argv[1])
    sha256sum = get_sha256sum(saved_filename)
    sha256sums_file_url = "/".join( sys.argv[1].split('/')[:-1] + ['SHA256SUMS'] ) 
    sha256sum_file = download_file( sha256sums_file_url  ) 
    compare_sha256sums(saved_filename,sha256sum,sha256sum_file)

if __name__ == '__main__': main()
