`timescale 1ns / 1ps

module tb_network();
    
	parameter INPUT_SZ  = 2;
	parameter HIDDEN_SZ = 8;
	parameter OUTPUT_SZ = 1;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW_G = 2;
	parameter DSP48_PER_ROW_M = 4;
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter OUTPUT_BITWIDTH  = BITWIDTH*OUTPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 8;
    parameter TRAIN_SAMPLES    = 1000;

	reg clock;
	reg reset;
    reg                       newSample;
    wire   			          dataReady;
    reg  [INPUT_BITWIDTH-1:0] inputVec;
    wire [LAYER_BITWIDTH-1:0] outputVec;
    reg [OUTPUT_BITWIDTH-1:0] test;
    reg   [BITWIDTH-1:0] temp;
    // File descriptors for the error/output dumps
    integer fid, fid_error_dump, retVal;
    integer fid_x, fid_Wz, fid_Wi, fid_Wf, fid_Wo, fid_Rz, fid_Ri, fid_Rf, fid_Ro, fid_bz, fid_bi, fid_bf, fid_bo;
    integer i=0,j=0,k=0,l=0;
    real    quantError=0;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end
    
    // DUT Instantiation
    network              #(INPUT_SZ, HIDDEN_SZ, OUTPUT_SZ, QN, QM, DSP48_PER_ROW_G, DSP48_PER_ROW_M) 
			LSTM_LAYER    (inputVec, 1'b0, clock, reset, newSample, dataReady, outputVec);
    
    // Keeping track of the simulation time
    real time_start, time_end;

	initial begin
		fid_x = $fopen("goldenIn_x.bin", "r");
		fid_Wz = $fopen("goldenIn_Wz.bin", "r");
		fid_Wi = $fopen("goldenIn_Wi.bin", "r");
		fid_Wf = $fopen("goldenIn_Wf.bin", "r");
		fid_Wo = $fopen("goldenIn_Wo.bin", "r");
		fid_Rz = $fopen("goldenIn_Rz.bin", "r");
		fid_Ri = $fopen("goldenIn_Ri.bin", "r");
		fid_Rf = $fopen("goldenIn_Rf.bin", "r");
		fid_Ro = $fopen("goldenIn_Ro.bin", "r");
		fid_bz = $fopen("goldenIn_bz.bin", "r");
		fid_bi = $fopen("goldenIn_bi.bin", "r");
		fid_bf = $fopen("goldenIn_bf.bin", "r");
		fid_bo = $fopen("goldenIn_bo.bin", "r");
		fid    = $fopen("output.bin", "w");
		
		// -------------------------------- Loading the weight memory ------------------------------- //
		for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wz, "%b\n", LSTM_LAYER.WRAM_Z_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Rz, "%b\n", LSTM_LAYER.WRAM_Z_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wi, "%b\n", LSTM_LAYER.WRAM_I_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Ri, "%b\n", LSTM_LAYER.WRAM_I_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wf, "%b\n", LSTM_LAYER.WRAM_F_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Rf, "%b\n", LSTM_LAYER.WRAM_F_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Wo, "%b\n", LSTM_LAYER.WRAM_O_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                retVal = $fscanf(fid_Ro, "%b\n", LSTM_LAYER.WRAM_O_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
			retVal = $fscanf(fid_bz, "%18b\n",temp);
			LSTM_LAYER.bZ[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bi, "%18b\n",temp);
			LSTM_LAYER.bI[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bf, "%18b\n",temp);
			LSTM_LAYER.bF[i*BITWIDTH +: BITWIDTH] = temp;
			
			retVal = $fscanf(fid_bo, "%18b\n",temp);
			LSTM_LAYER.bO[i*BITWIDTH +: BITWIDTH] = temp;
        end
		
	end
	
    // Running the simulation
    initial begin
        time_start = $realtime;
		clock = 0;
		newSample = 0;
		
		// Applying the initial reset
		reset     = 1'b1;
		#(2*FULL_CLOCK);
		reset     = 1'b0;

		// ----------------------------------------------------------------------------------------- //

        $display("Simulation started at %f", time_start);

		for(k=0; k < TRAIN_SAMPLES; k = k + 1) begin
			
			// Applying the initial reset
			reset     = 1'b1;
			#(2*FULL_CLOCK);
			reset     = 1'b0;
			
			if(k % 50 == 0) begin
				$display("Input Sample %d", k);
			end
			
			for(i=0; i < MAX_SAMPLES; i = i + 1) begin
				
				// ---------- Applying a new input signal ---------- //
				
				@(posedge clock);
				retVal = $fscanf(fid_x,  "%b\n", temp);
				inputVec[17:0]  = temp;
				retVal = $fscanf(fid_x,  "%b\n", temp);
				inputVec[35:18] = temp;
				//$fscanf(fid_out, "%b\n", ROM_goldenOut);
				//$display("Read: %b and %b", inputVec[17:0], inputVec[35:18]);
				
				newSample = 1'b1;
				#(FULL_CLOCK);
				newSample = 1'b0;
				
				// ------------------------------------------------- //
				
				// Waiting for the result
				@(posedge dataReady);
				
				#(3*HALF_CLOCK);
				
				for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
					//$display("Neuron[%0d]: %b", j, outputVec[j*BITWIDTH +: BITWIDTH]);
					$fwrite(fid, "%d\n", outputVec[j*BITWIDTH +: BITWIDTH]);
				end
				
			end
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
            
    
        

