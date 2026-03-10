// `timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
module adder_sub 
#(
    parameter int WIDTH = 32
)
(
    input                     add_sub_sel, // 0 if add , 1 if sub (!(NOT) of second (MSB)bit of cd_selector)
    input  signed [WIDTH-1:0] A,  
    input  signed [WIDTH-1:0] B,
    output signed [WIDTH:0]   S 
);

wire signed [WIDTH-1:0] adder_sub_in ;


assign adder_sub_in = (B ^ {(WIDTH){add_sub_sel}}) + add_sub_sel ;


adder #(WIDTH) adder_insta (A,adder_sub_in,S) ;


endmodule
