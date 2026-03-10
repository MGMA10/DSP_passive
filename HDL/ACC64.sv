`include "config.svh"
// `define FPGA
 (* DONT_TOUCH = "TRUE" *)
module ACC64 #(
    parameter int WIDTH = 18,
    parameter int FL = 12,
    parameter int N = 64
)(
    input clk , rst_n ,
    input  logic  y_sign_in [96],
    output logic signed [WIDTH-1:0] Z [N]
);

localparam int phi_width = 2;
`include "Phi.svh"
logic  y_sign [96];
logic signed [phi_width : 0] stage1 [48] [N];
logic signed [phi_width+1 : 0] stage2 [24] [N]; 
logic signed [phi_width+2 : 0] stage3 [12] [N];
logic signed [phi_width+3 : 0] stage4 [6]  [N]; 
logic signed [phi_width+4 : 0] stage5 [3]  [N];
logic signed [phi_width+5 : 0] stage6      [N]; 
logic signed [phi_width+6 : 0] stage7      [N];
logic signed [phi_width+7 : 0] stage8      [N]; 

logic                add_sub_sel_l1      [48]; 
logic                add_sub_sel_l2      [24]; 
logic                add_sub_sel_l3      [12]; 
logic                add_sub_sel_l4      [6] ; 
logic                add_sub_sel_l5      [3] ; 
logic                add_sub_sel_l6          ; 
logic                add_sub_sel_l7          ; 
logic                add_sub_sel_l8          ; 


generate 
            for (genvar j = 0; j < 96; j++) begin : ff_input_instans
    d_ff #(
            .DATA_WIDTH(1)
        ) D1 (
            .clk   (clk),
            .rst_n (rst_n),
            .d_in  (y_sign_in[j]),
            .d_out (y_sign[j])
        );
        end
    endgenerate 


generate
        for (genvar i = 0; i < 48; i++) begin : ACC_SIGN_XOR1
            assign add_sub_sel_l1 [i] = y_sign[2*(i)] ^ y_sign[2*(i)+1];
        end

        for (genvar i = 0; i < 24; i++) begin : ACC_SIGN_XOR2
            assign add_sub_sel_l2 [i] = y_sign[4*(i)] ^ y_sign[4*(i)+2];
        end

        for (genvar i = 0; i < 12; i++) begin : ACC_SIGN_XOR3
            assign add_sub_sel_l3 [i] = y_sign[8*(i)] ^ y_sign[8*(i)+4];
        end

        for (genvar i = 0; i < 6; i++) begin : ACC_SIGN_XOR4
            assign add_sub_sel_l4 [i] = y_sign[16*(i)] ^ y_sign[16*(i)+8];
        end

        for (genvar i = 0; i < 3; i++) begin : ACC_SIGN_XOR5
            assign add_sub_sel_l5 [i] = y_sign[32*(i)] ^ y_sign[32*(i)+16];
        end

            assign add_sub_sel_l6  = y_sign[0] ^ y_sign[32];

            assign add_sub_sel_l7  = y_sign[0] ^ y_sign[64];

            assign add_sub_sel_l8  =  y_sign[0];
endgenerate

logic signed [8:0] zero_stage [N];

generate
    for(genvar i=0;i<N;i++)
        assign zero_stage[i] = '0;
endgenerate

logic signed [7:0] stage5_ext [N];

generate
    for (genvar i = 0; i < N; i++) begin
        assign stage5_ext[i] =
            {stage5[2][i][6], stage5[2][i]};
    end
endgenerate


 
///////////////////////////////////////////////
/////////////////  Level 1  //////////////////
/////////////////////////////////////////////

    generate
                for (genvar i = 0; i < 48; i++) begin : add_sub_livel1

                        row_impl_64 #(
                            .WIDTH(2),
                            .dsp_num(6),
                            .elem_dsp(12)
                        ) add_sub64_livel1 (
                        .add_sub_sel((add_sub_sel_l1[i])),     // 1 bit
                        .A  (Phi_var [2*i]),                // WIDTH
                        .B  (Phi_var [2*i+1]),              // WIDTH
                        .S  (stage1[i])                     // WIDTH +1
                        );
                    

                end
    endgenerate


///////////////////////////////////////////////
/////////////////  Level 2  //////////////////
/////////////////////////////////////////////

        generate
                for (genvar i = 0; i < 24; i++) begin : add_sub_livel2

                        row_impl_64 #(
                            .WIDTH(3),
                            .dsp_num(8),
                            .elem_dsp(9)
                        ) add_sub64_livel2 (
                        .add_sub_sel((add_sub_sel_l2[i])),     // 1 bit
                        .A  (stage1[2*i]),                  // WIDTH
                        .B  (stage1[2*i+1]),                // WIDTH
                        .S  (stage2[i])                     // WIDTH +1
                        );
                    

                end
    endgenerate


///////////////////////////////////////////////
/////////////////  Level 3  //////////////////
/////////////////////////////////////////////

        generate
                for (genvar i = 0; i < 12; i++) begin : add_sub_livel3

                        row_impl_64 #(
                            .WIDTH(4),
                            .dsp_num(8),
                            .elem_dsp(8)
                        ) add_sub64_livel3 (
                        .add_sub_sel((add_sub_sel_l3[i])),     // 1 bit
                        .A  (stage2[2*i]),                  // WIDTH
                        .B  (stage2[2*i+1]),                // WIDTH
                        .S  (stage3[i])                     // WIDTH +1
                        );
                    

                end
    endgenerate


///////////////////////////////////////////////
/////////////////  Level 4  //////////////////
/////////////////////////////////////////////

        generate
                for (genvar i = 0; i < 6; i++) begin : add_sub_livel4

                        row_impl_64 #(
                            .WIDTH(5),
                            .dsp_num(11),
                            .elem_dsp(6)
                        ) add_sub64_livel4 (
                        .add_sub_sel((add_sub_sel_l4[i])),     // 1 bit
                        .A  (stage3[2*i]),                  // WIDTH
                        .B  (stage3[2*i+1]),                // WIDTH
                        .S  (stage4[i])                     // WIDTH +1
                        );
                    

                end
    endgenerate

///////////////////////////////////////////////
/////////////////  Level 5  //////////////////
/////////////////////////////////////////////

        generate
                for (genvar i = 0; i < 3; i++) begin : add_sub_livel5

                        row_impl_64 #(
                            .WIDTH(6),
                            .dsp_num(11),
                            .elem_dsp(6)
                        ) add_sub64_livel5 (
                        .add_sub_sel((add_sub_sel_l5[i])),         // 1 bit
                        .A  (stage4[2*i]),                      // WIDTH
                        .B  (stage4[2*i+1]),                    // WIDTH
                        .S  (stage5[i])                         // WIDTH +1
                        );
                    

                end
    endgenerate


///////////////////////////////////////////////
/////////////////  Level 6  //////////////////
/////////////////////////////////////////////


                        row_impl_64 #(
                            .WIDTH(7),
                            .dsp_num(13),
                            .elem_dsp(5)
                        ) add_sub64_livel6 (
                        .add_sub_sel((add_sub_sel_l6)),         // 1 bit
                        .A  (stage5[0]),                        // WIDTH
                        .B  (stage5[1]),                        // WIDTH
                        .S  (stage6)                            // WIDTH +1
                        );
                    



///////////////////////////////////////////////
/////////////////  Level 7  //////////////////
/////////////////////////////////////////////


                        row_impl_64 #(
                            .WIDTH(8),
                            .dsp_num(16),
                            .elem_dsp(4)
                            
                        ) add_sub64_livel7 (
                        .add_sub_sel((add_sub_sel_l7)),         // 1 bit
                        .A  (stage6),                           // WIDTH
                        .B  (stage5_ext),                        // WIDTH
                        .S  (stage7)                            // WIDTH +1
                        );
                    




///////////////////////////////////////////////
/////////////////  Level 8  //////////////////
/////////////////////////////////////////////

       
                        row_impl_64 #(
                            .WIDTH(9),
                            .dsp_num(16),
                            .elem_dsp(4)
                        ) add_sub64_livel8 (
                        .add_sub_sel((add_sub_sel_l8)),         // 1 bit
                        .A  (zero_stage),                           // WIDTH
                        .B  (stage7),                               // WIDTH
                        .S  (stage8)                            // WIDTH +1
                        );
                    

    generate
        for (genvar i = 0; i < N; i++) begin : Assign_Output
            assign Z[i] = {stage8[i][9],stage8[i][9],stage8[i],6'b0};
        end
    endgenerate

endmodule