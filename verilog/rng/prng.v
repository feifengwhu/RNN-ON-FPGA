module prng(seed,
			 clock,
			 reset,
			 enable,
			 fetchSample,
			 randomArray);
	
	parameter LFSR_size = 43;
	parameter CA_size   = 37;
	parameter OUT_size  = 32;
	 
	input [LFSR_size-1:0] seed;
	input                 clock;
	input                 reset;
	input                 enable;
	input                 fetchSample;
	output	reg [OUT_size-1:0]	randomArray;
	
	reg [LFSR_size-1:0]  shiftReg; 
	reg [CA_size-1:0]    celAut;  
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
	always @(posedge clock) begin
		if (reset) 
			celAut <= seed[CA_size-1:0];
		else if (enable)
			for(i = 0; i < CA_size; i = i + 1) begin
				if (i == 28) 
					celAut[i] <= (celAut[i-1] ^ celAut[i] ^ celAut[i+1]);
				else if (i == 0)
					celAut[i] <= celAut[i+1];
				else if (i == (CA_size - 1))
					celAut[i] <= celAut[i-1];
				else 
					celAut[i] <= (celAut[i-1] ^ celAut[i+1]);
			end
	end
	
	// --------------------- The Combined Output ---------------------- //
	
	always @(posedge clock) begin
		if (fetchSample)
			randomArray = celAut[OUT_size-1:0] ^ shiftReg[OUT_size-1:0];
	end
		
endmodule	
