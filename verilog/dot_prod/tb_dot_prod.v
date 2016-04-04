module tb_sigmoid();
    
    parameter BITWIDTH = 18;
    parameter HALF_CLOCK = 100;
    parameter FULL_CLOCK = 2*HALF_CLOCK;
    parameter MAX_SAMPLES = 40961;
    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input     [0:MAX_SAMPLES-1];   
    reg  [BITWIDTH-1:0] ROM_goldenOut [0:MAX_SAMPLES-1];   

    // DUT Connecting wires/regs
    reg  [BITWIDTH-1:0] operand;
    wire [BITWIDTH-1:0] result;

    reg clock;
    reg reset;

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        $readmemb("goldenIN.hex", ROM_input);
        $readmemb("sigmoid_goldenOUT.hex", ROM_goldenOut);
        fid_error_dump = $fopen("error_dump.txt", "w");
        fid = $fopen("myout.hex", "w");
    end
    
    // DUT Instantiation
    sigmoid SIGMOID01 (operand, clock, reset, result);  

    // Keeping track of the simulation time
    real time_start, time_end;
    integer i;

    // Running the simulation
    initial begin
        operand <= 18'd0;
        time_start = $realtime;

        $display("Simulation started at %f", time_start);

        // Initializing the clock and applying the initial reset
        clock = 0;
        reset = 1;
        #(FULL_CLOCK*2)
        reset = 0;

        for(i=0; i < MAX_SAMPLES; i = i + 1) begin
            @(posedge clock);
            @(posedge clock);
            operand <= ROM_input[i];
            #(HALF_CLOCK);
            $fwrite(fid, "%d\n", result);
            if (i % 1000 == 0) 
                $display("Simulated %d samples\n", i);
            
        end
        
        $stop;
    end
endmodule
            
    
        


