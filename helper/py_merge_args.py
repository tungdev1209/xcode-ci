# -*- coding: utf-8 -*-
# created by TungNQ

import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-a", "--arguments", required=True, help="arguments")
args = vars(ap.parse_args())

args_string = args["arguments"]
args_array = args_string.split(';')

keys_values = {}
is_new_key = False
current_key = ''
for arg in args_array:
    # print arg
    if is_new_key:
        if arg[0:1] == '-':
            keys_values[current_key] = ''
            is_new_key = True
            current_key = arg
        else:    
            keys_values[current_key] = arg
            is_new_key = False
            current_key = ''
        continue

    if arg[0:1] == '-':
        is_new_key = True
        current_key = arg
    elif arg != "":
        keys_values[arg] = ''

full_args = ''
for key in keys_values:
    full_args += key + ' '
    value = keys_values[key]
    if value != "":
        full_args += value + ' '
print full_args

        