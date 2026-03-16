/* Copyright 2026 (c) Michael Bell
   SPDX-License-Identifier: Apache-2.0
*/

module display (
    input clk,
    input rst_n,

    // Config
    input cfg_pulse, // The whole xx bit config is clocked in to the long config register while en is low
    input cfg_data,  // Then raising en starts the display with the configured params.
    input en,

    // VGA position
    output [10:0] row,  // Note these count down
    output [11:0] col,
    output row_pulse,   // A pulse a configured number of clocks before display start
    output frame_pulse, // A pulse at the end of every frame

    // VGA signals
    output hsync,
    output vsync,
    output active
);

    localparam CONFIG_LEN = 6 + 2 + 9 + 3*8 + 9 + 3*6;

    localparam STATE_DISPLAY = 0;
    localparam STATE_FRONT = 1;
    localparam STATE_SYNC = 2;
    localparam STATE_BACK = 3;

    reg [CONFIG_LEN-1:0] cfg;

    always @(posedge clk) begin
        if (cfg_pulse) begin
            // Rising edge of cfg_clk
            cfg <= {cfg[CONFIG_LEN-2:0], cfg_data};
        end
    end

    wire [5:0]  pulse_count = cfg[67:62];

    wire h_pol = cfg[61];
    wire v_pol = cfg[60];

    wire [11:0] h_display = {cfg[59:51], 3'b111};
    wire [9:0]  h_front   = {cfg[50:43], 2'b11};
    wire [9:0]  h_sync    = {cfg[42:35], 2'b11};
    wire [9:0]  h_back    = {cfg[34:27], 2'b11};

    wire [10:0] v_display = {cfg[26:18], 2'b11};
    wire [5:0]  v_bottom  = cfg[17:12];
    wire [5:0]  v_sync    = cfg[11:6];
    wire [5:0]  v_top     = cfg[5:0];

    reg [11:0] h_count;
    reg [10:0] v_count;

    reg [1:0] h_state;
    reg [1:0] v_state;

    always @(posedge clk) begin
        if (!rst_n || !en) begin
            h_count <= {2'b00, h_back};
            h_state <= STATE_BACK;
            v_count <= {5'b00, v_top};
            v_state <= STATE_BACK;
        end else begin
            h_count <= h_count - 1;

            if (h_count == 0) begin
                h_state <= h_state + 1;
                case (h_state)
                    STATE_DISPLAY: h_count <= {2'b00, h_front};
                    STATE_FRONT: h_count <= {2'b00, h_sync};
                    STATE_SYNC: h_count <= {2'b00, h_back};
                    STATE_BACK: h_count <= h_display;
                endcase

                if (h_state == STATE_BACK) begin
                    v_count <= v_count - 1;

                    if (v_count == 0) begin
                        v_state <= v_state + 1;

                        case (v_state)
                            STATE_DISPLAY: v_count <= {5'b00, v_bottom};
                            STATE_FRONT: v_count <= {5'b00, v_sync};
                            STATE_SYNC: v_count <= {5'b00, v_top};
                            STATE_BACK: v_count <= v_display;
                        endcase
                    end
                end
            end
        end
    end

    assign row_pulse = ((v_state == STATE_DISPLAY && v_count != 0) || (v_state == STATE_BACK && v_count == 0)) && h_count == {6'h0, pulse_count} && (h_state == STATE_BACK);
    assign frame_pulse = (v_state == STATE_SYNC && h_state == STATE_DISPLAY && v_count == 0 && h_count == 0);

    assign row = v_state == STATE_DISPLAY ? v_count : v_display;
    assign col = (h_state == STATE_DISPLAY && v_state == STATE_DISPLAY) ? h_count : h_display;

    assign hsync = en ? (h_state == STATE_SYNC) ^ h_pol : 1'b0;
    assign vsync = en ? (v_state == STATE_SYNC) ^ v_pol : 1'b0;
    assign active = en ? (h_state == STATE_DISPLAY) && (v_state == STATE_DISPLAY) : 1'b0;

endmodule
