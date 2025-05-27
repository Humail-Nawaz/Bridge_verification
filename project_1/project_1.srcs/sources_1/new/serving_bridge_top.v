`timescale 1ns / 1ps

module serving_bridge_top #(parameter AW=12)
    (
     input wire clk,
     input wire rst,
     // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
        // AXI adress write channel
        input wire [AW-1:0] i_awaddr,
        input wire i_awvalid,
        output wire o_awready,
        //AXI adress read channel
        input wire [AW-1:0] i_araddr,
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
        output wire [AW-1:0] o_awmaddr,
        output wire o_awmvalid,
        input wire i_awmready,
        //AXI adress read channel
        output wire [AW-1:0] o_armaddr,
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
        output wire o_rmready
    );
 

// INITERNAL WISHBBONE WIRES FOR SERVING AN DBRIDGE CONNECTION
// FROM SERVING TO BRIDGE
          wire [AW-1:2] i_swb_adr;
          wire [31:0] i_swb_dat;
          wire [3:0] i_swb_sel;
          wire i_swb_we;
          wire i_swb_stb;
          wire [31:0] o_swb_rdt;
          wire o_swb_ack;
  
//FROM BRIDGE TO SERVING
           wire [AW-1:2] o_mwb_adr;
           wire [31:0] o_mwb_dat;
           wire  [3:0] o_mwb_sel;
           wire o_mwb_we;
           wire o_mwb_stb;
           wire [31:0] i_mwb_rdt;
           wire i_mwb_ack;
           
//sel lines
wire sel_radr;
wire sel_wadr;           //1 for ext and 0 for if
wire sel_wdata;
wire sel_rdata;
wire sel_wen ;     
           
 //SERVING INSTANTIATION
 serving   serving
      (
       .i_clk(clk),
       .i_rst(rst),
// input wire           i_timer_irq,
    
       .o_wb_adr(i_swb_adr),
       .o_wb_dat(i_swb_dat),
       .o_wb_sel(i_swb_sel),
       .o_wb_we(i_swb_we),
       .o_wb_stb(i_swb_stb),
       .i_wb_rdt(o_swb_rdt),
       .i_wb_ack(o_swb_ack),
       // WISHONE SIGNALS FROM BRIDGE TO SERVING
       .adr_brg(o_mwb_adr),
       .data_brg(o_mwb_dat),
       .wen_brg(o_mwb_we),
       .sel_brg(o_mwb_sel),
       .stb_brg(o_mwb_stb),
       .ack_brg(i_mwb_ack),
       .rdt_brg(i_mwb_rdt),
        // MUX SELECTION 
        .sel_radr(sel_radr),
        .sel_wadr(sel_wadr),           //1 for ext and 0 for if
        .sel_wdata(sel_wdata),
        .sel_rdata(sel_rdata),
        .sel_wen(sel_wen)
       );
 //BRIDGE INSTANTIATION      
       complete_bridge  
         #(.AW(AW))
         uut(
          .i_clk(clk),
          .i_rst(rst),
       
          // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING
          .o_mwb_adr(o_mwb_adr),
          .o_mwb_dat(o_mwb_dat),
          .o_mwb_sel(o_mwb_sel),
          .o_mwb_we(o_mwb_we),
          .o_mwb_stb(o_mwb_stb),
          .i_mwb_rdt(i_mwb_rdt),
          .i_mwb_ack(i_mwb_ack),
  
          //WB2AXI WISHBONE SIGNALS FROM SERVING TO BRIDGE
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
          .o_rmready(o_rmready),
          
            //sel lines
            .sel_radr(sel_radr),
            .sel_wadr(sel_wadr),           //1 for ext and 0 for if
            .sel_wdata(sel_wdata),
            .sel_rdata(sel_rdata),
            .sel_wen(sel_wen)
              );
endmodule
