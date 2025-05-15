`timescale 1ns / 1ps
module Top(input wire clk,
           input wire rst,
           // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
              // AXI adress write channel
              input wire [12-1:0] i_awaddr,
              input wire i_awvalid,
              output wire o_awready,
              //AXI adress read channel
              input wire [12-1:0] i_araddr,
              input wire i_arvalid,
              output wire o_arready,
              //AXI write channel
              input wire [31:0] i_wdata,
              input wire [3:0] i_wstrb,
              input wire i_wvalid,
              output wire o_wready,
              //AXI response channel
              output wire [1:0] o_bresp,
              output wire o_bvalid,
              input wire i_bready,
              //AXI read channel
              output wire [31:0] o_rdata,
              output wire [1:0] o_rresp,
              output wire o_rlast,
              output wire o_rvalid,
              input wire i_rready,
              
              
              // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL(PERIPHERAL/ADAPTER/BUS)
              // AXI adress write channel
              output wire [12-1:0] o_awmaddr,
              output wire o_awmvalid,
              input wire i_awmready,
              //AXI adress read channel
              output wire [12-1:0] o_armaddr,
              output wire o_armvalid,
              input wire i_armready,
              //AXI write channel
              output wire [31:0] o_wmdata,
              output wire [3:0] o_wmstrb,
              output wire o_wmvalid,
              input wire i_wmready,
              //AXI response channel
              input wire [1:0] i_bmresp,
              input wire i_bmvalid,
              output wire o_bmready,
              //AXI read channel
              input wire[31:0] i_rmdata,
              input wire [1:0] i_rmresp,
              input wire i_rmlast,
              input wire i_rmvalid,
              output wire o_rmready);
    
      // Parameters
      localparam AW = 12;
      localparam IW = 0;
    
      // Dummy AXI signals (these can be driven by a testbench if needed)
//      wire [AW-1:0] axi_awaddr;
//      wire         axi_awvalid, axi_awready;
//      wire [AW-1:0] axi_araddr;
//      wire         axi_arvalid, axi_arready;
//      wire [31:0]  axi_wdata;
//      wire [3:0]   axi_wstrb;
//      wire         axi_wvalid, axi_wready;
//      wire [1:0]   axi_bresp;
//      wire         axi_bvalid, axi_bready;
//      wire [31:0]  axi_rdata;
//      wire [1:0]   axi_rresp;
//      wire         axi_rlast;
//      wire         axi_rvalid, axi_rready;
    
      // Wishbone master ? BRIDGE (AXI2WB side)
      wire [AW-1:2] o_mwb_adr;
      wire [31:0]   o_mwb_dat;
      wire [3:0]    o_mwb_sel;
      wire          o_mwb_we;
      wire          o_mwb_stb;
      wire [31:0]   i_mwb_rdt;
      wire          i_mwb_ack;
    
      // Wishbone slave ? BRIDGE (WB2AXI side)
      wire [AW-1:2] i_swb_adr;
      wire [31:0]   i_swb_dat;
      wire [3:0]    i_swb_sel;
      wire          i_swb_we;
      wire          i_swb_stb;
      wire [31:0]   o_swb_rdt;
      wire          o_swb_ack;
    
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
    
//      // === Instantiate Dummy WB Master (writes/reads into AXI slave through bridge) ===
//      wb_dummy_master_ip master_inst (
//        .clk(clk),
//        .rst(rst),
//        .adr_o(i_swb_adr),
//        .dat_o(i_swb_dat),
//        .sel_o(i_swb_sel),
//        .we_o(i_swb_we),
//        .stb_o(i_swb_stb),
//        .dat_i(o_swb_rdt),
//        .ack_i(o_swb_ack)
//      );
    
      // === Instantiate Dummy WB Slave (AXI2WB target) ===
      wb_slave_dummy slave_inst (
        .clk(clk),
        .rst(rst),
        .adr_i({o_mwb_adr, 2'b00}),  // align 32-bit word address to byte address
        .dat_i(o_mwb_dat),
        .sel_i(o_mwb_sel),
        .we_i(o_mwb_we),
        .stb_i(o_mwb_stb),
        .dat_o(i_mwb_rdt),
        .ack_o(i_mwb_ack)
      );
//     // ====================
//       // AXI Dummy Master IP
//       // ====================
//       axi_dummy uut(
//         .clk(clk),
//         .rst(rst),
//         .awaddr(axi_awaddr),
//         .awvalid(axi_awvalid),
//         .awready(axi_awready),
//         .wdata(axi_wdata),
//         .wvalid(axi_wvalid),
//         .wready(axi_wready),
//         .bvalid(axi_bvalid),
//         .bready(axi_bready),
//         .araddr(axi_araddr),
//         .arvalid(axi_arvalid),
//         .arready(axi_arready),
//         .rdata(axi_rdata),
//         .rvalid(axi_rvalid),
//         .rready(axi_rready),
//         .wstrb(axi_strb),
//         .bresp(axi_bresp),
//         .rresp(axi_rresp),
//         .rlast(axi_rlast)
//       );


endmodule
