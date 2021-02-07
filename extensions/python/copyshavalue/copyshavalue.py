# -*- coding: utf-8 -*-
# created by TungNQ

import json
import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-ps", "--path_source", required=True, help="path to source file .rb")
ap.add_argument("-pd", "--path_destination", required=True, help="path to destination file .rb")
args = vars(ap.parse_args())

# get the arg values
source_path = args["path_source"]
des_path = args["path_destination"]

f_source = open(source_path, 'rt')
f_des = open(des_path, 'rt')

sha_value = ""
for line in f_source:
    text = line.strip()
    if text.find('sha256') != -1:
        start_value = False
        for c in text:
            if start_value:
                if c != '"':
                    sha_value += c
                    continue
                else:
                    break
            if c == '"':
                start_value = True
        break

old_sha_value = ""
content = ""
for line in f_des:
    text = line.strip()
    if text.find('sha256') != -1:
        start_value = False
        for c in text:
            if start_value:
                if c != '"':
                    old_sha_value += c
                    continue
                else:
                    break
            if c == '"':
                start_value = True
        # replace sha value
        print(f'current >> {old_sha_value}')
        print(f'new >> {sha_value}')
        line = line.replace(old_sha_value, sha_value)
    content += line

f_des.close()
f_source.close()

def run():
    f_des = open(des_path, 'w+')
    f_des.write(content)
    f_des.close()
