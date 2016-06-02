module network  #(parameter INPUT_SZ   =  2,
                  parameter HIDDEN_SZ  = 16,
                  parameter OUTPUT_SZ  =  1,//NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW_G = 2,
                  parameter DSP48_PER_ROW_M = 2)
                 (inputVec,
                  trainingFlag,
                  initSeed,
                  pertRate,
				  learnRate,
                  clock,
                  reset,
				  newCostFunc,
                  costFunc,
                  newSample,
                  dataoutReady,
                  outputVec);

    // Dependent parameters
    parameter BITWIDTH           = QN + QM + 1;
    parameter INPUT_BITWIDTH     = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH     = BITWIDTH*HIDDEN_SZ;
    parameter MULT_BITWIDTH      = (2*BITWIDTH+2);
    parameter ELEMWISE_BITWIDTH  = MULT_BITWIDTH*HIDDEN_SZ;
    parameter OUTPUT_BITWIDTH    = OUTPUT_SZ * BITWIDTH; //log2(NUM_OUTPUT_SYMBOLS);
	parameter ADDR_BITWIDTH      = log2(HIDDEN_SZ);
	parameter ADDR_BITWIDTH_X    = log2(INPUT_SZ);
	parameter MUX_BITWIDTH		  = log2(DSP48_PER_ROW_M);  
	parameter N_DSP48            = HIDDEN_SZ/DSP48_PER_ROW_M; 
	parameter N_PRNG             = HIDDEN_SZ/4;
	parameter N_PRNG_BIAS        = HIDDEN_SZ/8;
	parameter RAND_GEN_BITWIDTH  = 32;
	
    // Input/Output definitions
    input [INPUT_BITWIDTH-1:0]       inputVec;
    input                            trainingFlag;
    input [42:0]					  initSeed;
    input [QM-1:0]					  pertRate;  // The absolute value of the exponent. Only supports (negative) powers of two
    input [QM-1:0]					  learnRate; // The absolute value of the exponent. Only supports (negative) powers of two
    input                            clock;
    input                            reset;
    input 							  newCostFunc;
    input [OUTPUT_BITWIDTH-1:0]      costFunc;
    input                            newSample;
    output reg                      dataoutReady;
    output reg [LAYER_BITWIDTH-1:0] outputVec;
            

    // Connecting wires and auxiliary registers
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wZX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wZY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wZX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wZY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wIX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wIY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wIX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wIY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wFX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wFY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wFX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wFY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wOX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wOY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wOX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wOY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressTRAIN_X;
    reg    [ADDR_BITWIDTH-1:0]   colAddressTRAIN_Y;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressRead_X;
    reg    [ADDR_BITWIDTH-1:0]   colAddressRead_Y;
    reg    [ADDR_BITWIDTH_X-1:0] PREVcolAddressTRAIN_X;
    reg    [ADDR_BITWIDTH-1:0]   PREVcolAddressTRAIN_Y;
    reg    [ADDR_BITWIDTH_X-1:0] NEXTcolAddressTRAIN_X;
    reg    [ADDR_BITWIDTH-1:0]   NEXTcolAddressTRAIN_Y;
    reg    [LAYER_BITWIDTH-1:0]  wZX_in;
    wire   [LAYER_BITWIDTH-1:0]  wZX_out;
    reg    [LAYER_BITWIDTH-1:0]  wZY_in;
    wire   [LAYER_BITWIDTH-1:0]  wZY_out;
    reg    [LAYER_BITWIDTH-1:0]  wIX_in;
    wire   [LAYER_BITWIDTH-1:0]  wIX_out;
    reg    [LAYER_BITWIDTH-1:0]  wIY_in;
    wire   [LAYER_BITWIDTH-1:0]  wIY_out;
    reg    [LAYER_BITWIDTH-1:0]  wFX_in;
    wire   [LAYER_BITWIDTH-1:0]  wFX_out;
    reg    [LAYER_BITWIDTH-1:0]  wFY_in;
    wire   [LAYER_BITWIDTH-1:0]  wFY_out;
    reg    [LAYER_BITWIDTH-1:0]  wOX_in;
    wire   [LAYER_BITWIDTH-1:0]  wOX_out;
    reg    [LAYER_BITWIDTH-1:0]  wOY_in;
    wire   [LAYER_BITWIDTH-1:0]  wOY_out;
    reg    [LAYER_BITWIDTH-1:0]  wZX_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wZY_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wIX_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wIY_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wFX_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wFY_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wOX_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  wOY_out_gate;
    reg    [LAYER_BITWIDTH-1:0]  PREVwZX_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwZY_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwIX_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwIY_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwFX_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwFY_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwOX_out;
    reg    [LAYER_BITWIDTH-1:0]  PREVwOY_out;
    wire   [HIDDEN_SZ-1:0]  sign_wZX;
    wire   [HIDDEN_SZ-1:0]  sign_wZY;
    wire   [HIDDEN_SZ-1:0]  sign_wIX;
    wire   [HIDDEN_SZ-1:0]  sign_wIY;
    wire   [HIDDEN_SZ-1:0]  sign_wFX;
    wire   [HIDDEN_SZ-1:0]  sign_wFY;
    wire   [HIDDEN_SZ-1:0]  sign_wOX;
    wire   [HIDDEN_SZ-1:0]  sign_wOY;
    reg    [HIDDEN_SZ-1:0]  sign_bZ;
    reg    [HIDDEN_SZ-1:0]  sign_bI;
    reg    [HIDDEN_SZ-1:0]  sign_bF;
    reg    [HIDDEN_SZ-1:0]  sign_bO;
    
    wire   [LAYER_BITWIDTH-1:0]  gate_Z;
    wire   [LAYER_BITWIDTH-1:0]  gate_I;
    wire   [LAYER_BITWIDTH-1:0]  gate_F;
    wire   [LAYER_BITWIDTH-1:0]  gate_O;
    wire                         gateReady_Z;
    wire                         gateReady_I;
    wire                         gateReady_F;
    wire                         gateReady_O;
    reg                          beginCalc;
    reg                          writeEn_wZX;
    reg                          writeEn_wZY;
    reg                          writeEn_wIX;
    reg                          writeEn_wIY;
    reg                          writeEn_wFX;
    reg                          writeEn_wFY;
    reg                          writeEn_wOX;
    reg                          writeEn_wOY;
    reg                          z_ready;
    reg                          f_ready;
    reg                          y_ready;
    reg signed [LAYER_BITWIDTH-1:0]    prevLayerOut;
    reg signed [BITWIDTH-1:0]    inputVecSample;
    reg signed [BITWIDTH-1:0]    prevOutVecSample;
    reg signed [LAYER_BITWIDTH-1:0] bZ;
    reg signed [LAYER_BITWIDTH-1:0] bI;
    reg signed [LAYER_BITWIDTH-1:0] bF;
    reg signed [LAYER_BITWIDTH-1:0] bO;
    reg signed [LAYER_BITWIDTH-1:0] PREVbZ;
    reg signed [LAYER_BITWIDTH-1:0] PREVbI;
    reg signed [LAYER_BITWIDTH-1:0] PREVbF;
    reg signed [LAYER_BITWIDTH-1:0] PREVbO;
    reg signed [LAYER_BITWIDTH-1:0] bZ_out_gate;
    reg signed [LAYER_BITWIDTH-1:0] bI_out_gate;
    reg signed [LAYER_BITWIDTH-1:0] bF_out_gate;
    reg signed [LAYER_BITWIDTH-1:0] bO_out_gate;
    reg signed [ELEMWISE_BITWIDTH-1:0] elemWiseMult_out;

    // Internal datapath registers
    reg [1:0] muxStageSelector;
    reg signed  [LAYER_BITWIDTH-1:0] ZI_prod;
    reg signed  [LAYER_BITWIDTH-1:0] CF_prod;
    reg signed  [LAYER_BITWIDTH-1:0] layer_C;
    reg signed  [LAYER_BITWIDTH-1:0] prev_C;
    reg signed  [LAYER_BITWIDTH-1:0] SS_layer_C;

    reg signed  [MUX_BITWIDTH-1:0] rowMux;
    reg signed  [MUX_BITWIDTH-1:0] NEXTrowMux;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_op1;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_op2;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_mult1;
    wire signed [LAYER_BITWIDTH-1:0] elemWise_mult2;
    wire signed [LAYER_BITWIDTH-1:0] tanh_result;
    reg signed [BITWIDTH-1:0] posBeta;
    reg signed [BITWIDTH-1:0] minusBeta;
    reg signed [BITWIDTH-1:0] deltaCost;
    wire [RAND_GEN_BITWIDTH*N_PRNG-1 : 0]      randGenOutput;
    wire [RAND_GEN_BITWIDTH*N_PRNG_BIAS-1 : 0] randGenOutput_bias;
    wire reset_sigm;
    wire reset_tanh;
    reg  sigmoidEnable;
    reg  tanhEnable;
    reg  savePrevC;
    reg  pertWeights;
    reg  weightUpdate;
    reg  genRandNum_X;
    reg  genRandNum_Y;
    reg  writeWeightUpdate_X;
    reg  writeWeightUpdate_Y;
    reg  saveSS_layerC;
    
    
    // The enable signals for the sigmoid/tanh evaluations
	assign reset_sigm = reset || !sigmoidEnable;
	assign reset_tanh = reset || !tanhEnable;

    integer j;

    // Module Instatiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_Z (inputVecSample, prevOutVecSample, wZX_out_gate, wZY_out_gate, bZ, beginCalc,
                                                             clock, reset, colAddressRead_wZX, colAddressRead_wZY, gateReady_Z, gate_Z);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_Z_X (PREVcolAddressTRAIN_X, colAddressRead_X, writeWeightUpdate_X, clock, reset, wZX_in, wZX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_Z_Y (PREVcolAddressTRAIN_Y, colAddressRead_Y, writeWeightUpdate_Y, clock, reset, wZY_in, wZY_out);
 
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_I (inputVecSample, prevOutVecSample, wIX_out_gate, wIY_out_gate, bI, beginCalc,
                                                             clock, reset, colAddressRead_wIX, colAddressRead_wIY, gateReady_I, gate_I);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_I_X (PREVcolAddressTRAIN_X, colAddressRead_X, writeWeightUpdate_X, clock, reset, wIX_in, wIX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_I_Y (PREVcolAddressTRAIN_Y, colAddressRead_Y, writeWeightUpdate_Y, clock, reset, wIY_in, wIY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_F (inputVecSample, prevOutVecSample, wFX_out_gate, wFY_out_gate, bF, beginCalc,
                                                             clock, reset, colAddressRead_wFX, colAddressRead_wFY, gateReady_F, gate_F);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_F_X (PREVcolAddressTRAIN_X, colAddressRead_X, writeWeightUpdate_X, clock, reset, wFX_in, wFX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_F_Y (PREVcolAddressTRAIN_Y, colAddressRead_Y, writeWeightUpdate_Y, clock, reset, wFY_in, wFY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_O (inputVecSample, prevOutVecSample, wOX_out_gate, wOY_out_gate, bO, beginCalc,
                                                             clock, reset, colAddressRead_wOX, colAddressRead_wOY, gateReady_O, gate_O);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_O_X (PREVcolAddressTRAIN_X, colAddressRead_X, writeWeightUpdate_X, clock, reset, wOX_in, wOX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_O_Y (PREVcolAddressTRAIN_Y, colAddressRead_Y, writeWeightUpdate_Y, clock, reset, wOY_in, wOY_out);

	// The non-linearity modules
    genvar i;
    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            sigmoid #(QN,QM) sigmoid_i (elemWise_op2[i*BITWIDTH +: BITWIDTH], clock, reset_sigm, elemWise_mult2[i*BITWIDTH +: BITWIDTH]);
        end 
    endgenerate 

    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            tanh #(QN,QM) tanh_i (elemWise_op1[i*BITWIDTH +: BITWIDTH], clock, reset_tanh, tanh_result[i*BITWIDTH +: BITWIDTH]);
        end 
    endgenerate 

	// The Pseudo-random Number Generators
	genvar k;
	generate
		for (k = 0; k < N_PRNG; k = k + 1) begin
			prng PRNG_k (initSeed, clock, reset, genRandNum, genRandNum, randGenOutput[k*RAND_GEN_BITWIDTH+:RAND_GEN_BITWIDTH]);
		end 
		for (k = 0; k < N_PRNG_BIAS; k = k + 1) begin
			prng PRNG_bias_k (initSeed, clock, reset, genRandNum, genRandNum, randGenOutput_bias[k*RAND_GEN_BITWIDTH+:RAND_GEN_BITWIDTH]);
		end 
    endgenerate

	// The sign matrix for the perturbations
	weightRAM  #(HIDDEN_SZ,  INPUT_SZ, 1)  PRAM_Z_X (colAddressRead_wZX, colAddressTRAIN_X, genRandNum_X, clock, reset, randGenOutput[0 +: HIDDEN_SZ]        , sign_wZX);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, 1)  PRAM_Z_Y (colAddressRead_wZY, colAddressTRAIN_Y, genRandNum_Y, clock, reset, randGenOutput[HIDDEN_SZ +:HIDDEN_SZ] , sign_wZY);
	weightRAM  #(HIDDEN_SZ,  INPUT_SZ, 1)  PRAM_I_X (colAddressRead_wIX, colAddressTRAIN_X, genRandNum_X, clock, reset, randGenOutput[2*HIDDEN_SZ+:HIDDEN_SZ], sign_wIX);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, 1)  PRAM_I_Y (colAddressRead_wIY, colAddressTRAIN_Y, genRandNum_Y, clock, reset, randGenOutput[3*HIDDEN_SZ+:HIDDEN_SZ], sign_wIY);
	weightRAM  #(HIDDEN_SZ,  INPUT_SZ, 1)  PRAM_F_X (colAddressRead_wFX, colAddressTRAIN_X, genRandNum_X, clock, reset, randGenOutput[4*HIDDEN_SZ+:HIDDEN_SZ], sign_wFX);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, 1)  PRAM_F_Y (colAddressRead_wFY, colAddressTRAIN_Y, genRandNum_Y, clock, reset, randGenOutput[5*HIDDEN_SZ+:HIDDEN_SZ], sign_wFY);
	weightRAM  #(HIDDEN_SZ,  INPUT_SZ, 1)  PRAM_O_X (colAddressRead_wOX, colAddressTRAIN_X, genRandNum_X, clock, reset, randGenOutput[6*HIDDEN_SZ+:HIDDEN_SZ], sign_wOX);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, 1)  PRAM_O_Y (colAddressRead_wOY, colAddressTRAIN_Y, genRandNum_Y, clock, reset, randGenOutput[7*HIDDEN_SZ+:HIDDEN_SZ], sign_wOY);  

	// Evaluating the positive and negative versions of the perturbation constant
	always @(*) begin
		posBeta   = (1 << pertRate);
		minusBeta = (~(1 << pertRate)) + 1;
	end
	
	// Chooses to perturbate the weights going to the Gate, or not.
	always @(*) begin
		if(pertWeights) begin
			for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
				if(sign_wZX[j] == 1)
					wZX_out_gate[j*BITWIDTH +: BITWIDTH] = wZX_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wZX_out_gate[j*BITWIDTH +: BITWIDTH] = wZX_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
				if(sign_wZY[j] == 1)
					wZY_out_gate[j*BITWIDTH +: BITWIDTH] = wZY_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wZY_out_gate[j*BITWIDTH +: BITWIDTH] = wZY_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
					
				if(sign_wIX[j] == 1)
					wIX_out_gate[j*BITWIDTH +: BITWIDTH] = wIX_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wIX_out_gate[j*BITWIDTH +: BITWIDTH] = wIX_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
				if(sign_wIY[j] == 1)
					wIY_out_gate[j*BITWIDTH +: BITWIDTH] = wIY_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wIY_out_gate[j*BITWIDTH +: BITWIDTH] = wIY_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
				
				if(sign_wFX[j] == 1)
					wFX_out_gate[j*BITWIDTH +: BITWIDTH] = wFX_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wFX_out_gate[j*BITWIDTH +: BITWIDTH] = wFX_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
				if(sign_wFY[j] == 1)
					wFY_out_gate[j*BITWIDTH +: BITWIDTH] = wFY_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wFY_out_gate[j*BITWIDTH +: BITWIDTH] = wFY_out[j*BITWIDTH +: BITWIDTH] + minusBeta;
				
				if(sign_wOX[j] == 1)
					wOX_out_gate[j*BITWIDTH +: BITWIDTH] = wOX_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wOX_out_gate[j*BITWIDTH +: BITWIDTH] = wOX_out[j*BITWIDTH +: BITWIDTH] + minusBeta;	
				if(sign_wOY[j] == 1)
					wOY_out_gate[j*BITWIDTH +: BITWIDTH] = wOY_out[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					wOY_out_gate[j*BITWIDTH +: BITWIDTH] = wOY_out[j*BITWIDTH +: BITWIDTH] + minusBeta;	
					
				if(sign_bZ[j] == 1)
					bZ_out_gate[j*BITWIDTH +: BITWIDTH] = bZ[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					bZ_out_gate[j*BITWIDTH +: BITWIDTH] = bZ[j*BITWIDTH +: BITWIDTH] + minusBeta;	
				if(sign_bI[j] == 1)
					bI_out_gate[j*BITWIDTH +: BITWIDTH] = bI[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					bI_out_gate[j*BITWIDTH +: BITWIDTH] = bI[j*BITWIDTH +: BITWIDTH] + minusBeta;	
				if(sign_bF[j] == 1)
					bF_out_gate[j*BITWIDTH +: BITWIDTH] = bF[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					bF_out_gate[j*BITWIDTH +: BITWIDTH] = bF[j*BITWIDTH +: BITWIDTH] + minusBeta;	
				if(sign_bO[j] == 1)
					bO_out_gate[j*BITWIDTH +: BITWIDTH] = bO[j*BITWIDTH +: BITWIDTH] + posBeta;
				else
					bO_out_gate[j*BITWIDTH +: BITWIDTH] = bO[j*BITWIDTH +: BITWIDTH] + minusBeta;	
			end
		end
		else begin
			wZX_out_gate = wZX_out;
			wZY_out_gate = wZY_out;
			wIX_out_gate = wIX_out;
			wIY_out_gate = wIY_out;
			wFX_out_gate = wFX_out;
			wFY_out_gate = wFY_out;
			wOX_out_gate = wOX_out;
			wOY_out_gate = wOY_out;
			bZ_out_gate = bZ;
			bI_out_gate = bI;
			bF_out_gate = bF;
			bO_out_gate = bO;
		end
	end
	
	// Evaluates the update to be applied for each training cycle
	always @(*) begin
		if(weightUpdate) begin
			for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
				if(sign_wZX[j] == 1)
					wZX_in[j*BITWIDTH +: BITWIDTH] = PREVwZX_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wZX_in[j*BITWIDTH +: BITWIDTH] = PREVwZX_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
				if(sign_wZY[j] == 1)
					wZY_in[j*BITWIDTH +: BITWIDTH] = PREVwZY_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wZY_in[j*BITWIDTH +: BITWIDTH] = PREVwZY_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
					
				if(sign_wIX[j] == 1)
					wIX_in[j*BITWIDTH +: BITWIDTH] = PREVwIX_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wIX_in[j*BITWIDTH +: BITWIDTH] = PREVwIX_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
				if(sign_wIY[j] == 1)
					wIY_in[j*BITWIDTH +: BITWIDTH] = PREVwIY_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wIY_in[j*BITWIDTH +: BITWIDTH] = PREVwIY_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
				
				if(sign_wFX[j] == 1)
					wFX_in[j*BITWIDTH +: BITWIDTH] = PREVwFX_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wFX_in[j*BITWIDTH +: BITWIDTH] = PREVwFX_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
				if(sign_wFY[j] == 1)
					wFY_in[j*BITWIDTH +: BITWIDTH] = PREVwFY_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wFY_in[j*BITWIDTH +: BITWIDTH] = PREVwFY_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
				
				if(sign_wOX[j] == 1)
					wOX_in[j*BITWIDTH +: BITWIDTH] = PREVwOX_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wOX_in[j*BITWIDTH +: BITWIDTH] = PREVwOX_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));	
				if(sign_wOY[j] == 1)
					wOY_in[j*BITWIDTH +: BITWIDTH] = PREVwOY_out[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					wOY_in[j*BITWIDTH +: BITWIDTH] = PREVwOY_out[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));
					
				if(sign_bZ[j] == 1)
					bZ[j*BITWIDTH +: BITWIDTH] = PREVbZ[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					bZ[j*BITWIDTH +: BITWIDTH] = PREVbZ[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));	
				if(sign_bI[j] == 1)
					bI[j*BITWIDTH +: BITWIDTH] = PREVbI[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					bI[j*BITWIDTH +: BITWIDTH] = PREVbI[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));	
				if(sign_bF[j] == 1)
					bF[j*BITWIDTH +: BITWIDTH] = PREVbF[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					bF[j*BITWIDTH +: BITWIDTH] = PREVbF[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));	
				if(sign_bO[j] == 1)
					bO[j*BITWIDTH +: BITWIDTH] = PREVbO[j*BITWIDTH +: BITWIDTH] + (deltaCost >> (learnRate - pertRate));
				else
					bO[j*BITWIDTH +: BITWIDTH] = PREVbO[j*BITWIDTH +: BITWIDTH] - (deltaCost >> (learnRate - pertRate));		
			end
		end
	end
	
	// One cycle delay for the weight RAM update
	always @(posedge clock) begin
		PREVwZX_out <= wZX_out;
		PREVwZY_out <= wZY_out;
		PREVwIX_out <= wIX_out;
		PREVwIY_out <= wIY_out;
		PREVwFX_out <= wFX_out;
		PREVwFY_out <= wFY_out;
		PREVwOX_out <= wOX_out;
		PREVwOY_out <= wOY_out;
		PREVbZ <= bZ;
		PREVbI <= bI;
		PREVbF <= bF;
		PREVbO <= bO;
	end
	
	always @(*) begin
		if(weightUpdate) begin
			colAddressRead_X = colAddressTRAIN_X;
			colAddressRead_Y = colAddressTRAIN_Y;
		end
		else begin
			colAddressRead_X = colAddressRead_wZX;
			colAddressRead_Y = colAddressRead_wZY;
		end
	end
	
	always @(posedge clock) begin
		PREVcolAddressTRAIN_X <= colAddressRead_X;
		PREVcolAddressTRAIN_Y <= colAddressRead_Y;
	end
	
	// Slicing the input and previous output vectors
	always @(negedge clock) begin
        if( reset == 1'b1) begin
            inputVecSample   <= {BITWIDTH{1'b0}};
            prevOutVecSample <= {BITWIDTH{1'b0}};
        end
        else begin
            inputVecSample   <= inputVec[colAddressRead_wZX*BITWIDTH +: BITWIDTH];
            prevOutVecSample <= prevLayerOut[colAddressRead_wZY*BITWIDTH +: BITWIDTH];//{18'b000000100000000000, 18'b000000100000000000};
        end
    end

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        case (muxStageSelector) 
            2'd0 : begin
                elemWise_op1 = gate_Z;
                elemWise_op2 = gate_I;
            end
        
            2'd1 : begin
                elemWise_op1 = 18'b0;
                elemWise_op2 = gate_F;
            end

            2'd2 : begin
                elemWise_op1 = layer_C;
                elemWise_op2 = gate_O;
            end
            
            default : begin
				elemWise_op1 = gate_Z;
                elemWise_op2 = gate_I;
            end
        endcase
    end

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        if(muxStageSelector == 2'd1)
            elemWise_mult1 = prev_C;
        else
            elemWise_mult1 = tanh_result;
    end  
    
    always @(posedge clock) begin
		if(reset) begin
			ZI_prod <= {LAYER_BITWIDTH{1'b0}};
			CF_prod <= {LAYER_BITWIDTH{1'b0}};
			prevLayerOut <= {LAYER_BITWIDTH{1'b0}};
		end
	end
			
    
    // Partial Non-liearity/Elementwise Block Result --- z signal TIMES i signal
    always @(posedge z_ready) begin
		for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			ZI_prod[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: MULT_BITWIDTH] >>> QM;
		end
    end

    // Partial Non-liearity/Elementwise Block Result --- c signal TIMES f signal
    always @(posedge f_ready) begin
		for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			CF_prod[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: MULT_BITWIDTH] >>> QM;
		end
    end
     
    // Saving the current layer output (that serves as input to the gate modules)
    always @(posedge y_ready) begin
		for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			prevLayerOut[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: MULT_BITWIDTH] >>> QM;
		end
    end

    // The C signal --- The memory element
    always @(*) begin
        for(j=0; j < HIDDEN_SZ; j = j + 1) begin
            layer_C[j*BITWIDTH +: BITWIDTH] = ZI_prod[j*BITWIDTH +: BITWIDTH] +  CF_prod[j*BITWIDTH +: BITWIDTH];
        end
    end
    
    always @(posedge reset) begin
		prev_C <= {LAYER_BITWIDTH{1'b0}};
		SS_layer_C <= {LAYER_BITWIDTH{1'b0}};
	end
	
    always @(posedge saveSS_layerC) begin
		SS_layer_C <= layer_C;
    end
    
    always @(posedge newSample) begin
		if(trainingFlag == 1) 
			prev_C <= SS_layer_C;
		else
			prev_C <= layer_C;
	end
    
    // The elementwise multiplication DSP slices
    always @(posedge clock) begin
        for(j=0; j < HIDDEN_SZ; j = j + 1) begin
            elemWiseMult_out[j*MULT_BITWIDTH +: MULT_BITWIDTH] <= ($signed(elemWise_mult2[j*BITWIDTH +: BITWIDTH]) * 
																							 $signed(elemWise_mult1[j*BITWIDTH +: BITWIDTH]));
        end
    end

	always @(*) begin
		outputVec = prevLayerOut;
	end

	// Keeping track of the Cost Function variables
	always @(posedge clock) begin
		if(newCostFunc) 
			deltaCost <= costFunc - deltaCost;
		else if(newSample)
			deltaCost <= {BITWIDTH{1'b0}};
	end

    // --------------------- FINITE STATE MACHINE --------------------- //
    
    // The state tags
    parameter IDLE             = 5'd0;
    parameter GATE_CALC_INIT   = 5'd1;
    parameter GATE_CALC   = 5'd2;
    parameter NON_LIN_1A  = 5'd3;
    parameter NON_LIN_2A  = 5'd4;
    parameter ELEM_PROD_A = 5'd5;
    parameter NON_LIN_1B  = 5'd6;
    parameter NON_LIN_2B  = 5'd7;
    parameter ELEM_PROD_B = 5'd8;
    parameter NON_LIN_1C  = 5'd9;
    parameter NON_LIN_2C  = 5'd10;
    parameter ELEM_PROD_C = 5'd11;
    parameter END         = 5'd12;
    parameter TRAIN_GATE_CALC_INIT   = 5'd13;
    parameter TRAIN_GATE_CALC   = 5'd14;
    parameter TRAIN_NON_LIN_1A  = 5'd15;
    parameter TRAIN_NON_LIN_2A  = 5'd16;
    parameter TRAIN_ELEM_PROD_A = 5'd17;
    parameter TRAIN_NON_LIN_1B  = 5'd18;
    parameter TRAIN_NON_LIN_2B  = 5'd19;
    parameter TRAIN_ELEM_PROD_B = 5'd20;
    parameter TRAIN_NON_LIN_1C  = 5'd21;
    parameter TRAIN_NON_LIN_2C  = 5'd22;
    parameter TRAIN_ELEM_PROD_C = 5'd23;
    parameter TRAIN_END         = 5'd24;
    parameter WEIGHT_UPDATE_X   = 5'd25;
    parameter WEIGHT_UPDATE_Y   = 5'd26;
    
    // The FSM registers
    reg [4:0] state;
    reg [4:0] NEXTstate;

    // The FSM that controls the gate
    always @(posedge clock) begin
		if (reset == 1'b1) begin
			state  <= IDLE;
			colAddressTRAIN_X <= {ADDR_BITWIDTH_X{1'b0}};
			colAddressTRAIN_Y <= {ADDR_BITWIDTH{1'b0}};
		end
		else begin
			state  <= NEXTstate;
			colAddressTRAIN_X <= NEXTcolAddressTRAIN_X;
			colAddressTRAIN_Y <= NEXTcolAddressTRAIN_Y;
		end
	end
	
	// Combinational logic that produces the next state
	always @(*) begin
		case(state)		
			IDLE :
			begin
				if ( newSample == 1'b1) begin
					NEXTstate = GATE_CALC_INIT;
				end
				else begin
					NEXTstate = IDLE;
				end
			end
			
			GATE_CALC_INIT:
			begin
				NEXTstate = GATE_CALC;
			end
			
			GATE_CALC:
			begin
				if (gateReady_Z == 1'b1 || gateReady_I == 1'b1 || gateReady_F == 1'b1 || gateReady_O == 1'b1) begin
					NEXTstate = NON_LIN_1A;
				end
				else begin
					NEXTstate = GATE_CALC;
				end
			end
			
			
			NON_LIN_1A:		
			begin
				NEXTstate = NON_LIN_2A;
			end
			
			NON_LIN_2A:		
			begin
				NEXTstate = ELEM_PROD_A;
			end	
			
			ELEM_PROD_A:
			begin
					NEXTstate  = NON_LIN_1B;
			end
			
			NON_LIN_1B:		
			begin
				NEXTstate = NON_LIN_2B;
			end
			
			NON_LIN_2B:		
			begin
				NEXTstate = ELEM_PROD_B;
			end	
			
			ELEM_PROD_B:
			begin
					NEXTstate  = NON_LIN_1C;
			end
			
			NON_LIN_1C:		
			begin
				NEXTstate = NON_LIN_2C;
			end
			
			NON_LIN_2C:		
			begin
				NEXTstate = ELEM_PROD_C;
			end	
			
			ELEM_PROD_C:
			begin
					NEXTstate  = END;
			end
			
			END :
			begin
				if(trainingFlag)
					NEXTstate = TRAIN_GATE_CALC_INIT;
				else
					NEXTstate = IDLE;
			end
			
			TRAIN_GATE_CALC_INIT:
			begin
				NEXTstate = GATE_CALC;
			end
			
			TRAIN_GATE_CALC:
			begin
				if (gateReady_Z == 1'b1 || gateReady_I == 1'b1 || gateReady_F == 1'b1 || gateReady_O == 1'b1) begin
					NEXTstate = NON_LIN_1A;
				end
				else begin
					NEXTstate = GATE_CALC;
				end
			end
			
			
			TRAIN_NON_LIN_1A:		
			begin
				NEXTstate = NON_LIN_2A;
			end
			
			TRAIN_NON_LIN_2A:		
			begin
				NEXTstate = ELEM_PROD_A;
			end	
			
			TRAIN_ELEM_PROD_A:
			begin
					NEXTstate  = NON_LIN_1B;
			end
			
			TRAIN_NON_LIN_1B:		
			begin
				NEXTstate = NON_LIN_2B;
			end
			
			TRAIN_NON_LIN_2B:		
			begin
				NEXTstate = ELEM_PROD_B;
			end	
			
			TRAIN_ELEM_PROD_B:
			begin
					NEXTstate  = NON_LIN_1C;
			end
			
			TRAIN_NON_LIN_1C:		
			begin
				NEXTstate = NON_LIN_2C;
			end
			
			TRAIN_NON_LIN_2C:		
			begin
				NEXTstate = ELEM_PROD_C;
			end	
			
			TRAIN_ELEM_PROD_C:
			begin
				NEXTstate = END;
			end
			
			TRAIN_END:
			begin
				if(newCostFunc)
					NEXTstate = WEIGHT_UPDATE_X;
				else
					NEXTstate = TRAIN_END; // Waits for the evaluation of the Cost Function with perturbed weights
			end
			
			WEIGHT_UPDATE_X:
			begin
				if(colAddressTRAIN_X == (INPUT_SZ-1))
					NEXTstate = WEIGHT_UPDATE_Y;
				else
					NEXTstate = WEIGHT_UPDATE_X;
			end
			
			WEIGHT_UPDATE_Y:
			begin
				if(colAddressTRAIN_Y == (HIDDEN_SZ-1))
					NEXTstate = IDLE;
				else
					NEXTstate = WEIGHT_UPDATE_Y;
			end
			
			default:
			begin
				NEXTstate = IDLE;
			end
		endcase
	end
	
	// Combinational block that produces the outputs and control signals
	always @(*) begin
		case(state)		
			IDLE :
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			GATE_CALC_INIT:
			begin
				beginCalc        = 1'b1;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			GATE_CALC:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b1;
				genRandNum_Y  = 1'b1;
			end
			
			NON_LIN_1A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			NON_LIN_2A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			ELEM_PROD_A:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			NON_LIN_1B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b1;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			NON_LIN_2B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			ELEM_PROD_B:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			NON_LIN_1C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b1;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			NON_LIN_2C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			ELEM_PROD_C:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			END :
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b1;
				dataoutReady     = 1'b1;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				if(trainingFlag == 1) 
					saveSS_layerC = 1'b1;
				else
					saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
				
			TRAIN_GATE_CALC_INIT:
			begin
				beginCalc        = 1'b1;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_GATE_CALC:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_1A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_2A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_ELEM_PROD_A:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_1B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b1;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_2B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_ELEM_PROD_B:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_1C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b1;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_NON_LIN_2C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_ELEM_PROD_C:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			TRAIN_END :
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b1;
				dataoutReady     = 1'b0;		
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			WEIGHT_UPDATE_X:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;	
				NEXTcolAddressTRAIN_X = colAddressTRAIN_X + 1;
				NEXTcolAddressTRAIN_Y = colAddressTRAIN_Y + 1;
				weightUpdate = 1'b1;
				writeWeightUpdate_X = 1'b1;
				writeWeightUpdate_Y = 1'b1;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			WEIGHT_UPDATE_Y:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;	
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = colAddressTRAIN_Y + 1;
				weightUpdate = 1'b1;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b1;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
			
			default:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
				dataoutReady     = 1'b0;
				NEXTcolAddressTRAIN_X = {ADDR_BITWIDTH_X{1'b0}};
				NEXTcolAddressTRAIN_Y = {ADDR_BITWIDTH{1'b0}};
				weightUpdate = 1'b0;
				writeWeightUpdate_X = 1'b0;
				writeWeightUpdate_Y = 1'b0;
				saveSS_layerC = 1'b0;
				genRandNum_X  = 1'b0;
				genRandNum_Y  = 1'b0;
			end
				
		endcase
	end
    
    // ---------------------------------------------------------------- //
    
        
	function integer log2;
		input [31:0] argument;
		integer k;
		begin
			 log2 = -1;
			 k = argument;  
			 while( k > 0 ) begin
				log2 = log2 + 1;
				k = k >> 1;
			 end
		end
	endfunction

endmodule
