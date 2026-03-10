`include "config.svh"
//`define FPGA
// ------------------------------------------------------------
// Module: LOD_a
// Purpose:
//   Leading-One Detector (LOD) for input a_in
//
//   Algorithm:
//   1) Bit-reverse the input
//   2) Compute two's complement of the bit-reversed value
//   3) AND original and two's-complement values to isolate
//      the least-significant '1' in the reversed domain
//   4) Bit-reverse again to map it back as the leading '1'
//
//   This structure is commonly used in normalization,
//   floating-point, and DSP datapaths.
//
// Latency:
//   - Pipelined (multiple clock cycles)
// ------------------------------------------------------------
module LOD_a #(
    parameter DATA_WIDTH = 32
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic [DATA_WIDTH-1:0]       a_in,          // Input data
    output logic [DATA_WIDTH-1:0]       a_out,         // Registered pass-through of a_in
    output logic [DATA_WIDTH-1:0]       leadind_one_a  // One-hot position of leading '1'
);

    // --------------------------------------------------------
    // Internal signals
    // --------------------------------------------------------

    // Bit-reversed version of input
    logic [DATA_WIDTH-1:0] bit_reverse_out;

    // Registered bit-reversed input (pipeline alignment)
    logic [DATA_WIDTH-1:0] bit_reverse_out_r;

    // Two's complement of bit-reversed input
    // Extra bit added to capture carry-out
    logic [DATA_WIDTH:0]   tc_out;

    // AND result used to isolate first '1' in reversed domain
    logic [DATA_WIDTH:0]   anding_out;

    // --------------------------------------------------------
    // AND operation:
    //   x & 2'c(x) isolates the least-significant '1'
    //   Here done on the bit-reversed value
    // --------------------------------------------------------
    assign anding_out = {1'b0, bit_reverse_out_r} & tc_out;

    // --------------------------------------------------------
    // Bit-reverse input
    // MSB <-> LSB, etc.
    // --------------------------------------------------------
    bit_reverse #(
        .DATA_WIDTH(DATA_WIDTH)
    ) BR1 (
        .din  (a_in),
        .dout (bit_reverse_out)
    );

    // --------------------------------------------------------
    // Register the bit-reversed data
    // Aligns timing with two's complement path
    // --------------------------------------------------------
    d_ff #(
        .DATA_WIDTH(DATA_WIDTH)
    ) D1 (
        .clk   (clk),
        .rst_n (rst_n),
        .d_in  (bit_reverse_out),
        .d_out (bit_reverse_out_r)
    );

    // --------------------------------------------------------
    // Compute two's complement of bit-reversed input
    // tc_out = (~bit_reverse_out + 1)
    //
    // Used to extract LSB '1' via AND operation
    // --------------------------------------------------------
    twos_comp_1cycle #(
        .DATA_WIDTH(DATA_WIDTH)
    ) CA_2 (
        .clk   (clk),
        .rst_n (rst_n),
        .br_in (bit_reverse_out),
        .tc_out(tc_out)
    );

    // --------------------------------------------------------
    // Bit-reverse again:
    // Converts isolated LSB '1' (reversed domain)
    // into leading '1' (original domain)
    // --------------------------------------------------------
    bit_reverse #(
        .DATA_WIDTH(DATA_WIDTH)
    ) BR2 (
        .din  (anding_out[DATA_WIDTH-1:0]),
        .dout (leadind_one_a)
    );

    // --------------------------------------------------------
    // Register original input
    // Used to keep data aligned with LOD output
    // --------------------------------------------------------
    d_ff #(
        .DATA_WIDTH(DATA_WIDTH)
    ) D2 (
        .clk   (clk),
        .rst_n (rst_n),
        .d_in  (a_in),
        .d_out (a_out)
    );

endmodule
