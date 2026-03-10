`include "config.svh"
// `define FPGA
module passive_top #(
    parameter int M = 96,
    parameter int N = 64,
    parameter int WIDTH = 18,
    parameter int FL = 12,
    parameter int ALPHA = 842,
    parameter int THRESHOLD = 1
)(
    input clk , rst_n ,
    input  signed [WIDTH -1:0] Z [N],
    output logic signed [WIDTH -1:0] x_out [N]
);

    // --------------------------------------------------
    // Phi_var matrix (example placeholder)
    // --------------------------------------------------
    //`include "Phi.svh"
    // localparam real ALPHA = $sqrt($log10((N)) / (M));
    localparam int s = 6;
    //logic signed [WIDTH -1:0] Z [N];
    logic signed [WIDTH -1:0] Z_in [N];
    logic signed [WIDTH -1:0] Z_1 [N];
    logic signed [WIDTH -1:0] Z_2 [N];
    logic signed Z_3 [N];
    logic signed [WIDTH -1+1:0] x_soft_1 [N];
    logic signed [WIDTH -1:0] x_soft_in [N];
    logic signed [WIDTH -1:0] x_soft [N];
    logic signed [WIDTH -1:0] x_soft_b2 [N][s];
    logic signed [WIDTH -1:0] x_norm [N];
    logic signed [WIDTH -1:0] r_norm_l2;
    logic signed [2*WIDTH-1:0] Mul_res_1[N];
    logic signed [WIDTH-1:0] Mul_res[N];
    logic signed [WIDTH -1:0] x [N];
    
    // --------------------------------------------------
    // Z = (1/M) * Phi_var' * y_sign
    // --------------------------------------------------
/*    genvar j, i;
    generate
        for (j = 0; j < N; j++) begin : Z_GEN
            logic signed [WIDTH -1:0] acc;
            always_comb begin
                acc = '0;
                for (i = 0; i < M; i++) begin
                    acc += (y_sign[i] ? -Phi_var[i][j] : Phi_var[i][j]);
                end
                Z[j] = acc;
            end
        end
    endgenerate
*/

    // TODO : Can be removed 
    generate 
            for (genvar j = 0; j < N; j++) begin : ff_input_instans
    d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (Z[j]),
            .d_out (Z_in[j])
        );
        end
    endgenerate 
    // --------------------------------------------------
    // Soft threshold
    // --------------------------------------------------
    generate 
        for (genvar j = 0; j < N; j++) begin : soft_threshold_abs
            always_comb begin
                    if (Z_in[j] > ALPHA)
                            Z_1[j] = Z_in[j];
                    else if (Z_in[j] < -ALPHA)
                            Z_1[j] = -Z_in[j];
                    else
                            Z_1[j] = ALPHA[0+:WIDTH];
                end 

            end
    endgenerate 
    // --------------------------------------------------
    // ff_med_instans
    // --------------------------------------------------
    generate 
        for (genvar j = 0; j < N; j++) begin : ff_med1_instans
            /*d_ff #(
                    .DATA_WIDTH(WIDTH)
                ) D1 (
                    .clk   (clk),
                    .rst_n (rst_n),
                    .d_in  (Z_1[j]),
                    .d_out (Z_2[j])
            );*/
            assign Z_2[j] = Z_1[j];
        end
       
    endgenerate 

    // --------------------------------------------------
    // ff_med_instans
    // --------------------------------------------------
    generate 
        for (genvar j = 0; j < N; j++) begin : ff_med2_instans
            /*d_ff #(
                    .DATA_WIDTH(1)
                ) D1 (
                    .clk   (clk),
                    .rst_n (rst_n),
                    .d_in  (Z_in[j][WIDTH-1]),
                    .d_out (Z_3[j])
            );*/
            assign Z_3[j] = Z_in[j][WIDTH-1];
        end
    endgenerate 
    // --------------------------------------------------
    // soft_threshold_sub
    // --------------------------------------------------        

    generate
            for (genvar j = 0; j < N; j++) begin : soft_threshold_sub
                    `ifdef FPGA
                        c_addsub_0 x_soft_calc_all (
                        .A  (Z_2[j]),
                        .B  (ALPHA[0+:WIDTH]),
                        .ADD(!1'b1),
                        .S  (x_soft_1[j])
                        );
                    `else
                        adder_sub #(
                        .WIDTH(WIDTH)
                        ) add_acc_32 (
                        .add_sub_sel(1'b1),
                        .A  (Z_2[j]),
                        .B  (ALPHA[0+:WIDTH]),
                        .S  (x_soft_1[j])
                        );
                    `endif
                assign x_soft_in[j] = (Z_3[j])? -x_soft_1[j][0 +: WIDTH] : x_soft_1[j][0 +: WIDTH] ;
            end
    endgenerate
    // --------------------------------------------------
    // 
    // --------------------------------------------------

    generate 
            for (genvar j = 0; j < N; j++) begin : ff_1_instans
    /*d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (x_soft_in[j]),
            .d_out (x_soft[j])
        );*/
        assign x_soft[j] = x_soft_in[j];
            end
    endgenerate 

    // --------------------------------------------------
    // L2 norm
    // --------------------------------------------------
    norm_l2_vec #(
        .WIDTH(WIDTH),
        .FL(FL),
        .N(N)
    ) U_L2 (
        .clk(clk) , 
        .rst_n(rst_n) ,
        .v(x_soft),
        .r_sqrt(r_norm_l2)
    );

    // --------------------------------------------------
    // 
    // --------------------------------------------------
    generate 
            for (genvar j = 0; j < N; j++) begin : ff_internal_instans
    d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (x_soft[j]),
            .d_out (x_soft_b2[j][0])
        );
            end

        for (genvar i = 0; i < s-1; i++) begin : ff_chain_instans
            for (genvar j = 0; j < N; j++) begin : ff_internal1_instans
        d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (x_soft_b2[j][i]),
            .d_out (x_soft_b2[j][i+1])
        );
            end
        end
        endgenerate 
    
    // --------------------------------------------------
    // Normalize and threshold
    // --------------------------------------------------


    generate    
		for (genvar i = 0; i < N; i++) begin : mul_array
		    `ifdef FPGA
		        mult_gen_0 mul (
		            .A(x_soft_b2[i][s-1][WIDTH -1:0]),
		            .B(r_norm_l2),
		            .P(Mul_res_1 [i])
		        );
		    `else
		        multiplier #(
		            .WIDTH(WIDTH),
                    .FL(FL)    
		        ) mul (
		            .A(x_soft_b2[i][s-1][WIDTH -1:0]),
		            .B(r_norm_l2),
		            .mult_out(Mul_res_1 [i])
		        );
		    `endif
            assign Mul_res [i] = Mul_res_1[i] [FL +: WIDTH];
		end
    endgenerate

    // --------------------------------------------------
    // 
    // --------------------------------------------------

    generate
        for (genvar j = 0; j < N; j++) begin

            always_comb begin
                if (r_norm_l2 != 0)
                    x_norm[j] = Mul_res[j] ;
                else
                    x_norm[j] = '0;
   
                if ((x_norm[j] < THRESHOLD) && (x_norm[j] > -THRESHOLD))
                    x[j] = '0;
                else
                    x[j] = x_norm[j];
            end
        end
    endgenerate

    // --------------------------------------------------
    // 
    // --------------------------------------------------

    generate 
            for (genvar j = 0; j < N; j++) begin : ff_output_instans
    d_ff #(
            .DATA_WIDTH(WIDTH)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (x[j]),
            .d_out (x_out[j])
        );
            end
    endgenerate 

endmodule


