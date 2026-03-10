//No comments 3alashan lsa han3adel.
//We can use 3 iterations and remove the pipeline. XD
`include "config.svh"
//`define FPGA
module nr_pipeline_3iter #(
    parameter int WIDTH = 32,
    parameter int FRAC  = 16
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic [WIDTH-1:0]  a_in,
    input  logic [WIDTH-1:0]  x0_in,
    output logic [WIDTH-1:0]  x3_out
);

    logic [WIDTH-1:0] x1, x2;
    logic [WIDTH-1:0] a_d1, a_d2, a_d3;
    logic [WIDTH-1:0]  x3_out_inter;

        nr_iteration #(.WIDTH(WIDTH), .FRAC(FRAC)) NR1 (
        .clk(clk),
        .rst_n(rst_n),
        .a_in(a_in),
        .x0_in(x0_in),
        .a_out(a_d1),
        .x1_out(x1)
    );

        nr_iteration #(.WIDTH(WIDTH), .FRAC(FRAC)) NR2 (
        .clk(clk),
        .rst_n(rst_n),
        .a_in(a_d1),
        .x0_in(x1),
        .a_out(a_d2),
        .x1_out(x2)
    );

        nr_iteration #(.WIDTH(WIDTH), .FRAC(FRAC)) NR3 (
        .clk(clk),
        .rst_n(rst_n),
        .a_in(a_d2),
        .x0_in(x2),
        .a_out(a_d3),   // Could be ignored , bs hasebha XD
        .x1_out(x3_out_inter)
    );

    // TODO : Add the final register
    d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (x3_out_inter),
            .d_out (x3_out)
        );
    

    
endmodule