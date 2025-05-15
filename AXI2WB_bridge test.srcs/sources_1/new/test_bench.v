`timescale 1ns/1ps

module test_bench;

    // Clock and Reset
    reg clk;
    reg rst;

    // AXI Interface
    reg [11:0] awaddr;
    reg awvalid;
    wire awready;

    reg [11:0] araddr;
    reg arvalid;
    wire arready;

    reg [63:0] wdata;
    reg [7:0] wstrb;
    reg wvalid;
    wire wready;

    wire [1:0] bresp;
    wire bvalid;
    reg bready;

    wire [63:0] rdata;
    wire [1:0] rresp;
    wire rlast;
    wire rvalid;
    reg rready;

    // Wishbone Interface
    wire [11:2] wb_adr;  // Word addressing
    wire [31:0] wb_dat;
    wire [3:0] wb_sel;
    wire wb_we;
    wire wb_stb;
    wire wb_cyc = wb_stb; // For simple memory
    reg [31:0] wb_rdt;
    reg wb_ack;

    // Instantiate AXI to WB Bridge
    axi2wb #(
        .AW(12),
        .IW(0)
    ) dut (
        .i_clk(clk),
        .i_rst(rst),

        // Wishbone
        .o_wb_adr(wb_adr),
        .o_wb_dat(wb_dat),
        .o_wb_sel(wb_sel),
        .o_wb_we(wb_we),
        .o_wb_stb(wb_stb),
        .i_wb_rdt(wb_rdt),
        .i_wb_ack(wb_ack),

        // AXI
        .i_awaddr(awaddr),
        .i_awvalid(awvalid),
        .o_awready(awready),
        .i_araddr(araddr),
        .i_arvalid(arvalid),
        .o_arready(arready),
        .i_wdata(wdata),
        .i_wstrb(wstrb),
        .i_wvalid(wvalid),
        .o_wready(wready),
        .o_bresp(bresp),
        .o_bvalid(bvalid),
        .i_bready(bready),
        .o_rdata(rdata),
        .o_rresp(rresp),
        .o_rlast(rlast),
        .o_rvalid(rvalid),
        .i_rready(rready)
    );

    // Simple Wishbone Memory
    reg [31:0] wb_mem [0:511]; // 2KB memory (512 x 32-bit)

    // Waveform dumping
    initial begin
        $dumpfile("axi2wb_tb.vcd");
        $dumpvars(0, test_bench);
    end

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz clock

    // Loop variable
    integer i;

    // Wishbone Memory Model
    always @(posedge clk) begin
        if (rst) begin
            wb_ack <= 0;
            for (i = 0; i < 512; i = i + 1) begin
                wb_mem[i] <= i + (i << 16);
            end
        end else begin
            wb_ack <= 0;

            if (wb_cyc && wb_stb) begin
                #1; // Simulate delay
                wb_ack <= 1;

                if (wb_we) begin
                    case (wb_sel)
                        4'b0001: wb_mem[wb_adr][7:0]   <= wb_dat[7:0];
                        4'b0010: wb_mem[wb_adr][15:8]  <= wb_dat[15:8];
                        4'b0100: wb_mem[wb_adr][23:16] <= wb_dat[23:16];
                        4'b1000: wb_mem[wb_adr][31:24] <= wb_dat[31:24];
                        4'b0011: wb_mem[wb_adr][15:0]  <= wb_dat[15:0];
                        4'b1100: wb_mem[wb_adr][31:16] <= wb_dat[31:16];
                        default: wb_mem[wb_adr] <= wb_dat;
                    endcase
                    $display("[%0t] WB MEM WR: addr=0x%h data=0x%h sel=0x%h", 
                            $time, {wb_adr, 2'b00}, wb_dat, wb_sel);
                end else begin
                    wb_rdt <= wb_mem[wb_adr];
                    $display("[%0t] WB MEM RD: addr=0x%h data=0x%h", 
                            $time, {wb_adr, 2'b00}, wb_mem[wb_adr]);
                end
            end
        end
    end

    // Main test sequence
    initial begin
        // Initialize all inputs
        rst = 1;
        awaddr = 0;
        awvalid = 0;
        araddr = 0;
        arvalid = 0;
        wdata = 0;
        wstrb = 0;
        wvalid = 0;
        bready = 0;
        rready = 0;

        // Reset
        #20;
        rst = 0;
        #10;

        // Test 1
        $display("\n[%0t] Test 1: Write lower 32 bits", $time);
        awaddr = 12'h004;
        awvalid = 1;
        wdata = 64'h1122334455667788;
        wstrb = 8'b00001111;
        wvalid = 1;
        wait(awready && wready);
        #10;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        wait(bvalid);
        #10;
        bready = 0;
        #20;
        if (wb_mem[1] === 32'h55667788)
            $display("[%0t] PASS", $time);
        else
            $display("[%0t] FAIL: got 0x%h", $time, wb_mem[1]);

        // Test 2
        $display("\n[%0t] Test 2: Write upper 32 bits", $time);
        awaddr = 12'h004;
        awvalid = 1;
        wdata = 64'hAABBCCDDEEFF9988;
        wstrb = 8'b11110000;
        wvalid = 1;
        wait(awready && wready);
        #10;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        wait(bvalid);
        #10;
        bready = 0;
        #20;
        if (wb_mem[1] === 32'hEEFF9988)
            $display("[%0t] PASS", $time);
        else
            $display("[%0t] FAIL: got 0x%h", $time, wb_mem[1]);

        // Test 3
        $display("\n[%0t] Test 3: Full 64-bit write", $time);
        awaddr = 12'h008;
        awvalid = 1;
        wdata = 64'hDEADBEEFCAFEBABE;
        wstrb = 8'b11111111;
        wvalid = 1;
        wait(awready && wready);
        #10;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        wait(bvalid);
        #10;
        bready = 0;
        #20;
        if (wb_mem[2] === 32'hCAFEBABE && wb_mem[3] === 32'hDEADBEEF)
            $display("[%0t] PASS", $time);
        else
            $display("[%0t] FAIL", $time);

        // Test 4
        $display("\n[%0t] Test 4: Read operation", $time);
        araddr = 12'h008;
        arvalid = 1;
        wait(arready);
        #10;
        arvalid = 0;
        rready = 1;
        wait(rvalid);
        if (rdata === 64'hDEADBEEFCAFEBABE)
            $display("[%0t] PASS", $time);
        else
            $display("[%0t] FAIL: got 0x%h", $time, rdata);
        #10;
        rready = 0;

        // Test 5
        $display("\n[%0t] Test 5: Byte write", $time);
        awaddr = 12'h010;
        awvalid = 1;
        wdata = 64'h00000000000000AA;
        wstrb = 8'b00000001;
        wvalid = 1;
        wait(awready && wready);
        #10;
        awvalid = 0;
        wvalid = 0;
        bready = 1;
        wait(bvalid);
        #10;
        bready = 0;
        #20;
        if (wb_mem[4][7:0] === 8'hAA)
            $display("[%0t] PASS: Byte write verified", $time);
        else
            $display("[%0t] FAIL: Byte write incorrect", $time);

        $display("\n[%0t] Simulation complete", $time);
        #100;
        $finish;
    end

    // FSM debug
    always @(dut.cs) begin
        $display("[%0t] Bridge FSM state: %0d", $time, dut.cs);
    end

    // Timeout
    initial begin
        #100000;
        $display("[%0t] Error: Simulation timeout", $time);
        $finish;
    end

endmodule
