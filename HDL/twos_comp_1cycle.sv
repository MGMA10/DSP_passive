//`include "config.svh"
`define FPGA
module twos_comp_1cycle #(
    parameter  DATA_WIDTH = 32   
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic [DATA_WIDTH-1:0]       br_in,
    output logic [DATA_WIDTH:0]         tc_out
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        tc_out   <= '0;
    end else begin
        tc_out <= (~br_in) + 1'b1;
    end
end

endmodule
