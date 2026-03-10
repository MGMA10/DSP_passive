`include "config.svh"
// `define FPGA
module norm_l2_vec #(
    parameter int WIDTH = 32,
    parameter int FL = 16,
    parameter int N = 64
)(
    input clk , rst_n ,
    input  logic signed [WIDTH-1:0] v [N],
    output logic signed [WIDTH-1:0] r_sqrt
);
    logic signed [2*WIDTH-1:0] Mul_res[N];
    logic signed [WIDTH -1:0] acc_path_in [N];
    logic signed [WIDTH -1:0] acc_path [N];
    logic signed [WIDTH-1+1 : 0] stage1 [0:31];
    logic signed [WIDTH-1+1 : 0] stage2 [0:15]; 
    logic signed [WIDTH-1 : 0] stage2_out [0:15]; 
    logic signed [WIDTH-1+1 : 0] stage3 [0:7];  
    logic signed [WIDTH-1+1 : 0] stage4 [0:3];  
    logic signed [WIDTH-1 : 0] stage4_out [0:3]; 
    logic signed [WIDTH-1+1 : 0] stage5 [0:1];      
    logic signed [WIDTH -1+1:0] norm;
    logic signed [WIDTH -1:0] norm_out;



    

        // ===============================================================
		// Multipliers
		// ===============================================================
        generate    
            for (genvar i = 0; i < N; i++) begin : mul_array
                `ifdef FPGA
                    mult_gen_0 mul (
                        .A(v[i]),
                        .B(v[i]),
                        .P(Mul_res [i])
                    );
                `else
                    multiplier #(
                        .WIDTH(WIDTH),     // w+2 --> 34 bit 
                        .FL(FL)
                    ) mul (
                        .A(v[i]),
                        .B(v[i]),
                        .mult_out(Mul_res [i])
                    );
                `endif
                assign acc_path_in[i] = Mul_res[i][FL +: WIDTH];
            end
        endgenerate

        // --------------------------------------------------
        // 
        // --------------------------------------------------

        generate 
                for (genvar j = 0; j < N; j++) begin : ff_2_instans
        /*d_ff #(
                .DATA_WIDTH(WIDTH)
            ) D1 (
                .clk   (clk),
                .rst_n (rst_n),
                .d_in  (acc_path_in[j]),
                .d_out (acc_path[j])
            );*/
            assign acc_path[j] = acc_path_in[j];
                end
        endgenerate 
        
        // ===============================================================
		// ACC Chain 
		// ===============================================================

        generate
            for (genvar i = 0; i < 32; i++) begin : adders_acc_32

                `ifdef FPGA
                    c_addsub_0 add_acc_32 (
                    .A  (acc_path[2*i]),
                    .B  (acc_path[2*i+1]),
                    .ADD(!('0)),
                    .S  (stage1[i])
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_32 (
                    .add_sub_sel(('0)),
                    .A  (acc_path[2*i]),
                    .B  (acc_path[2*i+1]),
                    .S  (stage1[i])
                    );
                `endif

            end

            for (genvar i = 0; i < 16; i++) begin : adders_acc_16

                `ifdef FPGA
                    c_addsub_0 add_acc_16 (
                    .A  (stage1[2*i][WIDTH-1 : 0]),
                    .B  (stage1[2*i+1][WIDTH-1 : 0]),
                    .ADD(!('0)),
                    .S  (stage2[i])
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_16 (
                    .add_sub_sel(('0)),
                    .A  (stage1[2*i][WIDTH-1 : 0]),
                    .B  (stage1[2*i+1][WIDTH-1 : 0]),
                    .S  (stage2[i])
                    );
                `endif

            end 

        // --------------------------------------------------
        // 
        // --------------------------------------------------

        
                for (genvar j = 0; j < N/4; j++) begin : ff_mid1_instans
        /*d_ff #(
                .DATA_WIDTH(WIDTH)
            ) D1 (
                .clk   (clk),
                .rst_n (rst_n),
                .d_in  (stage2[j][WIDTH-1 : 0]),
                .d_out (stage2_out[j])
            );*/
            assign stage2_out[j] = stage2[j][WIDTH-1 : 0];

                end
     

        // --------------------------------------------------
        // 
        // --------------------------------------------------

            for (genvar i = 0; i < 8; i++) begin : adders_acc_8

                `ifdef FPGA
                    c_addsub_0 add_acc_8 (
                    .A  (stage2_out[2*i][WIDTH-1 : 0]),
                    .B  (stage2_out[2*i+1][WIDTH-1 : 0]),
                    .ADD(!('0)),
                    .S  (stage3[i])
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_0 (
                    .add_sub_sel(('0)),
                    .A  (stage2_out[2*i][WIDTH-1 : 0]),
                    .B  (stage2_out[2*i+1][WIDTH-1 : 0]),
                    .S  (stage3[i])
                    );
                `endif
            end

        

            for (genvar i = 0; i < 4; i++) begin : adders_acc_4

                `ifdef FPGA
                    c_addsub_0 add_acc_4 (
                    .A  (stage3[2*i][WIDTH-1 : 0]),
                    .B  (stage3[2*i+1][WIDTH-1 : 0]),
                    .ADD(!('0)),
                    .S  (stage4[i])
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_4 (
                    .add_sub_sel(('0)),
                    .A  (stage3[2*i][WIDTH-1 : 0]),
                    .B  (stage3[2*i+1][WIDTH-1 : 0]),
                    .S  (stage4[i])
                    );
                `endif
            end

        // --------------------------------------------------
        // 
        // --------------------------------------------------

        
                for (genvar j = 0; j < N/16; j++) begin : ff_mid2_instans
        d_ff #(
                .DATA_WIDTH(WIDTH)
            ) D1 (
                .clk   (clk),
                .rst_n (rst_n),
                .d_in  (stage4[j][WIDTH-1 : 0]),
                .d_out (stage4_out[j])
            );
            //assign stage4_out[j] = stage4[j][WIDTH-1 : 0];

                end
     

        // --------------------------------------------------
        // 
        // --------------------------------------------------

            for (genvar i = 0; i < 2; i++) begin : adders_acc_2

                `ifdef FPGA
                    c_addsub_0 add_acc_2 (
                    .A  (stage4_out[2*i][WIDTH-1 : 0]),
                    .B  (stage4_out[2*i+1][WIDTH-1 : 0]),
                    .ADD(!('0)),
                    .S  (stage5[i])
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_2 (
                    .add_sub_sel(('0)),
                    .A  (stage4_out[2*i][WIDTH-1 : 0]),
                    .B  (stage4_out[2*i+1][WIDTH-1 : 0]),
                    .S  (stage5[i])
                    );
                `endif

            end

                `ifdef FPGA
                    c_addsub_0 add_acc_1 (
                    .A  (stage5[0][WIDTH-1 : 0]),
                    .B  (stage5[1][WIDTH-1 : 0]),
                    .ADD(!('0)),
                    .S  (norm)
                    );
                `else
                    adder_sub #(
                        .WIDTH(WIDTH)
                    ) add_acc_1 (
                    .add_sub_sel(('0)),
                    .A  (stage5[0][WIDTH-1 : 0]),
                    .B  (stage5[1][WIDTH-1 : 0]),
                    .S  (norm)
                    );
                `endif

    endgenerate

        // --------------------------------------------------
        // 
        // --------------------------------------------------

        
        /*d_ff #(
                .DATA_WIDTH(WIDTH)
            ) D1 (
                .clk   (clk),
                .rst_n (rst_n),
                .d_in  (norm[WIDTH-1 : 0]),
                .d_out (norm_out)
            );*/
            assign norm_out = norm[WIDTH-1 : 0];
        
        
        // --------------------------------------------------
        // 
        // --------------------------------------------------

    rsr_top #(
        .WIDTH (WIDTH),
        .FL(FL)
    ) rsr_top_in (  
    .clk(clk) , 
    .rst_n(rst_n) ,
    .a_in(norm_out),
    .a_rsr(r_sqrt)
);
endmodule
