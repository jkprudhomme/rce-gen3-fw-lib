`timescale  1 ps / 1 ps
`define DEL 500 // standard delay = 500 ps
module clk_div_100(clkIn, clkOut, rst);
   input clkIn;          // Input Clock
   input rst;            // Active high reset
   output clkOut;        // clock out = input clk / 100

   reg    [6:0] count;   
   
   
   
   always @(posedge clkIn or posedge rst) begin
      if (rst) begin
         count <= #`DEL 7'b0;
      end
      else begin
         if (count == 99) begin
            count <= #`DEL 7'b0;
         end
         else begin
            count <= #`DEL count + 1;
         end
      end
   end

   assign #`DEL clkOut = count < 50 ? 1'b1 : 1'b0;

   
endmodule

