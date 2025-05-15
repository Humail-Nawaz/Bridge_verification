`timescale 1ns / 1ps

`timescale 1ns / 1ps

// Dummy Wishbone Master: Writes then reads back from slave
module wb_dummy_master_ip(
    input clk, input rst,
    output reg [31:0] adr_o,
    output reg [31:0] dat_o,
    output reg [3:0]  sel_o,
    output reg        we_o,
    output reg        stb_o,
    input      [31:0] dat_i,
    input             ack_i
);

    reg [3:0] state;
    reg [31:0] rdata;

    localparam IDLE   = 0,
               WRITE  = 1,
               WAIT_W = 2,
               READ   = 3,
               WAIT_R = 4,
               DONE   = 5;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state   <= IDLE;
            adr_o   <= 0;
            dat_o   <= 0;
            sel_o   <= 4'b1111;
            we_o    <= 0;
            stb_o   <= 0;
            rdata   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    adr_o <= 32'h0000_0010;      // address to write
                    dat_o <= 32'hCAFEBABE;       // data to write
                    we_o  <= 1;
                    stb_o <= 1;
                    state <= WAIT_W;
                end

                WAIT_W: begin
                    if (ack_i) begin
                        stb_o <= 0;
                        we_o  <= 0;
                        state <= READ;
                    end
                end

                READ: begin
                    stb_o <= 1;
                    we_o  <= 0;
                    state <= WAIT_R;
                end

                WAIT_R: begin
                    if (ack_i) begin
                        rdata <= dat_i;          // capture read data
                        stb_o <= 0;
                        state <= DONE;
                    end
                end

                DONE: begin
                    // Finished read/write, remain here
                end
            endcase
        end
    end

endmodule
