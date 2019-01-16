# -*- coding: utf-8 -*-
# created by TungNQ

import json
import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-v", "--value", required=True, help="values need convert to json")
ap.add_argument("-p", "--path", required=True, help="path to json")
args = vars(ap.parse_args())

json_path = args["path"]
values = args["value"]
arr_values = values.split(';')

json_content = {}
json_content['build'] = {}
json_content['archive'] = {}
json_content['export'] = {}
json_content['test'] = {}
json_content['framework'] = {}

# set default value
json_content['build']['run'] = '1'
json_content['test']['run'] = '1'
json_content['archive']['run'] = '1'
json_content['export']['run'] = '1'

json_content['build']['args'] = ''
json_content['archive']['args'] = ''
json_content['export']['args'] = ''
json_content['test']['args'] = ''

json_content['framework']['universal'] = '1'
json_content['framework']['device'] = '1'
json_content['framework']['simulator'] = '1'
json_content['framework']['run'] = '0'

is_export_args = False
is_archive_args = False
is_build_args = False
is_test_args = False
is_choose_process = False
is_framework = False

for value in arr_values:
    if is_build_args:
        json_content['build']['args'] = value
        is_build_args = False
        continue
    if is_test_args:
        json_content['test']['args'] = value
        is_test_args = False
        continue
    elif is_archive_args:
        json_content['archive']['args'] = value
        is_archive_args = False
        continue
    elif is_export_args:
        json_content['export']['args'] = value
        is_export_args = False
        continue
    elif is_choose_process:
        processes = value.split('.')
        for process in processes:
            if process == 'b':
                json_content['build']['run'] = '1'
            if process == 't':
                json_content['test']['run'] = '1'
            elif process == 'a':
                json_content['archive']['run'] = '1'
            elif process == 'e':
                json_content['export']['run'] = '1'
        is_choose_process = False
        continue
    elif is_framework:
        libs = value.split('.')
        if len(libs) > 0:
            json_content['framework']['universal'] = '0'
            json_content['framework']['device'] = '0'
            json_content['framework']['simulator'] = '0'
        for lib in libs:
            if lib == 'u':
                json_content['framework']['universal'] = '1'
            elif lib == 'd':
                json_content['framework']['device'] = '1'
            elif lib == 's':
                json_content['framework']['simulator'] = '1'
        is_framework = False
        continue

    if value == '-b' or value == '--build':
        is_build_args = True
    elif value == '-t' or value == '--test':
        is_test_args = True
    elif value == '-a' or value == '--archive':
        is_archive_args = True
    elif value == '-e' or value == '--export':
        is_export_args = True
    elif value == '-r' or value =='--run':
        json_content['build']['run'] = '0'
        json_content['test']['run'] = '0'
        json_content['archive']['run'] = '0'
        json_content['export']['run'] = '0'
        is_choose_process = True
    elif value == '-fw' or value == '--framework':
        is_framework = True
        json_content['framework']['run'] = '1'

f = open(json_path, 'wt')
json.dump(json_content, f)
f.close()