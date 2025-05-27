`timescale 1ns / 1ps
`default_nettype none

module axi_slave_ip #(
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

  // AXI response codes
  localparam RESP_OKAY = 2'b00;

  // Internal memory
  reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1];
  integer i;
  // Write logic
  always @(posedge ACLK) begin
    if (RESET) begin
      AWREADY <= 0;
      WREADY  <= 0;
      BVALID  <= 0;
      BRESP   <= RESP_OKAY;
    end else begin
      // Address handshake
      if (!AWREADY && AWVALID)
        AWREADY <= 1;
      else
        AWREADY <= AWREADY;

      // Data handshake
      if (!WREADY && WVALID)
        WREADY <= 1;
      else
        WREADY <= WREADY;

      // Write operation
      if (AWREADY && AWVALID && WREADY && WVALID) begin
        
        for (i = 0; i < DATA_WIDTH/8; i = i + 1) begin
          if (WSTRB[i])
            mem[AWADDR[ADDR_WIDTH-1:2]][8*i +: 8] <= WDATA[8*i +: 8];
        end
        BVALID <= 1;
      end

      // Response handshake
      if (BVALID && BREADY)
        BVALID <= 0;
    end
  end

  // Read logic
  always @(posedge ACLK) begin
    if (RESET) begin
      ARREADY <= 0;
      RVALID  <= 0;
      RRESP   <= RESP_OKAY;
      RDATA   <= 0;
      RLAST   <= 0;
      end else begin
      // Address handshake
      if (!ARREADY && ARVALID) begin
        ARREADY <= 1;
        RLAST <= 1;  end
      else
        ARREADY <= ARREADY;

      // Read operation
      if (ARREADY && ARVALID) begin
        RDATA  <= mem[ARADDR[ADDR_WIDTH-1:2]];
        RVALID <= 1;
      end

      // Read data handshake
      if (RVALID && RREADY)
        RVALID <= 0;
    end
  end

endmodule

`default_nettype wire
