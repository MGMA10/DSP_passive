`timescale 1ns/1ps

module tb_row_impl_64;

    // -------------------------------------------------
    // Parameters
    // -------------------------------------------------
    localparam WIDTH = 2;
    localparam N     = 64;

    // -------------------------------------------------
    // DUT Signals
    // -------------------------------------------------
    logic add_sub_sel;

    logic signed [WIDTH-1:0] A [N];
    logic signed [WIDTH-1:0] B [N];

    logic signed [WIDTH:0]   S [N];

    // -------------------------------------------------
    // Expected results
    // -------------------------------------------------
    logic signed [WIDTH:0] expected [N];

    // -------------------------------------------------
    // Instantiate DUT
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
    // Test procedure
    // -------------------------------------------------
    integer i, test;

    initial begin

        $display("Starting Testbench");

        for (test = 0; test < 100; test++) begin

            // Random mode
            add_sub_sel = $urandom_range(0,1);

            // Random inputs
            for (i = 0; i < N; i++) begin
                A[i] = $urandom_range(-2,1);
                B[i] = $urandom_range(-2,1);
            end

            #1;

            // Expected calculation
            for (i = 0; i < N; i++) begin
                if (add_sub_sel)
                    expected[i] = A[i] - B[i];
                else
                    expected[i] = A[i] + B[i];
            end

            #1;

            // Compare
            for (i = 0; i < N; i++) begin
                if (S[i] !== expected[i]) begin
                    $display("ERROR test=%0d index=%0d A=%0d B=%0d mode=%0d expected=%0d got=%0d",
                        test, i, A[i], B[i], add_sub_sel, expected[i], S[i]);
                    
                end
                else
                $display("Pass");
            end

        end

        $display("All tests passed");
        $stop;

    end

endmodule