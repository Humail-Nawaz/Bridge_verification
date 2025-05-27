`timescale 1ns / 1ps

module WB2AXI_tb;

  // Inputs
  reg clk;
  reg rst;

  reg [11:2] i_swb_adr;
  reg [31:0] i_swb_dat;
  reg [3:0]  i_swb_sel;
  reg        i_swb_we;
  reg        i_swb_stb;

  // Outputs
  wire [31:0] o_swb_rdt;
  wire        o_swb_ack;


  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk; // 100MHz

  // Instantiate the top module
  WB2AXI_top uut (
    .clk(clk),
    .rst(rst),

    // Wishbone slave
    .i_swb_adr(i_swb_adr),
    .i_swb_dat(i_swb_dat),
    .i_swb_sel(i_swb_sel),
    .i_swb_we(i_swb_we),
    .i_swb_stb(i_swb_stb),
    .o_swb_rdt(o_swb_rdt),
    .o_swb_ack(o_swb_ack)
  );
  
reg [31:0] read_data;
  // Initial test sequence
  initial begin
    $display("==== Starting WB2AXI Testbench ====");
    rst = 1'b1;
    i_swb_adr = 10'h0;
    i_swb_dat = 32'b0;
    i_swb_sel = 4'b0;
    i_swb_we  = 1'b0;
    i_swb_stb = 1'b0;
    #50;
    rst = 0;
    #20;
    i_swb_adr = 10'h1;
    i_swb_dat = 32'hfadeface;
    i_swb_sel = 4'b1111;
    i_swb_we  = 1'b1;
    i_swb_stb = 1'b1;
    wait(o_swb_ack)
    i_swb_stb=1'b0;
    $display("DATA WRITTEN TO AXI=0x%08X",complete_bridge.o_wmdata);
    
    #10;
    rst=1;
    #20;
    rst=0;
        i_swb_adr = 10'h1;
       // i_swb_dat = 32'hfadeface;
        i_swb_sel = 4'b1111;
        i_swb_we  = 1'b0;
        i_swb_stb = 1'b1;
        wait(o_swb_ack)
        read_data = o_swb_rdt;
        i_swb_stb = 1'b0;
       
        $display("DATA READ FROM AXI=0x%08X",complete_bridge.o_swb_rdt);
    #100;
//    rst=1;
//    #10; rst=0;
//    #20;
    $display("==== Testbench Complete ====");
    $finish;
  end


endmodule
