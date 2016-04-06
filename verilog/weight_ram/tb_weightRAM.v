module tb_sigmoid();
    
    parameter BITWIDTH = 18;
    parameter NCOLS    = 16;
    parameter NROWS    = 16;
    parameter OUTPUT_PORT_BITWIDTH = NROWS*BITWIDTH;
    parameter HALF_CLOCK = 100;
    parameter FULL_CLOCK = 2*HALF_CLOCK;
    parameter MAX_SAMPLES = NROWS;

    // DUT Connecting wires/regs
    reg  [4-1:0] address;
    wire [OUTPUT_PORT_BITWIDTH:0] result;

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
    /*initial begin
        $readmemb("goldenIN.hex", ROM_input);
        $readmemb("sigmoid_goldenOUT.hex", ROM_goldenOut);
        fid_error_dump = $fopen("error_dump.txt", "w");
        fid = $fopen("myout.hex", "w");
    end*/
    
    // DUT Instantiation
    weightRAM WRAM01 (address, clock, reset, result);  

    // Keeping track of the simulation time
    real time_start, time_end;
    integer i;

    // Running the simulation
    initial begin
        address <= 18'd0;
        time_start = $realtime;

        $display("Simulation started at %f", time_start);

        // Initializing the clock and applying the initial reset
        clock = 0;
        reset = 1;
        #(FULL_CLOCK*2)
        reset = 0;

        for(i=0; i < NROWS; i = i + 1) begin
            @(posedge clock);
            address <= address + 16'd1; 
            #(HALF_CLOCK);
            $display("%d\n", result[0:18]);
        end
        
        $stop;
    end
endmodule
            
    
        


