/*
 * Copyright (c) 2026 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_MichaelBell_photo_frame (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // Bidirs are used for SPI interface
  wire [3:0] qspi_data_in = ui_in[3] ? uio_in[5:2] : {uio_in[5:4], uio_in[2:1]};
  wire [3:0] qspi_data_out;
  wire [3:0] qspi_data_oe;
  wire       qspi_clk_out;
  wire       qspi_flash_select;
  wire       qspi_ram_a_select = 1'b1;
  wire       pwm_audio = 1'b1;
  assign uio_out = ui_in[3] ?
                   {pwm_audio, qspi_ram_a_select, qspi_data_out[3:0], 
                    qspi_clk_out, qspi_flash_select} :
                   {pwm_audio, qspi_ram_a_select, qspi_data_out[3:2], 
                    qspi_clk_out, qspi_data_out[1:0], qspi_flash_select};
  assign uio_oe = rst_n ? (ui_in[3] ? 
                   {2'b11, qspi_data_oe[3:0], 2'b11} :
                   {2'b11, qspi_data_oe[3:2], 1'b1, qspi_data_oe[1:0], 1'b1}) : 8'h00;


  reg [23:0] addr_in;
  wire start_read;
  wire stop_read;
  wire [7:0] pixel_data;
  wire pixel_valid;

  wire [10:0] row;
  wire [10:0] col;
  wire row_pulse;
  wire frame_pulse;

  wire hsync;
  wire vsync;
  wire active;
  reg hsync_r;
  reg vsync_r;
  reg [1:0] R;
  reg [1:0] G;
  reg [1:0] B;

  qspi_dtr_flash_read i_qpsi (
    clk,
    rst_n,
    
    qspi_data_in,
    qspi_data_out,
    qspi_data_oe,
    qspi_flash_select,
    qspi_clk_out,

    ui_in[4],
    ui_in[6:5],

    addr_in,
    start_read,
    stop_read,
    pixel_data,
    pixel_valid
  );

  always @(posedge clk) begin
    if (!rst_n || frame_pulse) begin
      addr_in <= {ui_in[7], 23'b0};
    end else begin
      if (row_pulse && !row[0]) begin
        addr_in <= addr_in + {14'h0, col[10:1]} + 24'h1;
      end
    end
  end

  display i_display (
    clk,
    rst_n,
    
    ui_in[0],
    ui_in[1],
    ui_in[2],

    row,
    col,
    row_pulse,
    frame_pulse,

    hsync,
    vsync,
    active
  );

  always @(posedge clk) begin
    hsync_r <= hsync;
    vsync_r <= vsync;

    if (!active) begin
      R <= 0;
      G <= 0;
      B <= 0;
    end else begin
      if (pixel_valid) begin
        R <= pixel_data[2:1];
        G <= pixel_data[5:4];
        B <= pixel_data[7:6];
      end
    end
  end

  assign start_read = row_pulse;
  assign stop_read = col == 0;

  assign uo_out = {hsync_r, B[0], G[0], R[0], vsync_r, B[1], G[1], R[1]};

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in[7:6], uio_in[0], pixel_data[3], pixel_data[0], row, 1'b0};

endmodule
