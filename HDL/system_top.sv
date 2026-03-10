`include "config.svh"
(* DONT_TOUCH = "TRUE" *)

// `define FPGA
module system_top #(
    parameter int M = 96,
    parameter int N = 64,
    parameter int WIDTH = 18,
    parameter int FL = 12,
    parameter int ALPHA = 842,
    parameter int THRESHOLD = 819
)(
    input  logic clk,
    input  logic rst_n,
    input  logic y_sign [0:M-1],
    output logic signed [WIDTH-1:0] x_out [N]
);

    // Internal connection
    logic signed [WIDTH-1:0] Z [N];

    // -------------------------------------------------
    // ACC64
    // -------------------------------------------------
    ACC64 #(
        .WIDTH (WIDTH),
        .FL    (FL),
        .N     (N)
    ) u_acc64 (
        .clk    (clk),
        .rst_n  (rst_n),
        .y_sign_in (y_sign),
        .Z      (Z)
    );

    // -------------------------------------------------
    // passive_top
    // -------------------------------------------------
    passive_top #(
        .M         (M),
        .N         (N),
        .WIDTH     (WIDTH),
        .FL        (FL),
        .ALPHA     (ALPHA),
        .THRESHOLD (THRESHOLD)
    ) u_passive_top (
        .clk    (clk),
        .rst_n  (rst_n),
        .Z      (Z),
        .x_out  (x_out)
    );

endmodule