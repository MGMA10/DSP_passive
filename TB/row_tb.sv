`timescale 1ns/1ps
`include "config.svh"

module tb_row_impl_64;

    // -------------------------------------------------
    // Parameters (must match DUT)
    // -------------------------------------------------
    parameter int WIDTH = 3;

    // -------------------------------------------------
    // DUT Signals
    // -------------------------------------------------
    logic add_sub_sel;

    logic signed [WIDTH-1:0] A [64];
    logic signed [WIDTH-1:0] B [64];

    logic signed [WIDTH:0] S [64];

    // reference model
    logic signed [WIDTH:0] S_ref [64];

    // -------------------------------------------------
    // DUT Instantiation
    // -------------------------------------------------
    row_impl_64 #(
        .WIDTH(WIDTH)
    ) dut (
        .add_sub_sel(add_sub_sel),
        .A(A),
        .B(B),
        .S(S)
    );

    // -------------------------------------------------
    // Task : Generate Random Inputs
    // -------------------------------------------------
    task gen_inputs();
        foreach(A[i]) begin
            A[i] = $urandom_range(-2, 1);
            B[i] = $urandom_range(-2, 1);
        end
    endtask


    // -------------------------------------------------
    // Task : Reference Model
    // -------------------------------------------------
    task compute_reference();
        foreach(A[i]) begin
            if(add_sub_sel)
                S_ref[i] = A[i] - B[i];
            else
                S_ref[i] = A[i] + B[i];
        end
    endtask


    // -------------------------------------------------
    // Task : Checker
    // -------------------------------------------------
    task check_results();
        foreach(S[i]) begin
            if(S[i] !== S_ref[i]) begin
                $display("ERROR index=%0d A=%0d B=%0d DUT=%0d REF=%0d",
                         i, A[i], B[i], S[i], S_ref[i]);
            end
        end
    endtask


    // -------------------------------------------------
    // Test Sequence
    // -------------------------------------------------
    initial begin

        $display("---- START TEST ----");

        repeat(100) begin

            gen_inputs();

            // test addition
            add_sub_sel = 0;
            #1;
            compute_reference();
            check_results();

            // test subtraction
            add_sub_sel = 1;
            #1;
            compute_reference();
            check_results();

        end

        $display("---- TEST FINISHED ----");
        $finish;

    end

endmodule