`timescale 1ns / 1ps
    
    module serving_bridge_top_tb;
    
      parameter AW = 12;
    
      // Clock and reset
      reg clk=0;
      reg rst;
    
      // AXI inputs to the bridge
      reg [AW-1:0] i_awaddr;
      reg i_awvalid;
      wire o_awready;
    
      reg [AW-1:0] i_araddr;
      reg i_arvalid;
      wire o_arready;
    
      reg [31:0] i_wdata;
      reg [3:0] i_wstrb;
      reg i_wvalid;
      wire o_wready;
    
      wire [1:0] o_bresp;
      wire o_bvalid;
      reg i_bready;
    
      wire [31:0] o_rdata;
      wire [1:0] o_rresp;
      wire o_rlast;
      wire o_rvalid;
      reg i_rready;
    
      // AXI master-side dummy responses
      wire [AW-1:0] o_awmaddr;
      wire o_awmvalid;
      reg i_awmready;
    
      wire [AW-1:0] o_armaddr;
      wire o_armvalid;
      reg i_armready;
    
      wire [31:0] o_wmdata;
      wire [3:0] o_wmstrb;
      wire o_wmvalid;
      reg i_wmready;
    
      reg [1:0] i_bmresp;
      reg i_bmvalid;
      wire o_bmready;
    
      reg [31:0] i_rmdata;
      reg [1:0] i_rmresp;
      reg i_rmlast;
      reg i_rmvalid;
      wire o_rmready;
    
      // Instantiate the DUT
      serving_bridge_top #(AW) dut (
        .clk(clk),
        .rst(rst),
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
    
      // Clock generation
      always #5 clk = ~clk;

       initial begin
                // Initialize
                rst = 1;
                i_awaddr = 12'h000;
                i_awvalid = 0;
                i_wdata = 32'h00000000;
                i_wstrb = 4'hF;
                i_wvalid = 0;
                i_bready = 1;
                i_araddr = 12'h000;
                i_arvalid = 0;
                i_rready = 1;
    
                #20; rst = 0;
    
        // -----------------------------
                    // Write transaction to address 0x100
                    // -----------------------------
                    i_awvalid = 1;
                    i_wvalid  = 1;
                    i_bready = 1;
                    i_awaddr = 12'h100;
                    i_wdata = 32'hfadeface;
                    i_wstrb = 4'b1111;
                    #10;
                    wait (o_awready && o_wready);
                    #20;
                    i_awvalid = 0;
                    i_wvalid  = 0;
                
                    wait (o_bvalid);
                    if(o_bresp==2'b00) begin
                    $display("Data written without error");
                    $display("Write response received: BRESP = %b", o_bresp);
                    //$display("DATA written: WDATA = 0x%08X", cmplt_top.o_mwb_dat); 
                    end
                    else $display("Wrong data written");
 // -----------------------------
// AXI2WB Read transaction from address 0x100
// -----------------------------                             
                    rst =1'b1;
                    #10;
                    rst=1'b0;
                    i_arvalid = 1;
                    i_araddr=12'h100;
                    i_rready  = 1;                   
                    wait (o_arready);
                    #20;
                    i_arvalid = 0;
                    wait(o_rvalid)
                    if(o_rresp ==2'b00) begin
                    $display("Data read correctly without error");
                    $display("Read data received: RDATA = 0x%08X, RRESP = %b", o_rdata, o_rresp);
                    end
                    else $display("wrong data read");
                  $display("AXI write and read test complete.");
                
               
        #100;
        $finish;
      end
    
endmodule
