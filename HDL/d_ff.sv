
module d_ff #(
    parameter  DATA_WIDTH = 32   
)(
    input  logic                        clk,
    input  logic                        rst_n,
    input  logic [DATA_WIDTH-1:0]       d_in,
    output logic [DATA_WIDTH-1:0]       d_out
);

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        d_out   <= '0;
    end else begin
        d_out <= d_in;
    end
end

endmodule
