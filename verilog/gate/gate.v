module gate    #(parameter INPUT_SZ  = 8,
				  parameter HIDDEN_SZ = 16,
				  parameter QN = 6,
                  parameter QM = 11)
                 (inputVec,
                  prevLayerOut,
                  weightMem_X,
                  weightMem_Y,
                  clk,
                  reset,
                  colAddress_X,
                  colAddress_Y,
                  dataReady_gate,
                  gateOutput);
   
	// Dependent Parameters
    parameter BITWIDTH = QN + QM + 1;
    parameter LAYER_BITWIDTH = BITWIDTH*NROW;
	parameter ADDR_BITWIDTH  = $ln(NCOL)/$ln(2);
	
	// Input/Output definition
	input signed        [BITWIDTH-1:0]  inputVec;
	input signed        [BITWIDTH-1:0]  prevLayerOut;
	input signed  [LAYER_BITWIDTH-1:0]  weightMem_X;
	input signed  [LAYER_BITWIDTH-1:0]  weightMem_Y;
	input signed  [LAYER_BITWIDTH-1:0]  biasVec;
	output reg     [ADDR_BITWIDTH-1:0]  colAddress_X;
	output reg     [ADDR_BITWIDTH-1:0]  colAddress_Y;
	output reg							 dataReady_gate;
	output reg    [LAYER_BITWIDTH-1:0]  gateOutput;
	
	// Internal Registers
	reg signed [LAYER_BITWIDTH-1:0] outputVec_X;
	reg signed [LAYER_BITWIDTH-1:0] outputVec_Y;
	wire dataReady_X;
	wire dataReady_Y;
	
	// DUT Instantiation
    dot_prod   #(HIDDEN_SZ,INPUT_SZ,QN,QM,DSP48_PER_ROW) DOTPROD_X  (weightMem_X, inputVec, clock, reset, dataReady_X, colAddress_X, outputVec_X);  
    dot_prod   #(HIDDEN_SZ,HIDDEN_SZ,QN,QM,DSP48_PER_ROW) DOTPROD_Y  (weightMem_Y, prevLayerOut, clock, reset, dataReady_Y, colAddress_Y, outputVec_Y);
    
    
    
endmodule
