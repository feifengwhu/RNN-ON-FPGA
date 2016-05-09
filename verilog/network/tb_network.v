`timescale 1ns / 1ps

module tb_network();
    
	parameter INPUT_SZ  = 2;
	parameter HIDDEN_SZ = 8;
	parameter OUTPUT_SZ = 1;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW_G = 2;
	parameter DSP48_PER_ROW_M = 2;
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter OUTPUT_BITWIDTH  = BITWIDTH*OUTPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 1;

	reg clock;
	reg reset;
    reg                       newSample;
    reg    			          dataReady;
    reg [INPUT_BITWIDTH-1:0]  inputVec;
    reg [OUTPUT_BITWIDTH-1:0] oututVec;
    
    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input;
    reg  [BITWIDTH-1:0] ROM_goldenOut;
    reg  [BITWIDTH-1:0] ROM_weights_Wz [0:HIDDEN_SZ-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Rz [0:HIDDEN_SZ-1] [0:HIDDEN_SZ-1];
	reg  [BITWIDTH-1:0] ROM_weights_Wi [0:HIDDEN_SZ-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Ri [0:HIDDEN_SZ-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Wf [0:HIDDEN_SZ-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Rf [0:HIDDEN_SZ-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Wo [0:HIDDEN_SZ-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Ro [0:HIDDEN_SZ-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_bz [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_bi [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_bf [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_bo [0:HIDDEN_SZ-1];
    
    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    integer i=0,j=0,k=0,l=0;
    real    quantError=0;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        $readmemb("weights_Wz.bin", ROM_weights_Wz);
        $readmemb("weights_Rz.bin", ROM_weights_Rz);
        $readmemb("weights_Wi.bin", ROM_weights_Wi);
        $readmemb("weights_Ri.bin", ROM_weights_Ri);
        $readmemb("weights_Wf.bin", ROM_weights_Wf);
        $readmemb("weights_Rf.bin", ROM_weights_Rf);
        $readmemb("weights_Wo.bin", ROM_weights_Wo);
        $readmemb("weights_Ro.bin", ROM_weights_Ro);
        $readmemb("weights_bz.bin", ROM_weights_bz);
        $readmemb("weights_bi.bin", ROM_weights_bi);
        $readmemb("weights_bf.bin", ROM_weights_bf);
        $readmemb("weights_bo.bin", ROM_weights_bo); 
    end
    
    // DUT Instantiation
    network              #(INPUT_SZ, HIDDEN_SZ, OUTPUT_SZ, QN, QM, DSP48_PER_ROW_G, DSP48_PER_ROW_M) 
			LSTM_LAYER    (inputVec, 1'b0, clock, reset, newSample, dataReady, outputVec);
    
    // Keeping track of the simulation time
    real time_start, time_end;

    always @(negedge clock) begin
        if( reset == 1'b1) begin
            inputVec   <= {INPUT_BITWIDTH{1'b0}};
        end
        else begin
            inputVec   <= ROM_input[i];
        end
    end

    // Running the simulation
    initial begin
        time_start = $realtime;

		// Applying the initial reset
		reset     = 1'b1;
		#(2*FULL_CLOCK);
		reset     = 1'b0;

		// Loading the weight memory
		
		// -------------------------

        $display("Simulation started at %f", time_start);

        for(i=0; i < MAX_SAMPLES; i = i + 1) begin
			
			// ---------- Applying a new input signal ---------- //
			
			@(posedge clock);
			$fscanf(fid_in,  "%b\n", inputVec);
			$fscanf(fid_out, "%b\n", ROM_goldenOut);
			
            newSample = 1'b1;
            #(FULL_CLOCK);
            newSample = 1'b0;
            
            // ------------------------------------------------- //
            
            // Waiting for the result
            @(posedge dataReady);
            
            #(HALF_CLOCK);
            $display("OUTP %b\nREAL %b", outputVec, ROM_goldenOut);
            
        end
       
        //$display("Average Quantization Error: %f", quantError/(MAX_SAMPLES*HIDDEN_SZ));
 
        $stop; 
    end
    
function integer log2;
    input [31:0] argument;
    integer i;
    begin
         log2 = -1;
         i = argument;  
         while( i > 0 ) begin
            log2 = log2 + 1;
            i = i >> 1;
         end
    end
endfunction
endmodule

    
endmodule
            
    
        

