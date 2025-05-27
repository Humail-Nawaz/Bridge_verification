/* serving_ram.v : I/D SRAM for the serving SoC
 *
 * ISC License
 *
 * Copyright (C) 2020 Olof Kindgren <olof.kindgren@gmail.com>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

`default_nettype none
module serving_ram
  #(//Memory parameters
    parameter depth = 256,
    parameter aw    = $clog2(depth),    //8
    parameter memfile = "")
    
   (input wire		   i_clk,
    input wire [aw-1:0]	i_waddr,
    input wire [7:0]	i_wdata,
    input wire		    i_wen,
    input wire [aw-1:0]	i_raddr,
    output reg [7:0]	o_rdata,
    input wire		    i_ren
   //output reg ack
    
        );

   reg [7:0]		mem [0:depth-1] /* verilator public */;
   //reg [7:0]init_data;
  //reg write_ack, read_ack;
   
   always @(posedge i_clk) begin
     //write_ack <= 1'b0;
     //read_ack  <= 1'b0;
   
     if (i_wen) begin
       mem[i_waddr] <= i_wdata;
       //write_ack <= 1'b1;
     end
     else begin
       o_rdata <= mem[i_raddr];
       //read_ack <= 1'b1;
     end
   
    // ack <= write_ack || read_ack;
   end

   initial
     if(|memfile) begin
	$display("Preloading %m from %s", memfile);
	$readmemh(memfile, mem);
     end
     
     wire [63:0] debug_out;
     assign debug_out = {mem[i_waddr], mem[i_waddr+8], mem[i_waddr+16], mem[i_waddr+24], mem[i_waddr+32], mem[i_waddr+40], mem[i_waddr+48], mem[i_waddr+56]};

endmodule