`timescale 1ns/1ps

module system_top_tb();

localparam int M = 96;
localparam int N = 64;
localparam int WIDTH = 18;
localparam int FL = 12;

localparam int NUM_TESTS = 5;   // number of testcases
localparam int LATENCY = 8;

localparam int ALPHA = $floor(0.1372 * (2**FL)*1.5); // log(N)/M ~ 0.1372 
localparam int THRESHOLD = $floor(0.2 * (2**FL)) ; // 0.2
int frame_id ;
    
    logic clk , rst_n ;
    logic  y_sign [96];
    logic signed [WIDTH-1:0] x_out [N];
    logic signed [WIDTH-1:0] x_expected [N];
    string filename_y = "../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/y_sign_fi_1.txt";
    string filename_x = "../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/x_final_1.txt";
    int passed , failed;
    logic y_frames   [NUM_TESTS][M];
    logic signed [WIDTH-1:0] x_frames [NUM_TESTS][N];



    system_top  u_system_top (
        .clk    (clk),
        .rst_n  (rst_n),
                .\y_sign[0] (y_sign[0]),
                .\y_sign[1] (y_sign[1]),
                .\y_sign[2] (y_sign[2]),
                .\y_sign[3] (y_sign[3]),
                .\y_sign[4] (y_sign[4]),
                .\y_sign[5] (y_sign[5]),
                .\y_sign[6] (y_sign[6]),
                .\y_sign[7] (y_sign[7]),
                .\y_sign[8] (y_sign[8]),
                .\y_sign[9] (y_sign[9]),
                .\y_sign[10] (y_sign[10]),
                .\y_sign[11] (y_sign[11]),
                .\y_sign[12] (y_sign[12]),
                .\y_sign[13] (y_sign[13]),
                .\y_sign[14] (y_sign[14]),
                .\y_sign[15] (y_sign[15]),
                .\y_sign[16] (y_sign[16]),
                .\y_sign[17] (y_sign[17]),
                .\y_sign[18] (y_sign[18]),
                .\y_sign[19] (y_sign[19]),
                .\y_sign[20] (y_sign[20]),
                .\y_sign[21] (y_sign[21]),
                .\y_sign[22] (y_sign[22]),
                .\y_sign[23] (y_sign[23]),
                .\y_sign[24] (y_sign[24]),
                .\y_sign[25] (y_sign[25]),
                .\y_sign[26] (y_sign[26]),
                .\y_sign[27] (y_sign[27]),
                .\y_sign[28] (y_sign[28]),
                .\y_sign[29] (y_sign[29]),
                .\y_sign[30] (y_sign[30]),
                .\y_sign[31] (y_sign[31]),
                .\y_sign[32] (y_sign[32]),
                .\y_sign[33] (y_sign[33]),
                .\y_sign[34] (y_sign[34]),
                .\y_sign[35] (y_sign[35]),
                .\y_sign[36] (y_sign[36]),
                .\y_sign[37] (y_sign[37]),
                .\y_sign[38] (y_sign[38]),
                .\y_sign[39] (y_sign[39]),
                .\y_sign[40] (y_sign[40]),
                .\y_sign[41] (y_sign[41]),
                .\y_sign[42] (y_sign[42]),
                .\y_sign[43] (y_sign[43]),
                .\y_sign[44] (y_sign[44]),
                .\y_sign[45] (y_sign[45]),
                .\y_sign[46] (y_sign[46]),
                .\y_sign[47] (y_sign[47]),
                .\y_sign[48] (y_sign[48]),
                .\y_sign[49] (y_sign[49]),
                .\y_sign[50] (y_sign[50]),
                .\y_sign[51] (y_sign[51]),
                .\y_sign[52] (y_sign[52]),
                .\y_sign[53] (y_sign[53]),
                .\y_sign[54] (y_sign[54]),
                .\y_sign[55] (y_sign[55]),
                .\y_sign[56] (y_sign[56]),
                .\y_sign[57] (y_sign[57]),
                .\y_sign[58] (y_sign[58]),
                .\y_sign[59] (y_sign[59]),
                .\y_sign[60] (y_sign[60]),
                .\y_sign[61] (y_sign[61]),
                .\y_sign[62] (y_sign[62]),
                .\y_sign[63] (y_sign[63]),
                .\y_sign[64] (y_sign[64]),
                .\y_sign[65] (y_sign[65]),
                .\y_sign[66] (y_sign[66]),
                .\y_sign[67] (y_sign[67]),
                .\y_sign[68] (y_sign[68]),
                .\y_sign[69] (y_sign[69]),
                .\y_sign[70] (y_sign[70]),
                .\y_sign[71] (y_sign[71]),
                .\y_sign[72] (y_sign[72]),
                .\y_sign[73] (y_sign[73]),
                .\y_sign[74] (y_sign[74]),
                .\y_sign[75] (y_sign[75]),
                .\y_sign[76] (y_sign[76]),
                .\y_sign[77] (y_sign[77]),
                .\y_sign[78] (y_sign[78]),
                .\y_sign[79] (y_sign[79]),
                .\y_sign[80] (y_sign[80]),
                .\y_sign[81] (y_sign[81]),
                .\y_sign[82] (y_sign[82]),
                .\y_sign[83] (y_sign[83]),
                .\y_sign[84] (y_sign[84]),
                .\y_sign[85] (y_sign[85]),
                .\y_sign[86] (y_sign[86]),
                .\y_sign[87] (y_sign[87]),
                .\y_sign[88] (y_sign[88]),
                .\y_sign[89] (y_sign[89]),
                .\y_sign[90] (y_sign[90]),
                .\y_sign[91] (y_sign[91]),
                .\y_sign[92] (y_sign[92]),
                .\y_sign[93] (y_sign[93]),
                .\y_sign[94] (y_sign[94]),
                .\y_sign[95] (y_sign[95]),
                .\x_out[0] (x_out[0]),
                .\x_out[1] (x_out[1]),
                .\x_out[2] (x_out[2]),
                .\x_out[3] (x_out[3]),
                .\x_out[4] (x_out[4]),
                .\x_out[5] (x_out[5]),
                .\x_out[6] (x_out[6]),
                .\x_out[7] (x_out[7]),
                .\x_out[8] (x_out[8]),
                .\x_out[9] (x_out[9]),
                .\x_out[10] (x_out[10]),
                .\x_out[11] (x_out[11]),
                .\x_out[12] (x_out[12]),
                .\x_out[13] (x_out[13]),
                .\x_out[14] (x_out[14]),
                .\x_out[15] (x_out[15]),
                .\x_out[16] (x_out[16]),
                .\x_out[17] (x_out[17]),
                .\x_out[18] (x_out[18]),
                .\x_out[19] (x_out[19]),
                .\x_out[20] (x_out[20]),
                .\x_out[21] (x_out[21]),
                .\x_out[22] (x_out[22]),
                .\x_out[23] (x_out[23]),
                .\x_out[24] (x_out[24]),
                .\x_out[25] (x_out[25]),
                .\x_out[26] (x_out[26]),
                .\x_out[27] (x_out[27]),
                .\x_out[28] (x_out[28]),
                .\x_out[29] (x_out[29]),
                .\x_out[30] (x_out[30]),
                .\x_out[31] (x_out[31]),
                .\x_out[32] (x_out[32]),
                .\x_out[33] (x_out[33]),
                .\x_out[34] (x_out[34]),
                .\x_out[35] (x_out[35]),
                .\x_out[36] (x_out[36]),
                .\x_out[37] (x_out[37]),
                .\x_out[38] (x_out[38]),
                .\x_out[39] (x_out[39]),
                .\x_out[40] (x_out[40]),
                .\x_out[41] (x_out[41]),
                .\x_out[42] (x_out[42]),
                .\x_out[43] (x_out[43]),
                .\x_out[44] (x_out[44]),
                .\x_out[45] (x_out[45]),
                .\x_out[46] (x_out[46]),
                .\x_out[47] (x_out[47]),
                .\x_out[48] (x_out[48]),
                .\x_out[49] (x_out[49]),
                .\x_out[50] (x_out[50]),
                .\x_out[51] (x_out[51]),
                .\x_out[52] (x_out[52]),
                .\x_out[53] (x_out[53]),
                .\x_out[54] (x_out[54]),
                .\x_out[55] (x_out[55]),
                .\x_out[56] (x_out[56]),
                .\x_out[57] (x_out[57]),
                .\x_out[58] (x_out[58]),
                .\x_out[59] (x_out[59]),
                .\x_out[60] (x_out[60]),
                .\x_out[61] (x_out[61]),
                .\x_out[62] (x_out[62]),
                .\x_out[63] (x_out[63])
                // .y_sign (y_sign),
                // .x_out      (x_out)
    );

    initial begin
        clk =0 ;
        forever begin
            #5 clk =~clk;
        end

    end

    initial begin 
        // preload all test vectors
        for(int t=0; t<NUM_TESTS; t++) begin
            filename_y = $sformatf("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/y_sign_fi_%0d.txt",t+1);
            filename_x = $sformatf("../Simple_DSP_Core_MATLAB/Image_Reconstruction/Matlab Vars/x_final_%0d.txt",t+1);

            load_input_data_y(.data_array(y_frames[t]),.num_values(M),.filename(filename_y));
            load_input_data(.data_array(x_frames[t]),.num_values(N),.filename(filename_x));
        end

        rst_n = 0;
        y_sign =  '{default: 0};
        repeat(5) @(negedge clk);
        rst_n = 1;
        //y_sign_in = y_frames[0];
        repeat(5) @(negedge clk);
        for(int cycle=0; cycle<NUM_TESTS+LATENCY; cycle++) begin

            // drive input
            
            if(cycle < NUM_TESTS)
                y_sign = y_frames[cycle];
            
            // check output
            @(negedge clk);
            if(cycle >= LATENCY) begin

                frame_id = cycle - LATENCY;

                for(int i=0;i<N;i++) begin
                    
                    if(x_out[i] == x_frames[frame_id][i])
                        passed++;
                    else begin
                        failed++;
                        $display("Frame %0d Index %0d Expected=%0d Got=%0d t=%0t",
                                frame_id,i,
                                x_frames[frame_id][i],
                                x_out[i],
                                $time);
                    end
                end

            end

        end
            $display("================================");
            $display("TOTAL PASSED = %0d",passed);
            $display("TOTAL FAILED = %0d",failed);
            $display("================================");
            repeat(10) @(negedge clk);
            $stop;

    end



task automatic load_input_data;
        output logic signed [WIDTH - 1 : 0] data_array []; // Contains fixed point Values and it's size depends on num_values  
        input string filename;
        input int num_values;
        
        integer file_handle; // to check if the file is exists or not in the current pre-specified location
        integer i;
        int float_value; // Float value out from matlab
        longint fixed_value; // Fixed value out from matlab
        
        // Dynamically allocate array
        data_array = new[num_values];  // Size of data_array
        
        
   
        
        file_handle = $fopen(filename, "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open file %s", filename);
            $finish();
        end
        
        i = 0;
        while (!$feof(file_handle) && i < num_values) begin
            if ($fscanf(file_handle, "%d", float_value) == 1) begin
                fixed_value = float_value;
                data_array[i] = fixed_value[WIDTH-1:0];
                

                i++;
                void'($fgetc(file_handle));
            end
        end
        
        $fclose(file_handle);

    endtask

    task automatic load_input_data_y;
        output logic  data_array []; // Contains fixed point Values and it's size depends on num_values  
        input string filename;
        input int num_values;
        
        integer file_handle; // to check if the file is exists or not in the current pre-specified location
        integer i;
        int float_value; // Float value out from matlab
        longint fixed_value; // Fixed value out from matlab
        
        // Dynamically allocate array
        data_array = new[num_values];  // Size of data_array
   
        file_handle = $fopen(filename, "r");
        if (file_handle == 0) begin
            $display("ERROR: Could not open file %s", filename);
            $finish();
        end
        
        i = 0;
        while (!$feof(file_handle) && i < num_values) begin
            if ($fscanf(file_handle, "%d", float_value) == 1) begin
                fixed_value = float_value;
                data_array[i] = fixed_value[WIDTH-1:0];
                

                i++;
                void'($fgetc(file_handle));
            end
        end
        
        $fclose(file_handle);

    endtask


endmodule