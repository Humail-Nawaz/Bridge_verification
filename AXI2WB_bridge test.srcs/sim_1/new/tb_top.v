`timescale 1ns / 1ps

module tb_Top;

  // Clock and reset
  reg clk;
  reg rst;
 
  // AXI interface signals
  wire [11:0] axi_awaddr;
  wire        axi_awvalid;
  wire        axi_awready;
  wire [11:0] axi_araddr;
  wire        axi_arvalid;
  wire        axi_arready;
  wire [31:0] axi_wdata;
  wire [3:0]  axi_wstrb;
  wire        axi_wvalid;
  wire        axi_wready;
  wire [1:0]  axi_bresp;
  wire        axi_bvalid;
  wire        axi_bready;
  wire [31:0] axi_rdata;
  wire [1:0]  axi_rresp;
  wire        axi_rlast;
  wire        axi_rvalid;
  wire        axi_rready;
  wire sel;
  // Instantiate the DUT
  Top uut(
             .clk(clk),
             .rst(rst),
             // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
                // AXI adress write channel
                .i_awaddr(axi_awaddr),
                .i_awvalid(axi_awvalid),
                .o_awready(axi_awready),
                //AXI adress read channel
                .i_araddr(axi_araddr),
                .i_arvalid(axi_arvalid),
                .o_arready(axi_arready),
                //AXI write channel
                .i_wdata(axi_wdata),
                .i_wstrb(axi_wstrb),
                .i_wvalid(axi_wvalid),
                .o_wready(axi_wready),
                //AXI response channel
                .o_bresp(axi_bresp),
                .o_bvalid(axi_bvalid),
                .i_bready(axi_bready),
                //AXI read channel
                .o_rdata(axi_rdata),
                .o_rresp(axi_rresp),
                .o_rlast(axi_rlast),
                .o_rvalid(axi_rvalid),
                .i_rready(axi_rready)
                
                
//                // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL(PERIPHERAL/ADAPTER/BUS)
//                // AXI adress write channel
//                output wire [12-1:0] o_awmaddr,
//                output wire o_awmvalid,
//                input wire i_awmready,
//                //AXI adress read channel
//                output wire [12-1:0] o_armaddr,
//                output wire o_armvalid,
//                input wire i_armready,
//                //AXI write channel
//                output wire [31:0] o_wmdata,
//                output wire [3:0] o_wmstrb,
//                output wire o_wmvalid,
//                input wire i_wmready,
//                //AXI response channel
//                input wire [1:0] i_bmresp,
//                input wire i_bmvalid,
//                output wire o_bmready,
//                //AXI read channel
//                input wire[31:0] i_rmdata,
//                input wire [1:0] i_rmresp,
//                input wire i_rmlast,
//                input wire i_rmvalid,
//                output wire o_rmready);
                  );
  // Registers to drive AXI signals
  reg [11:0] awaddr_reg ;
  reg        awvalid_reg;
  reg [31:0] wdata_reg ;
  reg [3:0]  wstrb_reg ;
  reg        wvalid_reg;
  reg        bready_reg;

  reg [11:0] araddr_reg ;
  reg        arvalid_reg ;
  reg        rready_reg;

  // AXI driving assignments
  assign axi_awaddr  = awaddr_reg;
  assign axi_awvalid = awvalid_reg;
  assign axi_wdata   = wdata_reg;
  assign axi_wvalid  = wvalid_reg;
  assign axi_wstrb   = wstrb_reg;
  assign axi_bready  = bready_reg;
  assign sel = (awvalid_reg || arvalid_reg)?1'b1:1'b0;

  assign axi_araddr  = araddr_reg;
  assign axi_arvalid = arvalid_reg;
  assign axi_rready  = rready_reg;

  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;

  // Test sequence
  initial begin
  rst = 1;
  #20;
  rst = 0;
    $display("Starting AXI write and read test...");
    // -----------------------------
    // Write transaction to address 0x100
    // -----------------------------
    awvalid_reg = 1;
    wvalid_reg  = 1;
    bready_reg  = 1;
    awaddr_reg = 12'h100;
    wdata_reg = 32'hfadeface;
    wstrb_reg = 4'b1111;
    #10;
    wait (axi_awready && axi_wready);
    #20;
    awvalid_reg = 0;
    wvalid_reg  = 0;

    wait (axi_bvalid);
    if(axi_bresp==2'b00) begin
    $display("Data written without error");
    $display("Write response received: BRESP = %b", axi_bresp);
    $display("DATA written: WDATA = 0x%08X", axi_wdata); end
    else $display("Wrong data written");
    #100;

    // -----------------------------
    // Read transaction from address 0x100
    // -----------------------------
    rst =1'b1;
    #10;
    rst=1'b0;
    arvalid_reg = 1;
    araddr_reg=12'h100;
    rready_reg  = 1;
    #10;
    wait (axi_arready);
    #20;
    arvalid_reg = 0;
    wait(axi_rvalid)
    if(axi_rresp ==2'b00) begin
    $display("Data read correctly without error");
    $display("Read data received: RDATA = 0x%08X, RRESP = %b", axi_rdata, axi_rresp);
    end
    else $display("wrong data read");
    #10;

    $display("AXI write and read test complete.");
    $finish;
  end

endmodule
