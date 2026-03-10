module multiplier 
#(
    parameter int WIDTH = 32 , 
    parameter int FL = 16  
)
(
    input  signed [WIDTH - 1  : 0] A,  
    input  signed [WIDTH - 1  : 0] B,
    output signed [2*WIDTH -1 : 0] mult_out 
);
    assign mult_out = (A * B) ;
endmodule
//assign {C[i][j],C[i][j+1],C[i+1][j],C[i+1][j+1]} = {{{{$clog2(O){winograd_bus[i][0][0][MUL_WIDTH]}},{winograd_bus[i][0][0]}}},{{{$clog2(O){winograd_bus[i][0][1][MUL_WIDTH]}},{winograd_bus[i][0][1]}}},{{{$clog2(O){winograd_bus[i][1][0][MUL_WIDTH]}},{winograd_bus[i][1][0]}}},{{{$clog2(O){winograd_bus[i][1][1][MUL_WIDTH]}},{winograd_bus[i][1][1]}}}};
    //assign {C[i][j],C[i][j+1],C[i+1][j],C[i+1][j+1]} = {winograd_bus[i][0][0],winograd_bus[i][0][1],winograd_bus[i][1][0],winograd_bus[i][1][1]};
