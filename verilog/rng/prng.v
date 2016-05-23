module prng(seed,
			clock,
			reset,
			enable,
			fetchSample,
			randomArray);
	
	parameter LFSR_size = 43;
	parameter CA_size   = 37;
	parameter OUT_size  = 32;
	parameter integer shuffleOrder_CA [CA_size-1:0]   = '{5, 18, 12,  1, 32,  7, 36, 13,  3, 30, 14, 33, 34, 24, 20, 26, 16, 22, 17,  0, 21,  9, 19,  6, 27, 23, 31,  2,  8, 28, 29, 15, 11,  4, 25, 35, 10};
    parameter integer shuffleOrder_SR [LFSR_size-1:0] = '{11, 32, 24, 19, 16, 23, 27, 33, 13, 12,  1, 40, 18, 38, 20, 10,  6, 21,  2, 39, 34, 41, 25,  8, 17,  5, 35, 15, 26,  7,  3, 30, 36,  9, 31,  0, 29, 28, 22, 37, 14,  4, 42};
	
	input [LFSR_size-1:0] seed;
	input                 clock;
	input                 reset;
	input                 enable;
	input                 fetchSample;
	output	reg [OUT_size-1:0]	randomArray;
	
	reg [LFSR_size-1:0]  shiftReg; 
	reg [CA_size-1:0]    celAut;  
	reg [CA_size-1:0]    NEXTcelAut;  
	reg [OUT_size-1:0]   extractedCA;  
	reg [OUT_size-1:0]   extractedSR;    
	wire                 next_SR_Bit;
	
	integer i;
	
	// ---------------------- The Shift Register ---------------------- //

	// The register taps
	assign next_SR_Bit = (shiftReg[0] ^ shiftReg[19] ^ shiftReg[40] ^ shiftReg[42]);
	
	// The shift register operation description. The next bit is concatenated with the other portion of the SR, at the beggining
	always @(posedge clock) begin
		if (reset) 
			shiftReg <= seed;
		else if (enable)
			shiftReg <= {shiftReg[LFSR_size-2:0], next_SR_Bit};
	end
	
	// -------------------- The Cellular Automata --------------------- //
	
	// The cellular automata description
	always @(*) begin
		for(i = 0; i < CA_size; i = i + 1) begin
			if (i == 27) 
				NEXTcelAut[i] <= (celAut[i-1] ^ celAut[i] ^ celAut[i+1]);
			else if (i == 0)
				NEXTcelAut[i] <= celAut[i+1];
			else if (i == (CA_size - 1))
				NEXTcelAut[i] <= celAut[i-1];
			else 
				NEXTcelAut[i] <= (celAut[i-1] ^ celAut[i+1]);
		end
	end
	
	always @(posedge clock) begin
		if (reset) 
			celAut <= seed[CA_size-1:0];
		else if (enable)
			celAut <= NEXTcelAut;
	end
	
	// --------------------- Permutting the bits ---------------------- //
	always @(*) begin
		for(i = 0; i < OUT_size; i = i + 1) begin
			extractedCA[i] = celAut[shuffleOrder_CA[i]];
		end
		
		for(i = 0; i < OUT_size; i = i + 1) begin
			extractedSR[i] = shiftReg[shuffleOrder_SR[i]];
		end
	end

	
	// --------------------- The Combined Output ---------------------- //
	
	always @(posedge clock) begin
		if (fetchSample)
			randomArray = extractedCA ^ extractedSR;
	end
		
endmodule	
