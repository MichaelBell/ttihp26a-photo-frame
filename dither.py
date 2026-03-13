dither_matrix = [
    0, 8, 2, 10,
    12, 4, 14, 6,
    3, 11, 1, 9,
    15, 7, 13, 5
]

for col in range(8):
    for y in range(4):
        for x in range(4):
            if col == 0: print(f"{col*16 + y*4 + x}: colour = 2'd0;  // {col}, {x}, {y}")
            elif col == 7: print(f"{col*16 + y*4 + x}: colour = 2'd3;  // {col}, {x}, {y}")
            else:
                dither_val = 8 * col + dither_matrix[x + y*4] - 4
                int_val = int(dither_val / 16)
                print(f"{col*16 + y*4 + x}: colour = 2'd{int_val};  // {dither_val}, {col}, {x}, {y}")
