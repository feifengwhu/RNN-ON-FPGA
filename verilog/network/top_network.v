`timescale 1ns / 1ps

module top_network #(parameter INPUT_SZ=2,
					  parameter HIDDEN_SZ=32,
					  parameter OUTPUT_SZ=1,
					  parameter QN=6,
					  parameter QM=11,
					  parameter DSP48_PER_ROW_G=4,
					  parameter DSP48_PER_ROW_M=4) 
                     (inputVec, trainingFlag, clock, reset, newSample, dataReady_net, dataReadyP_net, enPerceptron, networkOutput);
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter OUTPUT_BITWIDTH  = BITWIDTH*OUTPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
    parameter MAC_BITWIDTH     = (2*BITWIDTH+1);
	parameter ADDR_BITWIDTH    = log2(HIDDEN_SZ);
	parameter ADDR_BITWIDTH_X  = log2(INPUT_SZ);	

	
	input [INPUT_BITWIDTH-1:0] inputVec;
	input trainingFlag;
	input clock;
	input reset;
    input newSample;
    input enPerceptron;
	output reg dataReady_net;
	output reg dataReadyP_net;
    output reg [BITWIDTH-1:0] networkOutput;
    
    wire [BITWIDTH-1:0] perceptOutput;
    wire [LAYER_BITWIDTH-1:0] outputVec;
    reg [OUTPUT_BITWIDTH-1:0] test;
    reg  [LAYER_BITWIDTH-1:0] Wperceptron;
	wire  [ADDR_BITWIDTH-1:0] colAddrP;
    reg   [BITWIDTH-1:0] temp;
    wire                  resetP;
	wire dataReady;
	wire dataReadyP;
	reg enPerceptronPIPE;
	
	always @(posedge clock) begin
		enPerceptronPIPE <= enPerceptron;
	end
	
    assign resetP = reset || !enPerceptronPIPE;
	
	always @(*) begin
		networkOutput = perceptOutput;
		dataReady_net = dataReady;
		dataReadyP_net = dataReadyP;
	end

    // DUT Instantiation
    network              #(INPUT_SZ, HIDDEN_SZ, OUTPUT_SZ, QN, QM, DSP48_PER_ROW_G, DSP48_PER_ROW_M) 
			LSTM_LAYER    (inputVec, trainingFlag, clock, reset, newSample, dataReady, outputVec);
    array_prod #(HIDDEN_SZ, QN, QM)  PERCEPTRON  (Wperceptron, outputVec, clock, resetP, dataReadyP, perceptOutput);

    
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
            
    
        

