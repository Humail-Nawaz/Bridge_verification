`timescale 1ns / 1ps


module cmplt_top_tb;

    // Clock and Reset
    reg i_clk = 0;
    reg i_rst = 0;

    // AXI Master signals to bridge (AXI2WB)
    reg [11:0] i_awaddr;
    reg i_awvalid;
    wire o_awready;
    reg [11:0] i_araddr;
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

    // WB Master signals from SERVING (WB2AXI)
    reg [11:2] i_swb_adr;
    reg [31:0] i_swb_dat;
    reg [3:0] i_swb_sel;
    reg i_swb_we;
    reg i_swb_stb;
    wire [31:0] o_swb_rdt;
    wire o_swb_ack;
    reg [31:0] read_data;


    // Instantiate DUT
    cmplt_top uut (
        .i_clk(i_clk),
        .i_rst(i_rst),
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
        .i_swb_adr(i_swb_adr),
        .i_swb_dat(i_swb_dat),
        .i_swb_sel(i_swb_sel),
        .i_swb_we(i_swb_we),
        .i_swb_stb(i_swb_stb),
        .o_swb_rdt(o_swb_rdt),
        .o_swb_ack(o_swb_ack)
    );

    // Clock generation
    always #5 i_clk = ~i_clk;

    // Test sequence
    initial begin
        // Initialize
        i_rst = 1;
        i_awaddr = 12'h000;
        i_awvalid = 0;
        i_wdata = 32'h00000000;
        i_wstrb = 4'hF;
        i_wvalid = 0;
        i_bready = 1;
        i_araddr = 12'h000;
        i_arvalid = 0;
        i_rready = 1;

        i_swb_adr = 10'h0;
        i_swb_dat = 32'h0;
        i_swb_sel = 4'hF;
        i_swb_we = 0;
        i_swb_stb = 0;

        #20;
        i_rst = 0;

        // AXI2WB write transaction
        i_rst = 0;
            $display("Starting AXI write and read test...");
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
            $display("DATA written: WDATA = 0x%08X", cmplt_top.o_mwb_dat); end
            else $display("Wrong data written");
            #100;
        
            // -----------------------------
            // AXI2WB Read transaction from address 0x100
            // -----------------------------
            i_rst =1'b1;
            #10;
            i_rst=1'b0;
            i_arvalid = 1;
            i_araddr=12'h100;
            i_rready  = 1;
            #10;
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
          
      //WB2AXI WRITE TRANSACTION//
      $display("==== Starting WB2AXI Transactions ====");
          i_rst = 1;
          #10;
          i_rst = 0;
          #20;
          i_swb_adr = 10'h1;
          i_swb_dat = 32'hfadeface;
          i_swb_sel = 4'b1111;
          i_swb_we  = 1'b1;
          i_swb_stb = 1'b1;
          wait(o_swb_ack)
          i_swb_stb=1'b0;
          $display("DATA WRITTEN TO AXI=0x%08X",cmplt_top.o_wmdata);
  // WB2AXI READ TRANSACTION        
          #10;
          i_rst=1;
          #20;
          i_rst=0;
              i_swb_adr = 10'h1;
             // i_swb_dat = 32'hfadeface;
              i_swb_sel = 4'b1111;
              i_swb_we  = 1'b0;
              i_swb_stb = 1'b1;
              wait(o_swb_ack)
              read_data = o_swb_rdt;
              i_swb_stb = 1'b0;
          #10;   
              $display("DATA READ FROM AXI=0x%08X",cmplt_top.o_swb_rdt);
          #10;
      //    rst=1;
      //    #10; rst=0;
      //    #20;
          $display("==== Testbench Complete ====");    
        #100 $finish;
    end

endmodule
