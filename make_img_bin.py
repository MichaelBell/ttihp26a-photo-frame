#!/usr/bin/env python3

import sys
import struct
from PIL import Image

if len(sys.argv) < 5:
    print("make_img_bin.py <input.png> <output.bin> width height")
    sys.exit(1)

img = Image.open(sys.argv[1])
out_file = open(sys.argv[2], "wb")

width = int(sys.argv[3])
height = int(sys.argv[4])

data = img.resize((width, height)).load()

def cpt_to_val3(cpt):
    val = 0
    for threshold in (18, 55, 91, 127, 164, 200, 236):
        if cpt <= threshold: return val
        val += 1
    return val

def cpt_to_val2(cpt):
    if cpt <= 42: return 0
    if cpt <= 127: return 1
    if cpt <= 212: return 2
    return 3

for y in range(height):
    for x in range(width):
        colour = data[x, y]
        packed = ((cpt_to_val3(colour[0]) << 5) & 0xE0) | ((cpt_to_val3(colour[1]) << 2) & 0x1C) | cpt_to_val2(colour[2])
        out_file.write(struct.pack('<B', packed))
