`timescale 1ns / 1ps

// Dummy WB slave: simple memory model
module wb_slave_dummy(
    input wire clk, input wire rst,
    input wire [10:0] adr_i, 
    input wire [31:0] dat_i, 
    input wire [3:0] sel_i,
    input wire we_i, 
    input wire stb_i, 
    output reg [31:0] dat_o, 
    output reg ack_o
);
    reg [31:0] mem [0:255];
    always @(posedge clk) begin
        ack_o <= 0;
        if (stb_i) begin
            ack_o <= 1;
            if (we_i) begin
                mem[adr_i[9:2]] <= dat_i;
            end else begin
                dat_o <= mem[adr_i[9:2]];
            end
        end
    end
endmodule