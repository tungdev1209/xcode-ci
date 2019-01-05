import json
import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--path", required=True, help="path to json")
ap.add_argument("-k", "--key", required=True, help="key need to parse")
args = vars(ap.parse_args())

json_path = args["path"]
keys = args["key"].split('/')

f = open(json_path, 'rt')
data = json.load(f)
current_data = ""
for key in keys:
    if current_data == "":
        current_data = data[key]
    else:
        current_data = current_data[key]

# close the json file
f.close()

if isinstance(current_data, list):
    print ', '.join(current_data)
else:
    print current_data