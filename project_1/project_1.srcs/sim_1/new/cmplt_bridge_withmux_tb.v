`timescale 1ns / 1ps

module cmplt_bridge_withmux_tb;

  // Parameters
  localparam AW = 12;
  localparam DW = 32;

  // Testbench Signals
  reg i_clk;
  reg i_rst;

  reg  [AW-1:2] i_swb_adr;
  reg  [DW-1:0] i_swb_dat;
  reg  [3:0]    i_swb_sel;
  reg          i_swb_we;
  reg          i_swb_stb;
  wire [DW-1:0] o_swb_rdt;
  wire         o_swb_ack;

  // Instantiate the DUT
  Bridge_mux_wb2axi_top dut (
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_swb_adr(i_swb_adr),
    .i_swb_dat(i_swb_dat),
    .i_swb_sel(i_swb_sel),
    .i_swb_we(i_swb_we),
    .i_swb_stb(i_swb_stb),
    .o_swb_rdt(o_swb_rdt),
    .o_swb_ack(o_swb_ack)
  );

  // Clock Generation
  initial i_clk = 0;
  always #5 i_clk = ~i_clk;

  // Reset and Stimulus
  initial begin
    // Init inputs
    i_swb_adr = 10'h0;
    i_swb_dat = 32'b0;
    i_swb_sel = 4'b0;
    i_swb_we  = 1'b0;
    i_swb_stb = 1'b0;
    i_rst = 1;
    #20;
    i_rst = 0;
    //WB2AXI WRITE
    #10;
    $display("WB2AXI WRITE START");
     i_swb_stb = 1'b1;
     i_swb_adr = 10'h4;
     i_swb_dat = 32'hfaceface;
     i_swb_sel = 4'b1111;
     i_swb_we  = 1'b1;
     wait(o_swb_ack)
     $display("DATA WRITTEN TO AXI IP");
     i_swb_stb=0;
     i_swb_we=0;
     

    // Finish
    #20;
    $finish;
  end

endmodule
