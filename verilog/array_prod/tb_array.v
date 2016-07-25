`timescale 1ns / 1ps

module tb_array();

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
    parameter MAC_BITWIDTH          = (2*BITWIDTH+1);
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 8;
    parameter TRAIN_SAMPLES    = 1000;

	reg clock;
	reg reset;
	reg [BITWIDTH-1:0] expectedOutput;
    reg                       newSample;
    wire   			          dataReady;
    reg signed [LAYER_BITWIDTH-1:0] outputVec;
    reg [OUTPUT_BITWIDTH-1:0] test;
    reg  [LAYER_BITWIDTH-1:0] Wperceptron;
	wire  [ADDR_BITWIDTH-1:0] colAddrP;
    wire  [BITWIDTH-1:0] networkOutput;
    reg   [BITWIDTH-1:0] temp;
    reg   [BITWIDTH-1:0] doesntMakeSense;
    wire                 resetP;
    wire                 dataReadyP;
    reg	 enPerceptron;

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump, retVal;
    integer fid_X, fid_w, fid_y;
    integer i=0,j=0,k=0,l=0;
    real    quantError=0;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    assign resetP = reset || !enPerceptron;

    // DUT Instantiation
    array_prod #(HIDDEN_SZ, QN, QM)  PERCEPTRON  (Wperceptron, outputVec, clock, resetP, dataReadyP, networkOutput);

	always @(posedge dataReadyP) begin
	    quantError = quantError + ($signed(networkOutput) - $signed(temp) )/(2.0**QM);
	end
    // Keeping track of the simulation time
    real time_start, time_end;

	initial begin
		fid_X = $fopen("array_X.bin", "r");
		fid_w = $fopen("array_w.bin", "r");
		fid_y = $fopen("array_y.bin", "r");
	end

    // Running the simulation
    initial begin
        time_start = $realtime;
		clock = 0;
		newSample = 0;
		enPerceptron = 0;

		// Applying the initial reset
		reset     = 1'b1;
		#(2*FULL_CLOCK);
		reset     = 1'b0;

		// ----------------------------------------------------------------------------------------- //

        $display("Simulation started at %f", time_start);

		for(k=0; k < TRAIN_SAMPLES; k = k + 1) begin

			if(k % 100 == 0) begin
				$display("Input Sample %d", k);
			end

				// ---------- Applying a new input signal ---------- //

				@(posedge clock);
				for (l = 0; l < HIDDEN_SZ; l = l + 1) begin
					retVal = $fscanf(fid_X,  "%18b\n", temp);
					outputVec[l*BITWIDTH +: BITWIDTH]  = temp;
					retVal = $fscanf(fid_w,  "%18b\n", temp);
					Wperceptron[l*BITWIDTH +: BITWIDTH]  = temp;
				end
				retVal = $fscanf(fid_y,  "%18b\n", temp);

				// ------------------------------------------------- //

				#(FULL_CLOCK);
				enPerceptron = 1;
				@(posedge dataReadyP);
				#(FULL_CLOCK);
				enPerceptron = 0;

				#(FULL_CLOCK);
       end
       $display("Average Quantization Error: %f", quantError/(TRAIN_SAMPLES));

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
