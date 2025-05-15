`timescale 1ns / 1ps
////////////////////////////////////////////////////

module BRIDGE_TOP #(parameter AW = 12,
    parameter IW = 0)
  (
   input wire i_clk,
   input wire i_rst,
   
   
   // AXI2WB WISHBONE SIGNALS FROM BRIDGE TO SERVING
      output reg [AW-1:2] o_mwb_adr,        
      output reg [31:0] o_mwb_dat,
      output reg [3:0] o_mwb_sel,
      output reg o_mwb_we,
      output reg o_mwb_stb,

      input wire [31:0] i_mwb_rdt,
      input wire i_mwb_ack,             

      //WB2AXI WISHBONE SIGNALS FROM SERVING TO BRIDGE
      input wire [AW-1:2] i_swb_adr,   //done
      input wire [31:0] i_swb_dat,     //done
      input wire [3:0] i_swb_sel,
      input wire i_swb_we,             //done
      input wire i_swb_stb,

      output reg [31:0] o_swb_rdt,     //done
      output reg o_swb_ack,            //done
      
      //AXI SIGNALS FROM EXT TO BRIDGE
      // AXI adress write channel
   inout wire [AW-1:0] io_awaddr,          //total width=12+2+12+2+32+4+2+2+2+32+2+3 =107
   inout wire io_awvalid,
   inout wire io_awready,
   //AXI adress read channel
   inout wire [AW-1:0] io_araddr,
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
   inout wire io_rready );
   
   
   // AXI2WB AXI SIGNALS FROM BRIDGE TO EXTERNAL(PERIPHERAL/ADAPTER/BUS)
      // AXI adress write channel 
       reg [AW-1:0] o_awmaddr;   
       reg o_awmvalid;  
       wire i_awmready;   
      //AXI adress read channel   
       reg [AW-1:0] o_armaddr;   
       reg o_armvalid;   
       wire i_armready;   
      //AXI write channel   
       reg [31:0] o_wmdata;   
       reg [3:0] o_wmstrb;   
       reg o_wmvalid;   
       wire i_wmready;   
      //AXI response channel   
      wire [1:0] i_bmresp;   
      wire i_bmvalid;   
      reg o_bmready;   
      //AXI read channel   
      wire[31:0] i_rmdata;   
      wire [1:0] i_rmresp;   
      wire i_rmlast;   
      wire i_rmvalid;   
      reg o_rmready;   
      
   // AXI2WB AXI SIGNALS FROM EXTERNAL(BUS/PERIPHERAL/ADAPTER) TO BRIDGE
      // AXI adress write channel
      wire [AW-1:0] i_awsaddr;
      wire i_awsvalid;
      reg o_awsready;
      //AXI adress read channel
       wire [AW-1:0] i_arsaddr;
       wire i_arsvalid;
       reg o_arsready;
      //AXI write channel   
       wire [31:0] i_wsdata;   
       wire [3:0] i_wsstrb;   
       wire i_wsvalid;   
       reg o_wsready;             
      //AXI response channel             
       wire [1:0] o_bsresp;             
       reg o_bsvalid;            
       wire i_bsready;             
      //AXI read channel             
       reg [31:0] o_rsdata;             
       wire [1:0] o_rsresp;             
       wire o_rslast;             
       reg o_rsvalid;             
       wire i_rsready;
       
       localparam          bridge_idle=4'd0, 
                           AXI2WB_start=4'd1,     //AXI2WB BRIDGE STATES:START
                           AXI2WB_WBWACK= 4'd2,           
                           AXI2WB_AWACK=4'd3, 
                           AXI2WB_WBRACK = 4'd4 ,
                           AXI2WB_BAXI = 4'd5,
                           AXI2WB_RRAXI = 4'd6,     //AXI2WB BRIDGE STATES:END
                           WB2AXI_start=4'd7,       //WB2AXI BRIDGE STATES:START
                           WBREAD=4'd8, 
                           WBWRITE=4'd9, 
                           WB2AXI_WRESP= 4'd10,     //WB2AXI BRIDE STATES:END
                           WB2AXI_RRESP= 4'd11;       
       reg [3:0] state, next_state;         
       reg arbiter, sel;
                      
        assign o_bsresp = 2'b00;         
        assign o_rsresp = 2'b00;         
        assign o_rslast = 1'b1;         
                
       // present state sequential logic         
       always @(posedge i_clk)  begin         
           if(i_rst)          
               state <= bridge_idle;         
           else         
               state <= next_state;         
       end         
                
       //next state combinational logic         
       always @(*) begin         
           case(state)         
               bridge_idle: next_state <= (i_awsvalid || i_arsvalid)? AXI2WB_start:          
                                          (i_swb_stb)?WB2AXI_start:         
                                          bridge_idle;         
                        
               AXI2WB_start: next_state <= (i_awsvalid && arbiter) ? (i_wsvalid ? AXI2WB_WBWACK : AXI2WB_AWACK) :         
                                           (i_arsvalid) ? AXI2WB_WBRACK :         
                                            AXI2WB_start;         
               AXI2WB_AWACK: next_state <= (i_wsvalid)? AXI2WB_WBWACK :AXI2WB_AWACK;         
               AXI2WB_WBWACK: next_state <= (i_mwb_ack) ? AXI2WB_BAXI : AXI2WB_WBWACK;         
               AXI2WB_WBRACK: next_state <= (i_mwb_ack) ? AXI2WB_RRAXI : AXI2WB_WBRACK;         
               AXI2WB_BAXI: next_state <= (i_bsready) ? bridge_idle : AXI2WB_BAXI;         
               AXI2WB_RRAXI: next_state <= (i_rsready) ? bridge_idle : AXI2WB_RRAXI;         
                        
               WB2AXI_start: next_state <= (i_swb_stb) ?          
                                              (i_swb_we ?          
                                                (i_awmready ? WBWRITE : WB2AXI_start) :(i_armready ? WBREAD : WB2AXI_start)) :         
                                          WB2AXI_start;         
                
              WBWRITE: next_state <=(i_wmready)? WB2AXI_WRESP: WBWRITE;         
              WBREAD: next_state <= (i_rmvalid)? WB2AXI_RRESP: WBREAD;        
              WB2AXI_WRESP: next_state <= bridge_idle;
              WB2AXI_RRESP: next_state <= bridge_idle;         
           endcase         
       end         
                
       //output sequential logic         
           always @(posedge i_clk) begin         
             if (i_rst)  begin         
                //RESETTING ALL OUTPUT VALUES OF BRIDGE SIGNALS TO ZERO         
                //AXI SIGNALS (AXI2WB)         
                 o_awsready <= 1'b0;         
                 o_arsready <= 1'b0;         
                 o_wsready <= 1'b0;         
                 o_bsvalid <= 1'b0;         
                 o_rsdata <= 32'b0;         
                 o_rsvalid <= 1'b0;         
                //AXI SIGNALS (WB2AXI)         
                 o_awmaddr <= {AW{1'b0}};         
                 o_awmvalid <= 1'b0;         
                 o_armvalid <= 1'b0;         
                 o_armaddr <= {AW{1'b0}};         
                 o_wmdata <= 32'b0;         
                 o_wmstrb <= 4'b0;         
                 o_wmvalid <= 1'b0;         
                 o_bmready <= 1'b0;         
                 o_rmready <= 1'b0;         
                          
               // WISHBONE SIGNALS (AXI2WB)         
                o_mwb_adr <= {AW-2{1'b0}};         
                o_mwb_dat <= 32'b0;         
                o_mwb_sel <= 4'b0;         
                o_mwb_we <= 1'b0;         
                o_mwb_stb <= 1'b0;         
                // WISHBONE SIGNALS (WB2AXI)         
                o_swb_rdt <= 32'b0;         
                o_swb_ack <= 1'b0;         
             end         
             else begin         
                      
           case(state)         
                    
           bridge_idle : begin         
                //AXI SIGNALS (AXI2WB)         
                 o_awsready <= 1'b0;         
                 o_arsready <= 1'b0;         
                 o_wsready <= 1'b0;         
                 o_bsvalid <= 1'b0;         
                 o_rsdata <= 32'b0;         
                 o_rsvalid <= 1'b0;         
                 arbiter <= 1'b1;         
                //AXI SIGNALS (WB2AXI)         
                 o_awmaddr <= {AW{1'b0}};         
                 o_awmvalid <= 1'b0;         
                 o_armvalid <= 1'b0;         
                 o_armaddr <= {AW{1'b0}};         
                 o_wmdata <= 32'b0;         
                 o_wmstrb <= 4'b0;         
                 o_wmvalid <= 1'b0;         
                 o_bmready <= 1'b0;         
                 o_rmready <= 1'b0;         
                          
               // WISHBONE SIGNALS (AXI2WB)         
                o_mwb_adr <= {AW-2{1'b0}};         
                o_mwb_dat <= 32'b0;         
                o_mwb_sel <= 4'b0;         
                o_mwb_we <= 1'b0;         
                o_mwb_stb <= 1'b0;         
                // WISHBONE SIGNALS (WB2AXI)         
                o_swb_rdt <= 32'b0;         
                o_swb_ack <= 1'b0;          
           end         
       // AXI2WB Bridge states start  /////         
               AXI2WB_start: begin         
                   if (i_awsvalid && arbiter) begin         
                       o_mwb_adr[AW-1:2] <= i_awsaddr[AW-1:2];         
                       o_awsready <= 1'b1;         
                       arbiter <= 1'b0;         
                
                       if (i_wsvalid) begin                        
                           o_mwb_stb <= 1'b1;         
                           o_mwb_sel <= i_wsstrb;         
                           o_mwb_dat <= i_wsdata[31:0];         
                           o_mwb_we <= 1'b1;         
                           o_wsready <= 1'b1;         
                                   
                       end         
                   end         
                   else if (i_arsvalid) begin         
                        o_mwb_adr[AW-1:2] <= i_arsaddr[AW-1:2];         
                        o_mwb_sel <= 4'hF;         
                        o_mwb_stb <= 1'b1;         
                        o_arsready <= 1'b1;         
                                
       	        end         
       	   end         
                        
               AXI2WB_AWACK : begin         
                     if (i_wsvalid) begin         
                           o_mwb_stb <= 1'b1;         
                           o_mwb_sel <= i_wsstrb;         
                           o_mwb_dat <= i_wsdata[31:0];         
                           o_mwb_we <= 1'b1;         
                           o_wsready <= 1'b1;         
                                    
                     end         
                  end         
                
               AXI2WB_WBWACK : begin         
                     if ( i_mwb_ack ) begin         
                        o_mwb_stb <= 1'b0;         
                        o_mwb_sel <= 4'h0;         
                        o_mwb_we <= 1'b0;         
                        o_bsvalid <= 1'b1;         
                                 
                     end         
                 end         
                
               AXI2WB_WBRACK : begin         
                     if ( i_mwb_ack) begin         
                            o_mwb_stb <= 1'b0;         
                            o_mwb_sel <= 4'h0;         
                            o_rsvalid <= 1'b1;         
                            o_rsdata <= i_mwb_rdt;         
                                     
                     end         
                  end         
                
               AXI2WB_BAXI : begin         
                             o_bsvalid <= 1'b1;         
                             if (i_bsready) begin         
                                  o_bsvalid <= 1'b0;             
                             end                             
                      end         
                
               AXI2WB_RRAXI : begin         
                             o_rsvalid <= 1'b1;         
                             if (i_rsready)         
                                o_rsvalid <= 1'b0;         
                            end      //AXI2WB Bridge states end          
                
      ///   WB2AXI BRIDGE AND STATES START  ////
                              WB2AXI_start: begin
                         o_swb_ack <= 1'b0;
                          if (i_swb_we) begin
                                 o_awmvalid <= 1'b1;
                                   if(i_awmready)
                                       o_awmaddr <= {i_swb_adr, 2'b00}; // Convert word address to byte address      
                             end else begin
                                 o_armvalid <= 1'b1;
                                   if (i_armready)
                                     o_armaddr <= {i_swb_adr, 2'b00};
                             end
                        
                     end
                      
                   WBWRITE: begin
                       o_wmvalid <=1'b1;
                       o_swb_ack <=1'b0;
                       if(i_wmready) begin
                          o_wmdata <= i_swb_dat;
                          o_wmstrb <= i_swb_sel;
                          o_bmready <=1'b1;        
                       end 
                   end
                 WB2AXI_WRESP: begin
                        o_bmready <=1'b1;
                        if(i_bmvalid) begin
                         o_swb_ack <=1'b1;
                                   if (i_bmresp != 2'b00)
                                        $display("Error while writing");
                                     else  begin
                                        $display("Successfully data written --- message from bridge");
                                         end
                        end     
                 end 
                 
                  WBREAD: begin
                       o_rmready <=1'b1; 
                       end 
                       
                  WB2AXI_RRESP: begin
                     if (i_rmresp != 2'b00) begin
                                      $display("Error while reading data");
                                  end else if (i_rmlast) begin
                                      o_swb_rdt <= i_rmdata;
                                      o_swb_ack <= 1'b1;
                                      $display("Successfully data read -----message from bridge");
                                  end
                     end    
            default: begin         
                //AXI SIGNALS (AXI2WB)         
                 o_awsready <= 1'b0;         
                 o_arsready <= 1'b0;         
                 o_wsready <= 1'b0;         
                 o_bsvalid <= 1'b0;         
                 o_rsdata <= 32'b0;         
                 o_rsvalid <= 1'b0;         
                //AXI SIGNALS (WB2AXI)         
                 o_awmaddr <= {AW{1'b0}};         
                 o_awmvalid <= 1'b0;         
                 o_armvalid <= 1'b0;         
                 o_armaddr <= {AW{1'b0}};         
                 o_wmdata <= 32'b0;         
                 o_wmstrb <= 4'b0;         
                 o_wmvalid <= 1'b0;         
                 o_bmready <= 1'b0;         
                 o_rmready <= 1'b0;         
                          
               // WISHBONE SIGNALS (AXI2WB)         
                o_mwb_adr <= {AW-2{1'b0}};         
                o_mwb_dat <= 32'b0;         
                o_mwb_sel <= 4'b0;         
                o_mwb_we <= 1'b0;         
                o_mwb_stb <= 1'b0;         
                // WISHBONE SIGNALS (WB2AXI)         
                o_swb_rdt <= 32'b0;         
                o_swb_ack <= 1'b0;         
            end         
                    
          endcase         
       end         
       end 
  // Mux sel to route the output axi signals    
  // for sel ==0, axi will gets AXI2WB signals and WB2AXI when sel==1    
   always @(posedge i_clk) begin
    if(i_swb_stb)
        sel <=1'b1;
    else
        sel <= 1'b0; 
   end
  // routing axi output signals
  assign {io_awaddr,io_awvalid,io_awready,
          io_araddr,io_arvalid,io_arready,
          io_wdata,io_wstrb,io_wvalid,io_wready,
          io_bresp, io_bvalid, io_bready,
          io_rdata, io_rresp,io_rlast,io_rvalid,io_rready}=(sel == 1'b0)?{i_awsaddr,i_awsvalid,o_awsready,  //AXI SIGNALS FROM EXT TO BRIDGE           
                                                                     i_arsaddr,i_arsvalid,o_arsready,             
                                                                     i_wsdata,i_wsstrb,i_wsvalid,o_wsready,        
                                                                     o_bsresp, o_bsvalid, i_bsready,              
                                                                     o_rsdata, o_rsresp,o_rslast,o_rsvalid,i_rsready}:
                                                                      
                                                                     (sel ==1'b1)? {o_awmaddr, o_awmvalid,i_awmready, o_armaddr,o_armvalid,i_armready,o_wmdata,o_wmstrb,o_wmvalid,   
                                                                      i_wmready,i_bmresp,i_bmvalid,o_bmready,i_rmdata,i_rmresp,i_rmlast,  
                                                                     i_rmvalid,o_rmready}:  //AXI SIGNALS FROM BRIDGE TO EXT
                                                                     
                                                                     {107{1'bz}};
    endmodule           