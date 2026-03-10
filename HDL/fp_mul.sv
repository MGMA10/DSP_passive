`include "config.svh"
// `define FPGA
// Module: FixedPoint_Mul
// Purpose: Pipelined Q-format multiplier for synthesis
module fp_mul #(
    parameter int WIDTH = 32,
    parameter int FRAC  = 16
)(
    input   logic                       clk,
    input   logic signed [WIDTH-1:0]    a,
    input   logic signed [WIDTH-1:0]    b,
    output  logic signed [WIDTH-1:0]    product
);

    logic signed [2*WIDTH-1:0] full_res;
    logic signed [2*WIDTH-1:0] Mul_res;

        // ===============================================================
		// Multipliers
		// ===============================================================
    generate
		    `ifdef FPGA 
                
		        mult_gen_0 mul (
		            .A((a)),
		            .B((b)),
		            .P(Mul_res)
		        );
		    `else
		        multiplier #(
		            .WIDTH(WIDTH),
                    .FL(FRAC)     
		        ) mul (
		            .A((a)),
		            .B((b)),
		            .mult_out(Mul_res)
		        );
		    `endif
    endgenerate


    // always_ff @(posedge clk) begin
    //     // Standard signed multiplication
    //     full_res <= Mul_res;
    // end
    assign full_res = Mul_res;
    // Selecting the Q-format window from the 64-bit result
    // We shift right by FRAC bits to align the decimal point
    assign product = full_res[FRAC +: WIDTH];

endmodule