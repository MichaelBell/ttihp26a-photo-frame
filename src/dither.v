/*
 * Copyright (c) 2026 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module dither_lookup (
    input wire [2:0] value,
    input wire [1:0] x,
    input wire [1:0] y,

    output reg [1:0] colour
);

    always @(*) begin
        case ({value, y, x})
0: colour = 2'd0;  // 0, 0, 0
1: colour = 2'd0;  // 0, 1, 0
2: colour = 2'd0;  // 0, 2, 0
3: colour = 2'd0;  // 0, 3, 0
4: colour = 2'd0;  // 0, 0, 1
5: colour = 2'd0;  // 0, 1, 1
6: colour = 2'd0;  // 0, 2, 1
7: colour = 2'd0;  // 0, 3, 1
8: colour = 2'd0;  // 0, 0, 2
9: colour = 2'd0;  // 0, 1, 2
10: colour = 2'd0;  // 0, 2, 2
11: colour = 2'd0;  // 0, 3, 2
12: colour = 2'd0;  // 0, 0, 3
13: colour = 2'd0;  // 0, 1, 3
14: colour = 2'd0;  // 0, 2, 3
15: colour = 2'd0;  // 0, 3, 3
16: colour = 2'd0;  // 4, 1, 0, 0
17: colour = 2'd0;  // 12, 1, 1, 0
18: colour = 2'd0;  // 6, 1, 2, 0
19: colour = 2'd0;  // 14, 1, 3, 0
20: colour = 2'd1;  // 16, 1, 0, 1
21: colour = 2'd0;  // 8, 1, 1, 1
22: colour = 2'd1;  // 18, 1, 2, 1
23: colour = 2'd0;  // 10, 1, 3, 1
24: colour = 2'd0;  // 7, 1, 0, 2
25: colour = 2'd0;  // 15, 1, 1, 2
26: colour = 2'd0;  // 5, 1, 2, 2
27: colour = 2'd0;  // 13, 1, 3, 2
28: colour = 2'd1;  // 19, 1, 0, 3
29: colour = 2'd0;  // 11, 1, 1, 3
30: colour = 2'd1;  // 17, 1, 2, 3
31: colour = 2'd0;  // 9, 1, 3, 3
32: colour = 2'd0;  // 12, 2, 0, 0
33: colour = 2'd1;  // 20, 2, 1, 0
34: colour = 2'd0;  // 14, 2, 2, 0
35: colour = 2'd1;  // 22, 2, 3, 0
36: colour = 2'd1;  // 24, 2, 0, 1
37: colour = 2'd1;  // 16, 2, 1, 1
38: colour = 2'd1;  // 26, 2, 2, 1
39: colour = 2'd1;  // 18, 2, 3, 1
40: colour = 2'd0;  // 15, 2, 0, 2
41: colour = 2'd1;  // 23, 2, 1, 2
42: colour = 2'd0;  // 13, 2, 2, 2
43: colour = 2'd1;  // 21, 2, 3, 2
44: colour = 2'd1;  // 27, 2, 0, 3
45: colour = 2'd1;  // 19, 2, 1, 3
46: colour = 2'd1;  // 25, 2, 2, 3
47: colour = 2'd1;  // 17, 2, 3, 3
48: colour = 2'd1;  // 20, 3, 0, 0
49: colour = 2'd1;  // 28, 3, 1, 0
50: colour = 2'd1;  // 22, 3, 2, 0
51: colour = 2'd1;  // 30, 3, 3, 0
52: colour = 2'd2;  // 32, 3, 0, 1
53: colour = 2'd1;  // 24, 3, 1, 1
54: colour = 2'd2;  // 34, 3, 2, 1
55: colour = 2'd1;  // 26, 3, 3, 1
56: colour = 2'd1;  // 23, 3, 0, 2
57: colour = 2'd1;  // 31, 3, 1, 2
58: colour = 2'd1;  // 21, 3, 2, 2
59: colour = 2'd1;  // 29, 3, 3, 2
60: colour = 2'd2;  // 35, 3, 0, 3
61: colour = 2'd1;  // 27, 3, 1, 3
62: colour = 2'd2;  // 33, 3, 2, 3
63: colour = 2'd1;  // 25, 3, 3, 3
64: colour = 2'd1;  // 28, 4, 0, 0
65: colour = 2'd2;  // 36, 4, 1, 0
66: colour = 2'd1;  // 30, 4, 2, 0
67: colour = 2'd2;  // 38, 4, 3, 0
68: colour = 2'd2;  // 40, 4, 0, 1
69: colour = 2'd2;  // 32, 4, 1, 1
70: colour = 2'd2;  // 42, 4, 2, 1
71: colour = 2'd2;  // 34, 4, 3, 1
72: colour = 2'd1;  // 31, 4, 0, 2
73: colour = 2'd2;  // 39, 4, 1, 2
74: colour = 2'd1;  // 29, 4, 2, 2
75: colour = 2'd2;  // 37, 4, 3, 2
76: colour = 2'd2;  // 43, 4, 0, 3
77: colour = 2'd2;  // 35, 4, 1, 3
78: colour = 2'd2;  // 41, 4, 2, 3
79: colour = 2'd2;  // 33, 4, 3, 3
80: colour = 2'd2;  // 36, 5, 0, 0
81: colour = 2'd2;  // 44, 5, 1, 0
82: colour = 2'd2;  // 38, 5, 2, 0
83: colour = 2'd2;  // 46, 5, 3, 0
84: colour = 2'd3;  // 48, 5, 0, 1
85: colour = 2'd2;  // 40, 5, 1, 1
86: colour = 2'd3;  // 50, 5, 2, 1
87: colour = 2'd2;  // 42, 5, 3, 1
88: colour = 2'd2;  // 39, 5, 0, 2
89: colour = 2'd2;  // 47, 5, 1, 2
90: colour = 2'd2;  // 37, 5, 2, 2
91: colour = 2'd2;  // 45, 5, 3, 2
92: colour = 2'd3;  // 51, 5, 0, 3
93: colour = 2'd2;  // 43, 5, 1, 3
94: colour = 2'd3;  // 49, 5, 2, 3
95: colour = 2'd2;  // 41, 5, 3, 3
96: colour = 2'd2;  // 44, 6, 0, 0
97: colour = 2'd3;  // 52, 6, 1, 0
98: colour = 2'd2;  // 46, 6, 2, 0
99: colour = 2'd3;  // 54, 6, 3, 0
100: colour = 2'd3;  // 56, 6, 0, 1
101: colour = 2'd3;  // 48, 6, 1, 1
102: colour = 2'd3;  // 58, 6, 2, 1
103: colour = 2'd3;  // 50, 6, 3, 1
104: colour = 2'd2;  // 47, 6, 0, 2
105: colour = 2'd3;  // 55, 6, 1, 2
106: colour = 2'd2;  // 45, 6, 2, 2
107: colour = 2'd3;  // 53, 6, 3, 2
108: colour = 2'd3;  // 59, 6, 0, 3
109: colour = 2'd3;  // 51, 6, 1, 3
110: colour = 2'd3;  // 57, 6, 2, 3
111: colour = 2'd3;  // 49, 6, 3, 3
112: colour = 2'd3;  // 7, 0, 0
113: colour = 2'd3;  // 7, 1, 0
114: colour = 2'd3;  // 7, 2, 0
115: colour = 2'd3;  // 7, 3, 0
116: colour = 2'd3;  // 7, 0, 1
117: colour = 2'd3;  // 7, 1, 1
118: colour = 2'd3;  // 7, 2, 1
119: colour = 2'd3;  // 7, 3, 1
120: colour = 2'd3;  // 7, 0, 2
121: colour = 2'd3;  // 7, 1, 2
122: colour = 2'd3;  // 7, 2, 2
123: colour = 2'd3;  // 7, 3, 2
124: colour = 2'd3;  // 7, 0, 3
125: colour = 2'd3;  // 7, 1, 3
126: colour = 2'd3;  // 7, 2, 3
127: colour = 2'd3;  // 7, 3, 3
        endcase
    end
endmodule
