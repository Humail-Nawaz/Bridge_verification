`timescale 1ns / 1ps

module cmplt_bridge_mux_top(
     input wire i_clk,
     input wire i_rst,
      // Wishbone signals for BRIDGE (WB2AXI side)
                 input wire [11:2] i_swb_adr,
                 input wire [31:0]   i_swb_dat,
                 input wire [3:0]    i_swb_sel,
                 input wire          i_swb_we,
                 input wire          i_swb_stb,
                 output wire [31:0]   o_swb_rdt,
                 output wire          o_swb_ack,
      //AXI SIGNALS FOR BRIDGE            
                inout wire [11:0] io_awaddr,          //total width=12+2+12+2+32+4+2+2+2+32+2+3 =107
                inout wire io_awvalid,
                inout wire io_awready,
                //AXI adress read channel
                inout wire [11:0] io_araddr,
                inout wire io_arvalid,
                inout wire io_arready,
                //AXI write channel
                inout wire [31:0] io_wdata,
                inout wire [3:0] io_wstrb,
                inout wire io_wvalid,
                inout wire io_wready,
                //AXI response channel
                inout wire [1:0] io_bresp,
                inout wire io_bvalid,
                inout wire io_bready,
                //AXI read channel
                inout wire [31:0] io_rdata,
                inout wire [1:0] io_rresp,
                inout wire io_rlast,
                inout wire io_rvalid,
                inout wire io_rready   
    );
   parameter AW=12;
   parameter IW=0; 
   
   // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING       //in top
             wire[AW-1:2] o_mwb_adr;        
             wire [31:0] o_mwb_dat;
             wire [3:0] o_mwb_sel;
             wire o_mwb_we;
             wire o_mwb_stb;
       
             wire [31:0] i_mwb_rdt;
             wire i_mwb_ack;             
       
  BRIDGE_TOP #(.AW(AW),
               .IW(IW))
      uut
      (
       .i_clk(i_clk),
       .i_rst(i_rst),     
       
       // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING
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
          
          //AXI SIGNALS FOR BRIDGE
          // AXI adress write channel
              .io_awaddr  (io_awaddr),
           .io_awvalid (io_awvalid),
           .io_awready (io_awready),
          // AXI read address
           .io_araddr  (io_araddr),
           .io_arvalid (io_arvalid),
           .io_arready (io_arready),
          // Axi write data
           .io_wdata   (io_wdata),
           .io_wstrb   (io_wstrb),
           .io_wvalid  (io_wvalid),
           .io_wready  (io_wready),
          // AXI write response
           .io_bresp   (io_bresp),
           .io_bvalid  (io_bvalid),
           .io_bready  (io_bready),
          // AXI read data
           .io_rdata   (io_rdata),
           .io_rresp   (io_rresp),
           .io_rlast   (io_rlast),
           .io_rvalid  (io_rvalid),
           .io_rready  (io_rready) );
  axi_slave_ip #(
               parameter ADDR_WIDTH = 12,
               parameter DATA_WIDTH = 32,
               parameter MEM_DEPTH  = 1 << (ADDR_WIDTH - 2)
           )(
               input  wire                  ACLK,
               input  wire                  RESET,
           
               // AXI write address channel
               input  wire [ADDR_WIDTH-1:0] AWADDR,
               input  wire                  AWVALID,
               output reg                   AWREADY,
           
               // AXI write data channel
               input  wire [DATA_WIDTH-1:0] WDATA,
               input  wire [(DATA_WIDTH/8)-1:0] WSTRB,
               input  wire                  WVALID,
               output reg                   WREADY,
           
               // AXI write response channel
               output reg  [1:0]            BRESP,
               output reg                   BVALID,
               input  wire                  BREADY,
           
               // AXI read address channel
               input  wire [ADDR_WIDTH-1:0] ARADDR,
               input  wire                  ARVALID,
               output reg                   ARREADY,
           
               // AXI read data channel
               output reg  [DATA_WIDTH-1:0] RDATA,
               output reg  [1:0]            RRESP,
               output reg                   RVALID,
               input  wire                  RREADY,
               output reg                   RLAST
           );

    
endmodule
