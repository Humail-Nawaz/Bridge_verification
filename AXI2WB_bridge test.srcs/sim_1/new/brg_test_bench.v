`timescale 1ns / 1ps

module brg_test_bench;

  // Parameters
  parameter DW = 32;
  parameter AW = 32;

  // Clock and reset
  reg clk = 0;
  reg rst = 1;
  always #5 clk = ~clk;  // 100MHz

  // AXI signals (master side)
  reg [AW-1:0] io_awaddr;
  reg io_awvalid;
  wire io_awready;

  reg [DW-1:0] io_wdata;
  reg [3:0] io_wstrb;
  reg io_wvalid;
  wire io_wready;

  wire [1:0] io_bresp;
  wire io_bvalid;
  reg io_bready;

  reg [AW-1:0] io_araddr;
  reg io_arvalid;
  wire io_arready;

  wire [DW-1:0] io_rdata;
  wire [1:0] io_rresp;
  wire io_rlast;
  wire io_rvalid;
  reg io_rready;

  // Wishbone master ip sending signals to bridge
  wire [AW-1:0] o_swb_addr;
  wire o_swb_we;
  wire [DW-1:0] o_swb_wdt;
  wire [3:0] o_swb_sel;
  wire o_swb_cyc;
  wire o_swb_stb;
  reg [DW-1:0] o_swb_rdt = 32'hdeadbeef;
  reg o_swb_ack;

  // Wishbone slave ip sending signals to bridge
  reg [AW-1:0] i_mwb_addr;
  reg i_mwb_we;
  reg [DW-1:0] i_mwb_dat;
  reg [3:0] i_mwb_sel;
  reg i_mwb_cyc;
  reg i_mwb_stb;
  wire [DW-1:0] o_mwb_dat;
  wire o_mwb_ack;

  // Simulated responses from AXI slave (for WB2AXI path)
  reg [DW-1:0] i_rmdata = 32'h12345678;
  reg i_rmvalid = 0;
  reg [1:0] i_bmresp = 2'b00;
  reg i_bmvalid = 0;

  wire o_rmready;
  wire o_bmready;

  // Instantiate DUT
  BRIDGE_TOP dut (
    .i_clk(clk),
    .i_rst(rst),
    .io_awaddr(io_awaddr),
    .io_awvalid(io_awvalid),
    .io_awready(io_awready),
    .io_wdata(io_wdata),
    .io_wstrb(io_wstrb),
    .io_wvalid(io_wvalid),
    .io_wready(io_wready),
    .io_bresp(io_bresp),
    .io_bvalid(io_bvalid),
    .io_bready(io_bready),
    .io_araddr(io_araddr),
    .io_arvalid(io_arvalid),
    .io_arready(io_arready),
    .io_rdata(io_rdata),
    .io_rresp(io_rresp),
    .io_rlast(io_rlast),
    .io_rvalid(io_rvalid),
    .io_rready(io_rready),
 // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING
    .o_mwb_adr(i_mwb_adr),        
    .o_mwb_dat(i_mwb_dat),
    .o_mwb_sel(i_mwb_sel),
    .o_mwb_we(i_mwb_we),
    .o_mwb_stb(i_mwb_stb),
    .i_mwb_rdt(o_mwb_rdt),
    .i_mwb_ack(o_mwb_ack),             
    
   //WB2AXI WISHBONE SIGNALS FROM SERVING TO BRIDGE
   .i_swb_adr(o_swb_adr),   //done
   .i_swb_dat(o_swb_dat),     //done
   .i_swb_sel(o_swb_sel),
   .i_swb_we(o_swb_we),             //done
   .i_swb_stb(o_swb_stb),
   .o_swb_rdt(i_swb_rdt),     //done
   .o_swb_ack(i_swb_ack)
  );

  // AXI write transaction
  task axi_write(input [AW-1:0] addr, input [DW-1:0] data);
    begin
      @(posedge clk);
      io_awaddr <= addr;
      io_awvalid <= 1;
      io_wdata <= data;
      io_wstrb <= 4'b1111;
      io_wvalid <= 1;
      io_bready <= 1;

      wait (io_awready && io_wready);
      @(posedge clk);
      io_awvalid <= 0;
      io_wvalid <= 0;

      wait (io_bvalid);
      @(posedge clk);
      io_bready <= 0;
      $display("AXI Write Response: %b", io_bresp);
    end
  endtask

  // AXI read transaction
  task axi_read(input [AW-1:0] addr);
    begin
      @(posedge clk);
      io_araddr <= addr;
      io_arvalid <= 1;
      io_rready <= 1;

      wait (io_arready);
      @(posedge clk);
      io_arvalid <= 0;

      wait (io_rvalid);
      $display("AXI Read Data: %h", io_rdata);
      @(posedge clk);
      io_rready <= 0;
    end
  endtask

  // Simulation logic
  initial begin
    $dumpfile("bridge_top.vcd");
    $dumpvars(0, brg_test_bench);

    #20 rst = 0;

    // AXI write to WB slave
    axi_write(32'h0000_0004, 32'hcafef00d);

    // Respond as WB slave
    #10 o_swb_ack = 1;  // acknowledge WB write
    #10 o_swb_ack = 0;

    // AXI read from WB slave
    o_swb_rdt = 32'hbeefbeef;
    axi_read(32'h0000_0004);
    #10 o_swb_ack = 1;  // acknowledge WB read
    #10 o_swb_ack = 0;

    // Wishbone master to AXI slave (simulate WB2AXI)
    #50;
    i_mwb_addr = 32'h0000_0008;
    i_mwb_dat = 32'hfeedface;
    i_mwb_we = 1;
    i_mwb_cyc = 1;
    i_mwb_stb = 1;
    i_mwb_sel = 4'b1111;

    // AXI slave returns write response
    #20 i_bmvalid = 1;
    #10 i_bmvalid = 0;

    // Wishbone read from AXI slave
    #40;
    i_mwb_addr = 32'h0000_0010;
    i_mwb_we = 0;
    i_mwb_cyc = 1;
    i_mwb_stb = 1;

    #20 i_rmvalid = 1;
    i_rmdata = 32'habadcafe;
    #10 i_rmvalid = 0;
    i_mwb_cyc = 0;
    i_mwb_stb = 0;

    #100 $finish;
  end

endmodule
