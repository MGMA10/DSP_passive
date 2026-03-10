`include "config.svh"
// `define FPGA

module row_impl_64 #(
    parameter int WIDTH     = 2,     // before guard bit
    parameter int dsp_num   = 6,
    parameter int elem_dsp  = 12
)(
    input           logic                     add_sub_sel,
    input   logic   signed  [WIDTH-1:0]         A [64],
    input   logic   signed  [WIDTH-1:0]         B [64],
    output  logic   signed  [WIDTH:0]           S [64]
);

    // ---------------------------------------------------------
    // Local parameters
    // ---------------------------------------------------------
    localparam int GUARD_WIDTH = WIDTH + 2;
    localparam int DSP_WIDTH   = 48;
    localparam int LAST_ELEM   = 64 - (dsp_num-1)*elem_dsp;

    // ---------------------------------------------------------
    // Internal signals per DSP
    // ---------------------------------------------------------
    logic signed [DSP_WIDTH-1:0] A_dsp [dsp_num];
    logic signed [DSP_WIDTH-1:0] B_dsp [dsp_num];
    logic signed [DSP_WIDTH-1:0] S_dsp [dsp_num];

    genvar d, e;

    generate
        for (d = 0; d < dsp_num; d++) begin : DSP_BLOCK

            localparam int BASE_INDEX =
                d * elem_dsp;

            localparam int ELEM_COUNT =
                (d == dsp_num-1) ? LAST_ELEM : elem_dsp;

            // ---------------------------------------------
            // Guard bit insertion + packing into 48-bit
            // ---------------------------------------------
            for (e = 0; e < ELEM_COUNT; e++) begin : PACK

                localparam int GLOBAL_INDEX = BASE_INDEX + e;

                assign A_dsp[d][e*GUARD_WIDTH +: GUARD_WIDTH] =
                        {add_sub_sel,A[GLOBAL_INDEX][WIDTH-1], A[GLOBAL_INDEX]};

                assign B_dsp[d][e*GUARD_WIDTH +: GUARD_WIDTH] =
                        {1'b0,B[GLOBAL_INDEX][WIDTH-1], B[GLOBAL_INDEX]};
            end

            // Zero unused bits in last DSP
            if (ELEM_COUNT*GUARD_WIDTH < DSP_WIDTH) begin : ZERO_PAD
                assign A_dsp[d][DSP_WIDTH-1 : ELEM_COUNT*GUARD_WIDTH] = '0;
                assign B_dsp[d][DSP_WIDTH-1 : ELEM_COUNT*GUARD_WIDTH] = '0;
            end

            // ---------------------------------------------
            // DSP instantiation
            // ---------------------------------------------
            `ifdef FPGA
                        c_addsub_48 add_acc_48 (
                            .A   (A_dsp[d]),
                            .B   (B_dsp[d]),
                            .ADD (!add_sub_sel),
                            .S   (S_dsp[d])
                        );
            `else
                        adder_sub #(
                            .WIDTH(DSP_WIDTH)
                        ) add_acc_48 (
                            .add_sub_sel(add_sub_sel),
                            .A   (A_dsp[d]),
                            .B   (B_dsp[d]),
                            .S   (S_dsp[d])
                        );
            `endif

            // ---------------------------------------------
            // Unpacking back to S[64]
            // ---------------------------------------------
            for (e = 0; e < ELEM_COUNT; e++) begin : UNPACK

                localparam int GLOBAL_INDEX = BASE_INDEX + e;

                assign S[GLOBAL_INDEX] =
                {
                    S_dsp[d][e*GUARD_WIDTH + WIDTH],
                    S_dsp[d][e*GUARD_WIDTH +: WIDTH]
                };

            end

        end
    endgenerate

endmodule