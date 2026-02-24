/* Copyright 2023-2026 (c) Michael Bell
   SPDX-License-Identifier: Apache-2.0

   Reads from a QSPI DTR flash, one byte every 2 clock cycles
   
   To start the data stream:
   - Set addr_in and set start_read high for 1 cycle
   - Wait for valid to pulse high
   - The next byte is available every time valid pulses high

   To stop the data stream, pulse stop_read high.

   Latency configures the number of clock cycles after the
   SPI clock pulse that data is read.  Valid values are 1-3.
   If use_neg_spi_clk is set, then the SPI clock is delayed by
   half a clock cycle, reducing the latency by 0.5 cycles.
   */

`default_nettype none

module qspi_dtr_flash_read #(parameter ADDR_BITS=24) (
    input clk,
    input rstn,

    // External SPI interface
    input  [3:0] spi_data_in,
    output [3:0] spi_data_out,
    output reg [3:0] spi_data_oe,
    output           spi_select,
    output           spi_clk_out,

    // Configuration
    input use_neg_spi_clk,
    input [1:0] latency,

    // Internal interface for reading data
    input [ADDR_BITS-1:0] addr_in,
    input                 start_read,
    input                 stop_read,
    output [7:0]          data_out,
    output reg            valid
);

    localparam BITS_REM_BITS = 3;

    localparam FSM_IDLE = 0;
    localparam FSM_CMD  = 1;
    localparam FSM_ADDR = 2;
    localparam FSM_DUMMY = 3;
    localparam FSM_DATA = 4;

    reg [2:0] fsm_state;
    reg [11:0] spi_miso_buf;
    reg [ADDR_BITS-1:0]       addr;
    reg [7:0] data;
    reg [BITS_REM_BITS-1:0] bits_remaining;
    reg spi_clk;
    reg spi_clk_n;

    assign data_out = data;

    always @(posedge clk) begin
        if (!rstn) begin
            fsm_state <= FSM_IDLE;
            bits_remaining <= 0;
            spi_data_oe <= 4'b0000;
            spi_clk <= 0;
        end else if (stop_read) begin
            fsm_state <= FSM_IDLE;
            bits_remaining <= 0;
            spi_data_oe <= 4'b0000;
            spi_clk <= 0;
        end else begin
            if (fsm_state == FSM_IDLE) begin
                if (start_read) begin
                    spi_data_oe <= 4'b0001;
                    fsm_state <= FSM_CMD;
                    bits_remaining <= 7;
                end
            end else begin
                spi_clk <= !spi_clk;
                if (bits_remaining == 0) begin
                    fsm_state <= fsm_state + 1;
                    if (fsm_state == FSM_CMD)        bits_remaining <= 6;
                    else if (fsm_state == FSM_ADDR)  bits_remaining <= 6;
                    else if (fsm_state == FSM_DUMMY) bits_remaining <= 1 + latency;
                    else if (fsm_state == FSM_DATA) begin
                        bits_remaining <= 1;
                        fsm_state <= FSM_DATA;
                    end

                    if (fsm_state == FSM_ADDR) spi_data_oe <= 4'b0000;
                end else begin
                    if (!fsm_state[0] || spi_clk) bits_remaining <= bits_remaining - 1;
                end
            end
        end
    end

    always @(posedge clk) begin
        if (fsm_state == FSM_IDLE && start_read) begin
            addr <= addr_in;
        end else if (fsm_state == FSM_ADDR) begin
            addr <= {addr[ADDR_BITS-5:0], 4'b0000};
        end
    end

    always @(posedge clk) begin
        spi_miso_buf <= {spi_miso_buf[7:0], spi_data_in};
    end

    reg [3:0] spi_miso_in;
    always @(*) begin
        if (latency == 2'b11) spi_miso_in = spi_miso_buf[11:8];
        else if (latency[1]) spi_miso_in = spi_miso_buf[7:4];
        else spi_miso_in = spi_miso_buf[3:0];
    end

    always @(posedge clk) begin
        if (fsm_state == FSM_DATA) begin
            data <= {data[3:0], spi_miso_in};
        end
    end

    assign spi_select = fsm_state == FSM_IDLE;

    always @(negedge clk) spi_clk_n <= spi_clk;
    assign spi_clk_out = use_neg_spi_clk ? spi_clk_n : spi_clk;

    wire [7:0] read_cmd = 8'hED;
    assign spi_data_out = fsm_state == FSM_CMD  ? {3'b000, read_cmd[bits_remaining[2:0]]} :
                          fsm_state == FSM_ADDR ? addr[ADDR_BITS-1:ADDR_BITS-4] :
                                                  4'b0000;
    always @(posedge clk) valid <= fsm_state == FSM_DATA && bits_remaining == 0;

endmodule
