`include "config.svh"
//`define FPGA
module bit_reverse #(parameter
  DATA_WIDTH = 32
) (
  input  logic  [DATA_WIDTH-1:0]    din,
  output logic  [DATA_WIDTH-1:0]    dout
);
integer i;
always_comb begin
    dout = 0;
    for(i=0;i<DATA_WIDTH;i=i+1) begin
        dout[i] = din[DATA_WIDTH-1-i];
    end
end
endmodule