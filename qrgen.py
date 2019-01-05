# -*- coding: utf-8 -*-
# created by TungNQ

import qrcode
import argparse

ap = argparse.ArgumentParser()
ap.add_argument("-t", "--text", required=True, help="text for generate")
ap.add_argument("-n", "--name", required=False, help="name of qr image")
args = vars(ap.parse_args())

text = args['text']
name = args['name']

if name == "":
    name = "qr"

qr = qrcode.QRCode(
    version=5,
    error_correction=qrcode.constants.ERROR_CORRECT_L,
    box_size=10,
    border=4,
)
qr.add_data(text)
qr.make(fit=True)

img = qr.make_image(fill_color="black", back_color="white")
img.save(name + '.png')