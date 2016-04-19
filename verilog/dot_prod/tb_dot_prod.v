`timescale 1ns / 1ps

module tb_dot_prod();
    
    // User defined parameters
    parameter NROW = 16;
    parameter NCOL = 8;
    parameter QN   = 6;
    parameter QM   = 11;
    parameter DSP48_PER_ROW    = 4; 
    
    // Dependent Parameters
    parameter BITWIDTH = QN + QM + 1;
    parameter MEMORY_BITWIDTH  = BITWIDTH*NROW;
    parameter LAYER_BITWIDTH  = BITWIDTH*NCOL;  
	parameter ADDR_BITWIDTH         = $ln(NCOL)/$ln(2);
    parameter HALF_CLOCK = 1;
    parameter FULL_CLOCK = 2*HALF_CLOCK;
    parameter MAX_SAMPLES = 1;

    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input     [0:NCOL-1];   
    reg  [BITWIDTH-1:0] ROM_goldenOut [0:MAX_SAMPLES-1];   

    // DUT Connecting wires/regs
    wire [MEMORY_BITWIDTH-1:0]   weightMemOutput;
    wire [ADDR_BITWIDTH-1:0]     colAddress;
    wire [MEMORY_BITWIDTH-1:0]   outputVec;
    wire dataReady;
    reg clock;
    reg reset;
    reg signed [MEMORY_BITWIDTH-1:0] inputVecRAM;
    reg signed [BITWIDTH-1:0] inputVec;

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    integer i;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        //for(i = 0; i < NCOL; i = i + 1) begin
            //inputVec <=  18'b00_0001_000_0000_0000;
       //end        
        
        $readmemb("goldenIn_x.bin", ROM_input);
        $readmemb("goldenOut.bin", ROM_goldenOut);
        fid_error_dump = $fopen("error_dump.txt", "w");
        fid = $fopen("myout.hex", "w");
        
    end
    
    // DUT Instantiation
    dot_prod   #(NROW,NCOL,QN,QM,DSP48_PER_ROW) DOTPROD  (weightMemOutput, inputVec, clock, reset, dataReady, colAddress, outputVec);  
    weightRAM  #(NROW,NCOL,BITWIDTH)            WRAM     (colAddress, clock, reset, weightMemOutput);
    
    always @(posedge clock) begin
        inputVec <= ROM_input[colAddress];
    end

    // Keeping track of the simulation time
    real time_start, time_end;

    // Running the simulation
    initial begin
        time_start = $realtime;

        $display("Simulation started at %f", time_start);

        // Initializing the clock and applying the initial reset
        clock = 1;
        reset = 1;
        #(FULL_CLOCK*2)
        reset = 0;

        for(i=0; i < MAX_SAMPLES; i = i + 1) begin
            @(posedge dataReady);
            #(HALF_CLOCK);
            $display("OUTPUT %b  ---- REAL %b\n", outputVec[17:0], ROM_goldenOut[0]);

            if (i % 1000 == 0) 
                $display("Simulated %d samples\n", i);
            
        end
        
        $stop;
    end
endmodule
            
    
        

