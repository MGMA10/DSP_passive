//`include "config.svh"
`define FPGA
module passive_top_tb ();


localparam number_of_tests = 1;
localparam int M = 96;
localparam int N = 64;
localparam int WIDTH = 18;
localparam int FL = 12;

localparam int ALPHA = $floor(0.1372 * (2**FL)*1.5); // log(N)/M ~ 0.1372 
localparam int THRESHOLD = $floor(0.2 * (2**FL)) ; // 0.2

bit clk , rst_n;
logic signed [WIDTH -1:0] Z [N];
logic signed [WIDTH -1:0] x [N];

// All the reference arrays should be constructed as 3D arrays to use the `load_input` task correctly
logic signed [WIDTH-1:0] Z_in [number_of_tests][N];
logic signed [WIDTH-1:0] x_ref [number_of_tests][N];
logic signed [WIDTH-1:0] x_soft_ref [number_of_tests][N];
logic signed [WIDTH-1:0] norm_sq_ref [number_of_tests][1];
logic signed [WIDTH-1:0] rsqrt_ref [number_of_tests][1];


int passed , failed;

passive_top #(
    .M(M),
    .N(N),
    .WIDTH(WIDTH),
    .FL(FL),
    .THRESHOLD(THRESHOLD),
    .ALPHA(ALPHA)
    ) PASSIVE_ALG (
    .clk(clk),
    .rst_n(rst_n),
    .Z(Z),
    .x_out(x));

always begin
    #5 clk = ~clk;
end

task automatic load_data(
    input int tests ,
    input int size,
    output logic signed [WIDTH - 1: 0] data [][],
    input int fid
);

    int i = 0; // Iterating over the tests
    int j = 0; // iterating over the elements of same test

    if(!(fid)) begin
        $display("Can't open the text file\n");
        $stop;
    end

    data = new[tests];
    foreach(data[k]) data[k] = new[size]; 

    while($fscanf(fid,"%d\n",data[i][j])==1) begin
        if((++j) == N) begin
            i++;
            j = 0;
        end
    end
    
endtask


initial begin
    // automatic int fid0 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/alpha.txt","r");
    automatic int fid1 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/Z.txt","r");
    automatic int fid2 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/x_final.txt","r");
    automatic int fid3 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/x_after_threshold.txt","r");
    automatic int fid4 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/x_sum.txt","r");
    automatic int fid5 = $fopen("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/rsqrt_x.txt","r");

    
    // Load the data from the text files 

    // load_data(.tests(1),.size(1),.data(ALPHA_ref),.fid(fid0));
    load_data(.tests(number_of_tests),.size(N),.data(Z_in),.fid(fid1));
    load_data(.tests(number_of_tests),.size(N),.data(x_ref),.fid(fid2));
    load_data(.tests(number_of_tests),.size(N),.data(x_soft_ref),.fid(fid3));
    load_data(.tests(number_of_tests),.size(1),.data(norm_sq_ref),.fid(fid4));
    load_data(.tests(number_of_tests),.size(1),.data(rsqrt_ref),.fid(fid5));
    
    // Reset the Input(s)
    foreach(Z[i]) Z[i] = 0;
    
    rst_n = 0;
    repeat(3) @(negedge clk);
    rst_n = 1;
    @(posedge clk);

    // for ( int i = 0 ; i < number_of_tests ; i++ ) begin
    //     Z = Z_in[i];
    //     repeat(100) @(negedge clk); // System Initial Latency
    //     if(x_ref[i] === x) begin
    //         passed++;
    //     end
    //     else begin
    //         failed++;
    //         $display("Expected = %p \n\n Found = %p",x_ref[i],x);
    //     end
    // end

    fork
        begin : INPUT_THREAD
            for (int i=0; i < number_of_tests; i++) begin
                Z <= Z_in[i];
                @(posedge clk);
            end
        end

        begin : OUT_MONITOR_THREAD
            for (int i=0; i< number_of_tests; i++) begin
                repeat(27)@(posedge clk);
                if(x_ref[i] === x) begin
                    passed++;
                end
                else begin
                    failed++;
                    $display("Expected = %p \n\n Found = %p",x_ref[i],x);
                end
            end
        end
    join

    $display("\nTest ended with %0d passed & %0d failed\n",passed,failed);
    $stop;

end

endmodule 