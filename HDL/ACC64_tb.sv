module ACC64_tb();

    parameter int M = 96;
    parameter int N = 64;
    parameter int WIDTH = 18;
    parameter int FL = 12;
    
    logic clk , rst_n ;
    logic  y_sign_in [96];
    logic signed [WIDTH-1:0] Z [N];
    logic signed [WIDTH-1:0] Z_expected [N];
    string filename_y = "y_sign_fi.txt";
    string filename_z = "Z.txt";
    int passed , failed;



    ACC64 #(
        .WIDTH (WIDTH),
        .FL    (FL),
        .N     (N)
    ) u_acc64 (
        .clk    (clk),
        .rst_n  (rst_n),
        .y_sign_in (y_sign_in),
        .Z      (Z)
    );

    initial begin
        clk =0 ;
        forever begin
            #5 clk =~clk;
        end

    end

    initial begin 
        rst_n = 0;
        y_sign_in =  '{default: 0};
        #50;
        rst_n = 1;
        load_input_data_y(.data_array(y_sign_in),.num_values(96),.filename(filename_y));
        load_input_data(.data_array(Z_expected),.num_values(64),.filename(filename_z));
        #100;
        for (int i =0; i<64; i++) begin
            if(Z[i] === Z_expected[i]) begin
                    passed++;
                end
                else begin
                    failed++;
                    $display("Expected = %p \n\n Found = %p",Z_expected[i],Z[i]);
                end
                
                
        end
        $display(" Simulatio Finished \n Test Pass = %p \n\n Test Fail = %p",passed,failed);
        #100;
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
        
        
        $display("Loading input data from: %s", filename);
        
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
                
                if (i < 3) begin
                    $display("  [%0d] Float: %f -> Fixed: %0d (0x%h)", 
                             i, float_value, data_array[i], data_array[i]);
                end
                i++;
                void'($fgetc(file_handle));
            end
        end
        
        $fclose(file_handle);
        $display("Loaded %0d values from %s", i, filename);
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
        
        
        $display("Loading input data from: %s", filename);
        
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
                
                if (i < 3) begin
                    $display("  [%0d] Float: %f -> Fixed: %0d (0x%h)", 
                             i, float_value, data_array[i], data_array[i]);
                end
                i++;
                void'($fgetc(file_handle));
            end
        end
        
        $fclose(file_handle);
        $display("Loaded %0d values from %s", i, filename);
    endtask


endmodule
