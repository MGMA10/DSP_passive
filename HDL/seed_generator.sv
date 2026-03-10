//`include "config.svh"
`define FPGA
module seed_generator #(
    parameter WIDTH = 32,
    parameter FL = 16
) (
    input  [WIDTH-1:0] leading_one_vector , // Vector masking the leading one
    input  [WIDTH-1:0] a_in ,
    output [WIDTH-1:0] nr_seed ,              // Newton-Raphson seed
    output [WIDTH-1:0] a_out
);

localparam IL = WIDTH - FL;

// Constants from the original design
localparam f1 = ((FL-1)/2);
localparam f2 = ((FL-2)/2);
localparam f3 = ((FL-4)/2);
localparam c1 = (-IL/2);
localparam c2 = ((-IL-1)/2);
localparam c3 = ((-IL-3)/2);

localparam start_index = c3;
localparam finish_index = f1;

genvar idx;

assign a_out = a_in >> 1 ;

generate
    for (idx = 0; idx < WIDTH; idx = idx + 1) begin : gen_seed_bit
        // Map the bit index to the internal index i used in the original logic
        localparam integer i = idx - FL;

        // Single continuous assignment per bit – no multiple drivers
        assign nr_seed[idx] =
            (idx < FL + start_index) ? 1'b0 :                       // Bits below active range
            (idx > FL + finish_index) ? 1'b0 :                      // Bits above active range
            // Active range: apply original conditions in the same order
            (i >= c1 && i <= f3) ? (leading_one_vector[FL - 2*i - 1] |
                                    leading_one_vector[FL - 2*i - 2] |
                                    leading_one_vector[FL - 2*i - 4]) :
            (i <= f2 && i > f3) ? (leading_one_vector[FL - 2*i - 1] |
                                   leading_one_vector[FL - 2*i - 2]) :
            (i >= c2 && i < c1) ? (leading_one_vector[FL - 2*i - 2] |
                                   leading_one_vector[FL - 2*i - 4]) :
            (i <= f1 && i > f2) ? leading_one_vector[FL - 2*i - 1] :
            (i >= c3 && i < c2) ? leading_one_vector[FL - 2*i - 4] :
            1'b0;  // Default (should not occur if ranges are correct)
    end
endgenerate

endmodule