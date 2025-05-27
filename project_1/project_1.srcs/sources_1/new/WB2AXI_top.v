`timescale 1ns / 1ps
`default_nettype none
module WB2AXI_top
           (input wire clk,
           input wire rst,
           // Wishbone master ? BRIDGE (AXI2WB side)
           output  wire [11:2] o_mwb_adr,
           output  wire [31:0]   o_mwb_dat,
           output      wire [3:0]    o_mwb_sel,
           output      wire          o_mwb_we,
           output      wire          o_mwb_stb,
           input      wire [31:0]   i_mwb_rdt,
           input     wire          i_mwb_ack,
               
                 // Wishbone signals for BRIDGE (WB2AXI side)
             input wire [11:2] i_swb_adr,
             input wire [31:0]   i_swb_dat,
             input wire [3:0]    i_swb_sel,
             input wire          i_swb_we,
             input wire          i_swb_stb,
             output wire [31:0]   o_swb_rdt,
             output wire          o_swb_ack
);
    
      // Parameters
      localparam AW = 12;
      localparam IW = 0;
    
      // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
         // AXI adress write channel
         wire [12-1:0] i_awaddr;
         wire i_awvalid;
         wire o_awready;
         //AXI adress read channel
         wire [12-1:0] i_araddr;
         wire i_arvalid;
         wire o_arready;
         //AXI write channel
         wire [31:0] i_wdata;
         wire [3:0] i_wstrb;
         wire i_wvalid;
         wire o_wready;
         //AXI response channel
         wire [1:0] o_bresp;
         wire o_bvalid;
         wire i_bready;
         //AXI read channel
         wire [31:0] o_rdata;
         wire [1:0] o_rresp;
         wire o_rlast;
         wire o_rvalid;
         wire i_rready;
         
         // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL(PERIPHERAL/ADAPTER/BUS)
         // AXI adress write channel
         wire [12-1:0] o_awmaddr;
         wire o_awmvalid;
         wire i_awmready;
         //AXI adress read channel
         wire [12-1:0] o_armaddr;
         wire o_armvalid;
         wire i_armready;
         //AXI write channel
         wire [31:0] o_wmdata;
         wire [3:0] o_wmstrb;
         wire o_wmvalid;
         wire i_wmready;
         //AXI response channel
         wire [1:0] i_bmresp;
         wire i_bmvalid;
         wire o_bmready;
         //AXI read channel
         wire[31:0] i_rmdata;
         wire [1:0] i_rmresp;
         wire i_rmlast;
         wire i_rmvalid;
         wire o_rmready;
      
    
      // === Instantiate Bridge ===
      complete_bridge #(.AW(AW)) bridge_inst (
        .i_clk(clk),
        .i_rst(rst),
    
        // AXI2WB (master WB interface)
        .o_mwb_adr(o_mwb_adr),
        .o_mwb_dat(o_mwb_dat),
        .o_mwb_sel(o_mwb_sel),
        .o_mwb_we(o_mwb_we),
        .o_mwb_stb(o_mwb_stb),
        .i_mwb_rdt(i_mwb_rdt),
        .i_mwb_ack(i_mwb_ack),
    
        // WB2AXI (slave WB interface)
        .i_swb_adr(i_swb_adr),
        .i_swb_dat(i_swb_dat),
        .i_swb_sel(i_swb_sel),
        .i_swb_we(i_swb_we),
        .i_swb_stb(i_swb_stb),
        .o_swb_rdt(o_swb_rdt),
        .o_swb_ack(o_swb_ack),
    
        // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
           // AXI adress write channel
           .i_awaddr(i_awaddr),
           .i_awvalid(i_awvalid),
           .o_awready(o_awready),
           //AXI adress read channel
           .i_araddr(i_araddr),
           .i_arvalid(i_arvalid),
           .o_arready(o_arready),
           //AXI write channel
           .i_wdata(i_wdata),
           .i_wstrb(i_wstrb),
           .i_wvalid(i_wvalid),
           .o_wready(o_wready),
           //AXI response channel
           .o_bresp(o_bresp),
           .o_bvalid(o_bvalid),
           .i_bready(i_bready),
           //AXI read channel
           .o_rdata(o_rdata),
           .o_rresp(o_rresp),
           .o_rlast(o_rlast),
           .o_rvalid(o_rvalid),
           .i_rready(i_rready),
           
           
           // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL(PERIPHERAL/ADAPTER/BUS)
           // AXI adress write channel
           .o_awmaddr(o_awmaddr),
           .o_awmvalid(o_awmvalid),
           .i_awmready(i_awmready),
           //AXI adress read channel
           .o_armaddr(o_armaddr),
           .o_armvalid(o_armvalid),
          .i_armready(i_armready),
           //AXI write channel
           .o_wmdata(o_wmdata),
           .o_wmstrb(o_wmstrb),
           .o_wmvalid(o_wmvalid),
           .i_wmready(i_wmready),
           //AXI response channel
           .i_bmresp(i_bmresp),
           .i_bmvalid(i_bmvalid),
           .o_bmready(o_bmready),
           //AXI read channel
           .i_rmdata(i_rmdata),
           .i_rmresp(i_rmresp),
           .i_rmlast(i_rmlast),
           .i_rmvalid(i_rmvalid),
           .o_rmready(o_rmready)
      );
    
    // === Instantiate AXI Slave IP ===
      axi_slave_ip #(
          .ADDR_WIDTH(12),  // 12-bit address from top
          .DATA_WIDTH(32)
      ) axi_slave_inst (
          .ACLK(clk),
          .RESET(rst),
  
          // Write address channel
          .AWADDR(o_awmaddr),
          .AWVALID(o_awmvalid),
          .AWREADY(i_awmready),
  
          // Write data channel
          .WDATA(o_wmdata),
          .WSTRB(o_wmstrb),
          .WVALID(o_wmvalid),
          .WREADY(i_wmready),
  
          // Write response channel
          .BRESP(i_bmresp),
          .BVALID(i_bmvalid),
          .BREADY(o_bmready),
  
          // Read address channel
          .ARADDR(o_armaddr),
          .ARVALID(o_armvalid),
          .ARREADY(i_armready),
  
          // Read data channel
          .RDATA(i_rmdata),
          .RRESP(i_rmresp),
          .RVALID(i_rmvalid),
          .RREADY(o_rmready),
          .RLAST(i_rmlast)
      );
assign {i_awaddr,i_awvalid,o_awready,
          i_araddr,i_arvalid,o_arready,
          i_wdata,i_wstrb,i_wvalid,o_wready,
          o_bresp, o_bvalid, i_bready,
          o_rdata, o_rresp,o_rlast,o_rvalid,i_rready}={107{1'b0}};

endmodule
`default_nettype wire
