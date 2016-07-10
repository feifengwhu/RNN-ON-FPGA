`timescale 1ns / 1ps

module tb_network();

	parameter INPUT_SZ  = 2;
	parameter HIDDEN_SZ = 8;
	parameter OUTPUT_SZ = 1;
	parameter QN = 6;
  parameter QM = 11;
	parameter DSP48_PER_ROW_G = 2;
	parameter DSP48_PER_ROW_M = 4;
	parameter real e = 2.718281828459045;

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
	parameter TRAIN_SAMPLES    = 200000;

	reg clock;
	reg reset;
  reg                        newSample;
  wire   			           dataReady;
  reg  [INPUT_BITWIDTH-1:0]  inputVec;
  wire [LAYER_BITWIDTH-1:0]  outputVec;
  reg  [OUTPUT_BITWIDTH-1:0] test;
  reg  [BITWIDTH-1:0]        temp;
  reg 					    resetRAM;
  reg  [LAYER_BITWIDTH-1:0]  Wperceptron;
  reg  [LAYER_BITWIDTH-1:0]  Wperceptron_p;
  reg  [LAYER_BITWIDTH-1:0]  Wperceptron_IN;
  wire  [BITWIDTH-1:0]       networkOutput;
  wire                       resetP;
  wire                       dataReadyP;
  wire                       trainingReady;
  reg	 enPerceptron;
  reg  modelOutput;
  reg signed [BITWIDTH-1:0] costFunc;
  reg [BITWIDTH-1:0] wmax;
  //reg [2*BITWIDTH-1:0] costFuncIntermediate;
  reg newCostFunc;
  reg [64:0] currSecs [1:0];
  reg [7:0] sign_outW;

  // File descriptors for the error/output dumps
  integer fid, fid_error_dump, retVal;
  integer fid_x, fid_Wz, fid_Wi, fid_Wf, fid_Wo, fid_Rz, fid_Ri, fid_Rf, fid_Ro, fid_bz, fid_bi, fid_bf, fid_bo, fid_outW, fid_out;
  integer i=0,j=0,k=0,l=0, roundOut;
  real    quantError=0;
  //real    costFuncIntermediate;
  real    J;
  real    Jpert;
  real    diffJ;

  // Clock generation
  always begin
      #(HALF_CLOCK) clock = ~clock;
      #(HALF_CLOCK) clock = ~clock;
  end

  assign resetP = reset || !enPerceptron;

  // DUT Instantiation
  network              #(INPUT_SZ, HIDDEN_SZ, OUTPUT_SZ, QN, QM, DSP48_PER_ROW_G, DSP48_PER_ROW_M)
		LSTM_LAYER    (inputVec, 1'b1, {11'd2311, $random(currSecs[0])}, 11'd9, 11'd4, wmax, clock, reset, resetRAM, newCostFunc, costFunc, newSample, dataReady, trainingReady, outputVec);

  array_prod #(HIDDEN_SZ, QN, QM)  PERCEPTRON  (Wperceptron_IN, outputVec, clock, resetP, dataReadyP, networkOutput);


 /*
  always @(posedge dataReadyP) begin
      costFuncIntermediate = (modelOutput - sigmoid(networkOutput))**2;
      costFunc = costFuncIntermediate * (2**(QM);
      #(FULL_CLOCK);
	newCostFunc = 1;
	#(FULL_CLOCK);
	newCostFunc = 0;
  end
*/
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
		fid_outW = $fopen("goldenIn_outW.bin", "r");
		fid_out  = $fopen("goldenOut.bin", "r");
		fid      = $fopen("output.bin", "w");

		// -------------------------------- Loading the weight memory ------------------------------- //
		for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Wz, "%b\n", LSTM_LAYER.WRAM_Z_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_Z_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Rz, "%b\n", LSTM_LAYER.WRAM_Z_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_Z_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Wi, "%b\n", LSTM_LAYER.WRAM_I_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_I_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Ri, "%b\n", LSTM_LAYER.WRAM_I_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_I_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Wf, "%b\n", LSTM_LAYER.WRAM_F_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_F_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Rf, "%b\n", LSTM_LAYER.WRAM_F_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_F_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Wo, "%b\n", LSTM_LAYER.WRAM_O_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_O_X.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                //retVal = $fscanf(fid_Ro, "%b\n", LSTM_LAYER.WRAM_O_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH]);
                LSTM_LAYER.WRAM_O_Y.RAM_matrix[i][j*BITWIDTH +: BITWIDTH] = 18'h00400;
            end
        end

        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
					retVal = $fscanf(fid_bz, "%18b\n",temp);
					LSTM_LAYER.bZ[i*BITWIDTH +: BITWIDTH] = 18'h00400; //temp;

					retVal = $fscanf(fid_bi, "%18b\n",temp);
					LSTM_LAYER.bI[i*BITWIDTH +: BITWIDTH] = 18'h00400; //temp;

					retVal = $fscanf(fid_bf, "%18b\n",temp);
					LSTM_LAYER.bF[i*BITWIDTH +: BITWIDTH] = 18'h00400; //temp;

					retVal = $fscanf(fid_bo, "%18b\n",temp);
					LSTM_LAYER.bO[i*BITWIDTH +: BITWIDTH] = 18'h00400;//temp;

					retVal = $fscanf(fid_outW, "%18b\n",temp);
					Wperceptron[i*BITWIDTH +: BITWIDTH] = 18'h00400; //temp;
        end

	end

    // Running the simulation
    initial begin
		$system("date +%s  > date_file");
		$readmemh("date_file", currSecs);

		clock        = 0;
		newSample    = 0;
	  newCostFunc  = 0;
	  enPerceptron = 0;
    wmax = (18'd7 << 11);

		// Applying the initial reset
		reset     = 1'b1;
		resetRAM  = 1'b1;
		#(2*FULL_CLOCK);
		reset     = 1'b0;
		resetRAM  = 1'b0;

		// ----------------------------------------------------------------------------------------- //

		for(k=0; k < TRAIN_SAMPLES; k = k + 1) begin

			// Applying the initial reset
			reset     = 1'b1;
			#(2*FULL_CLOCK);
			reset     = 1'b0;

			if(k % 1000 == 0) begin
				//$display("Input Sample %d", k);
				$display("Average Wrong bits: %.4f", quantError/1000.0);
				quantError=0;
			end

			for(i=0; i < MAX_SAMPLES; i = i + 1) begin

				// ---------- Applying a new input signal ---------- //

				@(posedge clock);
				retVal = $fscanf(fid_x,  "%b\n", temp);
				inputVec[17:0]  = temp;
				retVal = $fscanf(fid_x,  "%b\n", temp);
				inputVec[35:18] = temp;
				retVal = $fscanf(fid_out, "%b\n", modelOutput);
				sign_outW = $random();
				Wperceptron_IN = Wperceptron;

				newSample = 1'b1;
				#(FULL_CLOCK);
				newSample = 1'b0;

				// ------------------------------------------------- //

				// Waiting for the result
				@(posedge dataReady);
				#(FULL_CLOCK);
				enPerceptron = 1;

				@(posedge dataReadyP);
				J = (modelOutput - sigmoid(networkOutput))**2;
				roundOut = sigmoid(networkOutput);
				enPerceptron = 0;
				if (roundOut !=  modelOutput) begin
					quantError <= quantError + 1;
					//$display("%d --> %b", roundOut, modelOutput);
					//$display("ERROR!\n");
				end
				#(FULL_CLOCK);
				// Applying perturbation to the weights
				for(l=0; l < HIDDEN_SZ; l = l + 1) begin
					if(sign_outW[l] == 1)
						Wperceptron_IN[l*BITWIDTH +: BITWIDTH] = $signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) + (18'h00800 >>> 9);
					else
						Wperceptron_IN[l*BITWIDTH +: BITWIDTH] = $signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) - (18'h00800 >>> 9);
				end


				// If we are training, wait for the perturbed FP, and uncomment this
				@(posedge dataReady);
				#(FULL_CLOCK);
				enPerceptron = 1;

				@(posedge dataReadyP);
				Jpert = (modelOutput - sigmoid(networkOutput))**2;
				diffJ = (Jpert-J) * (2**5);
				costFunc = diffJ * (2**QM);
				//$display("Cost: %.4f", diffJ);
				enPerceptron = 0;
				newCostFunc = 1;
				#(FULL_CLOCK);
				newCostFunc = 0;

				// Training the output perceptron
				for(l=0; l < HIDDEN_SZ; l = l + 1) begin
					if(sign_outW[l] == 1)
						if($signed($signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) - $signed(costFunc)) > $signed(wmax)) begin
							//$display("LIMITADOR MAIS! %d", j);
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= wmax;
						end else if($signed($signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) - $signed(costFunc)) < $signed(-wmax)) begin
							//$display("LIMITADOR MENOS! %d", j);
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= -wmax;
						end
						else
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= $signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) - $signed(costFunc);
					else
						if($signed($signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) + $signed(costFunc)) > $signed(wmax))
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= wmax;
						else if($signed($signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) + $signed(costFunc)) < $signed(-wmax))
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= -wmax;
						else
							Wperceptron[l*BITWIDTH +: BITWIDTH] <= $signed(Wperceptron[l*BITWIDTH +: BITWIDTH]) + $signed(costFunc);
				end


				@(posedge trainingReady);
				//$display("%d --> %b", roundOut, modelOutput);
				//$fwrite(fid, "%d\n", networkOutput);

			end
     end
	   //$display("Percentage Wrong bits: %f percent", 100*quantError/8000.0);
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

function real sigmoid;
	input [BITWIDTH-1:0] bit_number;
	real conv;
	begin
		conv = ($signed(bit_number)) / (2.0**QM);
		sigmoid = 1/(1+ e**(-conv));
	end
endfunction
endmodule
