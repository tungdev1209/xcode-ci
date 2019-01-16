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
process_keys = []

is_new_key = False
current_key = ''
for arg in args_array:
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
    elif '=' in arg and arg[0:1] != "\"" and arg[0:1] != "'":
        kv = arg.split('=')
        a_key = kv[0] + '='
        index = 0
        a_value = ''
        for v in kv:
            index += 1
            if index == 1:
                continue
            if index == 2:
                a_value += v
                continue
            a_value += '=' + v
        keys_values[a_key] = a_value
    elif arg != "":
        if arg == 'clean' or arg == 'build' or arg == 'test' or arg == 'archive':
            process_keys.append(arg)
        else:
            keys_values[arg] = ''

def applyKeyValues(kvs):
    args=''
    for key in kvs:
        args += key
        value = kvs[key]
        if key[-1:] == '=':
            args += value
        elif value != "":
            args += ' ' + value
        args += ' '
    return args

full_args = ''
full_args += applyKeyValues(keys_values)

if len(process_keys) > 0:
    if 'clean' in process_keys:
        full_args += ' clean'
    if 'build' in process_keys:
        full_args += ' build'
    if 'test' in process_keys:
        full_args += ' test'
    if 'archive' in process_keys:
        full_args += ' archive'

print full_args

        