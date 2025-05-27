`timescale 1ns / 1ps
`default_nettype none
module Bridge_mux_wb2axi_top(
     input wire i_clk,
     input wire i_rst,
      // Wishbone signals for BRIDGE (WB2AXI side)
                 input wire [11:2] i_swb_adr,
                 input wire [31:0]   i_swb_dat,
                 input wire [3:0]    i_swb_sel,
                 input wire          i_swb_we,
                 input wire          i_swb_stb,
                 output wire [31:0]   o_swb_rdt,
                 output wire          o_swb_ack  
    );
   parameter AW=12;
   parameter IW=0; 
   parameter DATA_WIDTH = 32;
   parameter MEM_DEPTH  = 1 << (AW - 2);
   
   // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING       //in top
             wire[AW-1:2] o_mwb_adr;        
             wire [31:0] o_mwb_dat;
             wire [3:0] o_mwb_sel;
             wire o_mwb_we;
             wire o_mwb_stb;
       
             wire [31:0] i_mwb_rdt;
             wire i_mwb_ack;
   //AXI SIGNALS FOR BRIDGE            
                 wire [11:0] io_awaddr;          //total width=12+2+12+2+32+4+2+2+2+32+2+3 =107
                 wire io_awvalid;
                  wire io_awready;
                 //AXI adress read channel
                  wire [11:0] io_araddr;
                  wire io_arvalid;
                  wire io_arready;
                 //AXI write channel
                  wire [31:0] io_wdata;
                  wire [3:0] io_wstrb;
                  wire io_wvalid;
                  wire io_wready;
                 //AXI response channel
                  wire [1:0] io_bresp;
                  wire io_bvalid;
                 wire io_bready;
                 //AXI read channel
                  wire [31:0] io_rdata;
                  wire [1:0] io_rresp;
                  wire io_rlast;
                  wire io_rvalid;
                  wire io_rready ;               
       
  cmplt_bridge_withmux #(.AW(AW),
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
          .o_swb_ack(o_swb_ack) );
  
  //AXI IP CONNECGED WITH WB2AXI AXI SIGNALS
  axi_slave_ip #(
               .ADDR_WIDTH (AW),
               .DATA_WIDTH (DATA_WIDTH),
               .MEM_DEPTH(MEM_DEPTH))
               axi_ip_uut(
               .ACLK(i_clk),
               .RESET(i_rst),
           
               // AXI write address channel
               .AWADDR(io_awaddr),
               .AWVALID(io_awvalid),
               .AWREADY(io_awready),
           
               // AXI write data channel
               .WDATA(io_wdata),
               .WSTRB(io_wstrb),
               .WVALID(io_wvalid),
               .WREADY(io_wready),
           
               // AXI write response channel
               .BRESP(io_bresp),
               .BVALID(io_bvalid),
               .BREADY(io_bready),
           
               // AXI read address channel
               .ARADDR(io_araddr),
               .ARVALID(io_arvalid),
               .ARREADY(io_arready),
           
               // AXI read data channel
               .RDATA(io_rdata),
               .RRESP(io_rresp),
               .RVALID(io_rvalid),
               .RREADY(io_rready),
               .RLAST(io_rlast)
           );
wb_slave_dummy  wb_slave_uut(
                   .clk(i_clk), 
                   .rst(i_rst),
                   .adr_i(o_mwb_adr), 
                   .dat_i(o_mwb_dat), 
                   .sel_i(o_mwb_sel),
                   .we_i(o_mwb_we), 
                   .stb_i(o_mwb_stb), 
                   .dat_o(i_mwb_rdt), 
                   .ack_o(i_mwb_ack)
               );

    
endmodule
`default_nettype wire