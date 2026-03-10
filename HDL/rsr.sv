//`include "config.svh"
`define FPGA
module rsr_top #(
    parameter WIDTH = 32,
    parameter FL = 16
)(  
    input clk , rst_n ,
    input [WIDTH-1:0] a_in,
    output [WIDTH-1:0] a_rsr
);


wire [WIDTH-1:0] LOD , a_lod_bypass;

LOD_a #(.DATA_WIDTH(WIDTH)) LEADING_1_DET (
    .clk(clk) ,
    .rst_n(rst_n) ,
    .a_in (a_in) ,
    .a_out (a_lod_bypass) ,
    .leadind_one_a (LOD)
);

wire [WIDTH-1:0] nr_seed , a_div_2;

seed_generator #(
        .WIDTH(WIDTH),
        .FL(FL)
    ) SEED_GEN (
    .leading_one_vector (LOD),
    .a_in (a_lod_bypass),
    .nr_seed (nr_seed),
    .a_out (a_div_2)
);

nr_pipeline_3iter #(
        .WIDTH(WIDTH),
        .FRAC(FL)
    ) NR_ITs ( 
    .clk (clk),
    .rst_n (rst_n),
    .a_in (a_div_2),
    .x0_in (nr_seed),
    .x3_out(a_rsr)
);

endmodule