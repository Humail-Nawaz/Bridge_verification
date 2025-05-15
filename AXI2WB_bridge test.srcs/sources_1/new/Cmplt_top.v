`timescale 1ns / 1ps
module Cmplt_top (
    input wire i_clk,
    input wire i_rst,
        // AXI signals for master ip(from ip to bridge)
    // AXI slave IP connections
            input  wire [11:0] i_awaddr,
            input wire i_awvalid,
            output wire o_awready,
            input wire [11:0] i_araddr,
            input wire i_arvalid,
            output wire o_arready,
            input wire [31:0] i_wdata,
            input wire [3:0] i_wstrb,
            input wire i_wvalid,
            output wire o_wready,
            output wire [1:0] o_bresp,
            output wire o_bvalid,
            input wire i_bready,
            output wire [31:0] o_rdata,
            output wire [1:0] o_rresp,
            output wire o_rlast,
            output wire o_rvalid,
            input wire i_rready,
    // SERVING TO BRIDGE SIGNALS
    input wire [11:2] i_swb_adr,
    input wire [31:0] i_swb_dat,
    input wire [3:0] i_swb_sel,
    input wire i_swb_we,
    input wire i_swb_stb,
    output wire [31:0] o_swb_rdt,
    output wire o_swb_ack
);

    // Parameters for address width
    localparam AW = 12;  // Adjust the address width as needed

    // Wire declarations for the bridge and slave connections
    wire [AW-1:2] o_mwb_adr;
    wire [31:0] o_mwb_dat;
    wire [3:0] o_mwb_sel;
    wire o_mwb_we;
    wire o_mwb_stb;
    wire [31:0] i_mwb_rdt;
    wire i_mwb_ack;

    // AXI signals for slave axi ip
        wire [11:0] o_awmaddr;
        wire o_awmvalid;
        wire i_awmready;
        wire [11:0] o_armaddr;
        wire o_armvalid;
        wire i_armready;
        wire [31:0] o_wmdata;
        wire [3:0] o_wmstrb;
        wire o_wmvalid;
        wire i_wmready;
        wire [1:0] i_bmresp;
        wire i_bmvalid;
        wire o_bmready;
        wire [31:0] i_rmdata;
        wire [1:0] i_rmresp;
        wire i_rmlast;
        wire i_rmvalid;
        wire o_rmready;


    // Instantiating the complete bridge
    complete_bridge #(
        .AW(AW)
    ) bridge_inst (
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

        // WB2AXI WISHBONE SIGNALS FROM SERVING TO BRIDGE
        .i_swb_adr(i_swb_adr),
        .i_swb_dat(i_swb_dat),
        .i_swb_sel(i_swb_sel),
        .i_swb_we(i_swb_we),
        .i_swb_stb(i_swb_stb),
        .o_swb_rdt(o_swb_rdt),
        .o_swb_ack(o_swb_ack),

        // AXI2WB AXI SIGNALS FROM EXTERNAL TO BRIDGE
        .i_awaddr(i_awaddr),
        .i_awvalid(i_awvalid),
        .o_awready(o_awready),
        .i_araddr(i_araddr),
        .i_arvalid(i_arvalid),
        .o_arready(o_arready),
        .i_wdata(i_wdata),
        .i_wstrb(i_wstrb),
        .i_wvalid(i_wvalid),
        .o_wready(o_wready),
        .o_bresp(o_bresp),
        .o_bvalid(o_bvalid),
        .i_bready(i_bready),
        .o_rdata(o_rdata),
        .o_rresp(o_rresp),
        .o_rlast(o_rlast),
        .o_rvalid(o_rvalid),
        .i_rready(i_rready),

        // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL
        .o_awmaddr(o_awmaddr),
        .o_awmvalid(o_awmvalid),
        .i_awmready(i_awmready),
        .o_armaddr(o_armaddr),
        .o_armvalid(o_armvalid),
        .i_armready(i_armready),
        .o_wmdata(o_wmdata),
        .o_wmstrb(o_wmstrb),
        .o_wmvalid(o_wmvalid),
        .i_wmready(i_wmready),
        .i_bmresp(i_bmresp),
        .i_bmvalid(i_bmvalid),
        .o_bmready(o_bmready),
        .i_rmdata(i_rmdata),
        .i_rmresp(i_rmresp),
        .i_rmlast(i_rmlast),
        .i_rmvalid(i_rmvalid),
        .o_rmready(o_rmready)
    );

    // Instantiating the AXI slave IP
    axi_slave_ip #(
        .ADDR_WIDTH(AW),
        .DATA_WIDTH(32)
    ) axi_slave_inst (
        .ACLK(i_clk),
        .RESET(i_rst),
        
        // AXI write address channel
        .AWADDR(o_awmaddr),
        .AWVALID(o_awmvalid),
        .AWREADY(i_awmready),

        // AXI write data channel
        .WDATA(o_wmdata),
        .WSTRB(o_wmstrb),
        .WVALID(o_wmvalid),
        .WREADY(i_wmready),

        // AXI write response channel
        .BRESP(i_bmresp),
        .BVALID(i_bmvalid),
        .BREADY(o_bmready),

        // AXI read address channel
        .ARADDR(o_armaddr),
        .ARVALID(o_armvalid),
        .ARREADY(i_armready),

        // AXI read data channel
        .RDATA(i_rmdata),
        .RRESP(i_rmresp),
        .RVALID(i_rmvalid),
        .RREADY(o_rmready),
        .RLAST(i_rmlast)
    );
    
       wb_slave_dummy uut(
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
