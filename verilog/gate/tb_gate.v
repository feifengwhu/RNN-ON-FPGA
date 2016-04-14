`timescale 1ns / 1ps

module tb_dot_prod();
    
	parameter INPUT_SZ  = 8;
	parameter HIDDEN_SZ = 16;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW = 2;
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 1000;

    // The golden inputs/outputs ROM
    reg  [INPUT_BITWIDTH-1:0] ROM_input     [0:MAX_SAMPLES-1];   
    reg  [BITWIDTH-1:0]       ROM_goldenOut [0:MAX_SAMPLES-1];   

    // DUT Connecting wires/regs
	wire        [ADDR_BITWIDTH_X-1:0] colAddress_X;
	wire        [ADDR_BITWIDTH-1:0] colAddress_Y;
	wire       [LAYER_BITWIDTH-1:0] weightMem_X;
	wire       [LAYER_BITWIDTH-1:0] weightMem_Y;
    wire       [LAYER_BITWIDTH-1:0] gateOutput;
    wire                          	dataReady_gate;
    reg  						  	clock;
    reg  						  	reset;
    reg  						  	beginCalc;
    reg signed [LAYER_BITWIDTH-1:0] prevLayerOut ;
    reg signed [LAYER_BITWIDTH-1:0] inputVec;
	reg signed [BITWIDTH-1:0] inData;
	reg signed [BITWIDTH-1:0] prevOut;
	reg [LAYER_BITWIDTH-1:0]  biasVec;
    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    integer i,j;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        for(i = 0; i < MAX_SAMPLES; i = i + 1) begin
            for(j = 0; j < INPUT_SZ; j = j + 1) begin
				ROM_input[i][j*BITWIDTH +: BITWIDTH] <= 18'b00_0000_100_0000_0000;
			end
        end        
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            biasVec[i*BITWIDTH +: BITWIDTH] <= 18'b00_0000_000_0000_0001;
            prevLayerOut[i*BITWIDTH +: BITWIDTH] <= 18'b00_0000_100_0000_0000;
        end
        
        /*
        $readmemb("goldenIN.hex", ROM_input);
        $readmemb("sigmoid_goldenOUT.hex", ROM_goldenOut);
        fid_error_dump = $fopen("error_dump.txt", "w");
        fid = $fopen("myout.hex", "w");
        */
    end
    
    // DUT Instantiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE (ROM_input[0][0+:18], prevLayerOut[0+:18], weightMem_X, weightMem_Y, biasVec, beginCalc,
														     clock, reset, colAddress_X, colAddress_Y, dataReady_gate, gateOutput);
    weightRAM  #(HIDDEN_SZ, INPUT_SZ, BITWIDTH)  WRAM_X (colAddress_X, clock, reset, weightMem_X);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH) WRAM_Y (colAddress_Y, clock, reset, weightMem_Y);
    
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
        
        beginCalc = 1;
		#(FULL_CLOCK);
		beginCalc = 0;
		
        for(i=0; i < 500; i = i + 1) begin
            @(posedge dataReady_gate);
            #(HALF_CLOCK);
            $display("OUTPUT %d\n", gateOutput[17:0]);

            if (i % 100 == 0) 
                $display("Simulated %d samples\n", i);
            
        end
        
        $stop;
    end
endmodule
            
    
        

