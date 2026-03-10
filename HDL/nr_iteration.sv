`include "config.svh"
// `define FPGA
module nr_iteration #(
    parameter int WIDTH = 32,
    parameter int FRAC  = 16
)(
    input  logic              clk,
    input  logic              rst_n,
    input  logic [WIDTH-1:0]  a_in, // Input 0.5a
    input  logic [WIDTH-1:0]  x0_in,     // Input x0
    output logic [WIDTH-1:0]  a_out,// Delayed 0.5a
    output logic [WIDTH-1:0]  x1_out     // Output x1
);

    // Constant 1.5 in Q16.16
    localparam logic [WIDTH-1:0] CONST_1_5 = (32'd1 << FRAC) | (32'd1 << (FRAC-1));

    // Internal pipeline signals
    logic [WIDTH-1:0] a_reg [0:3];
    logic [WIDTH-1:0] a_reg1; 
    logic [WIDTH-1:0] x_reg [0:3];
    logic [WIDTH-1:0] x_reg1;
    logic [WIDTH-1:0] mul1_res;
    logic [WIDTH-1:0] mul2_res;
    logic [WIDTH-1:0] sub_res;
    logic [2*WIDTH-1:0] final_mul_res_1;
    logic [WIDTH-1:0] final_mul_res;

    // --- Row 1: Delay Line for 0.5a ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            //for (int i=0; i<4; i++) a_reg[i] <= '0;
            a_reg1 <= '0;
        end else begin
            a_reg1 <= a_in;
            // a_reg[0] <= a_in;
            // a_reg[1] <= a_reg[0];
            // a_reg[2] <= a_reg[1];
            // a_reg[3] <= a_reg[2];
            
        end
    end
    assign a_reg[1] = a_reg1; 
    assign a_reg[2] = a_reg[1];
    assign a_reg[3] = a_reg[2];


    // --- Row 2: Delay Line for x0 ---
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            //for (int i=0; i<4; i++) x_reg[i] <= '0;
            x_reg1 <= '0;
        end else begin
            x_reg1 <= x0_in;
            // x_reg[0] <= x0_in;
            // x_reg[1] <= x_reg[0];
            // x_reg[2] <= x_reg[1];
            // x_reg[3] <= x_reg[2];
        end
    end
    assign x_reg[1] = x_reg1;
    assign x_reg[2] = x_reg[1];
    assign x_reg[3] = x_reg[2];


    // --- Mathematical Operations (Instantiating Multiplier Modules) ---

    // Stage 1: Compute x0 * x0
    // Based on the diagram, this happens right after the first Reg of x0
    fp_mul #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) MUL_1 (
        .clk(clk),
        .a(x_reg1), 
        .b(x_reg1),
        .product(mul1_res)
    );

    // Stage 2: Compute (x0^2) * 0.5a
    // The diagram shows this input coming from the 3rd register stage of 0.5a
    fp_mul #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) MUL_2 (
        .clk(clk),
        .a(mul1_res ),
        .b(a_reg[1]), 
        .product(mul2_res)
    );

    // Stage 3: Subtraction 1.5 - (0.5a * x0^2)
    // Pipelined subtraction to maintain timing closure
    // always_ff @(posedge clk or negedge rst_n) begin
    //     if (!rst_n) sub_res <= '0;
    //     else        sub_res <= CONST_1_5 - mul2_res;
    // end

    assign sub_res = CONST_1_5 - mul2_res;


    // Stage 4: Final Refinement x1 = x0 * (1.5 - 0.5a * x0^2)
    // x_reg[3] is used here to align with the latency of the multiplication/subtraction path
    /*fp_mul #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) MUL_3 (
        .clk(clk),
        .a(x_reg[3]),
        .b(sub_res),
        .product(final_mul_res)
    );*/


		    `ifdef FPGA
		        mult_gen_0 mul (
		            .A(x_reg[3]),
		            .B(sub_res),
		            .P(final_mul_res_1)
		        );
		    `else
		        multiplier #(
		            .WIDTH(WIDTH),
                    .FL(FRAC)    
		        ) mul (
		            .A(x_reg[3]),
		            .B(sub_res),
		            .mult_out(final_mul_res_1)
		        );
		    `endif

 assign final_mul_res = final_mul_res_1[FRAC +: WIDTH];

    // --- Final Output Assignments ---
    // The x1 output has one final register in the diagram 
    /*always_ff @(posedge clk or negedge rst_n) begin //TODO : Remove it 
        if (!rst_n) x1_out <= '0;
        else        x1_out <= final_mul_res;
    end*/
    assign x1_out = final_mul_res;
    assign a_out = a_reg[3];

endmodule