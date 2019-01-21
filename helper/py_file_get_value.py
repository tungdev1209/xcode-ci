# -*- coding: utf-8 -*-
# created by TungNQ

import json
import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--path", required=True, help="path to file")
ap.add_argument("-k", "--key", required=True, help="key for get value")
args = vars(ap.parse_args())

file_path = args["path"]
key = args["key"]

f = open(file_path, 'rt')
value = ''
for line in f:
    if key not in line:
        continue
    start_value = False
    content = line.strip()
    for word in content:
        if start_value:
            value += word
            continue
        if word == '=':
            start_value = True
    break
print value
