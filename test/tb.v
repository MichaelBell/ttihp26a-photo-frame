`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a FST file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
    #1;
  end

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  wire [7:0] ui_in;
  wire [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  reg cfg_clk, cfg_dat, display_en;
  reg qspi_pinout;
  reg qspi_half_clk;
  reg [1:0] qspi_latency;
  reg addr_hi;

  wire qspi_clk = qspi_pinout ? uio_out[1] : uio_out[3];
  wire qspi_cs = uio_out[0];
  wire [3:0] qspi_mosi = qspi_pinout ? uio_out[5:2] : {uio_out[5:4], uio_out[2:1]};
  wire [3:0] qspi_miso;

  reg [3:0] qspi_miso_in;
  reg [3:0] qspi_miso_buf [1:5];

  always @(posedge clk or negedge clk) begin
    qspi_miso_buf[1] <= qspi_miso_in;
  end
  genvar i;
  generate
  for (i = 1; i < 5; i = i + 1) begin
    always @(posedge clk or negedge clk) begin
      qspi_miso_buf[i+1] <= qspi_miso_buf[i];
    end

    wire [3:0] qspi_miso_peek = qspi_miso_buf[i];
  end
  endgenerate
  reg [2:0] latency;
  initial latency = 3'd1;

  assign qspi_miso = qspi_miso_buf[latency];

  assign uio_in = qspi_pinout ? {2'b00, qspi_miso[3:0], 2'b00} : {2'b00, qspi_miso[3:2], 1'b0, qspi_miso[1:0], 1'b0};

  assign ui_in = {addr_hi, qspi_latency, qspi_half_clk, qspi_pinout, display_en, cfg_dat, cfg_clk};

  wire [5:0] colour = {uo_out[0], uo_out[4], uo_out[1], uo_out[5], uo_out[2], uo_out[6]};
  wire hsync = uo_out[7];
  wire vsync = uo_out[3];

  // Replace tt_um_example with your module name:
  tt_um_MichaelBell_photo_frame user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

endmodule
