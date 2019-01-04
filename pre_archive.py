import json
import argparse

# construct the argument parser and parse the arguments
ap = argparse.ArgumentParser()
ap.add_argument("-p", "--path", required=True, help="path to json")
ap.add_argument("-k", "--key", required=True, help="key need to parse")
args = vars(ap.parse_args())

json_path = args["path"]
key = args["key"]

with open(json_path) as f:
    data = json.load(f)

print ', '.join(data[key])