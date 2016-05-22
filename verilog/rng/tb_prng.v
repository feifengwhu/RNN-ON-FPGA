module tb_prng();

	parameter LFSR_size = 43;
	parameter OUT_size  = 32;
	parameter NUM_ITER  = 1000;
	parameter FULL_CLOCK = 2;
	parameter HALF_CLOCK = FULL_CLOCK/2;
	
	integer i, fid;
	
	reg clock;
	reg reset;
	reg enablePRNG;
	reg fetchNewSample;
	wire [OUT_size-1:0] randomArray;
	reg [LFSR_size-1:0] initSeed;

	prng RandomGen (initSeed, clock, reset, enablePRNG, fetchNewSample, randomArray);
	
	always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end
	
	initial begin
		clock = 0;
		reset = 0;
		enablePRNG     = 0;
		fetchNewSample = 0;
		initSeed = {{$random}, {$random}};
		fid = $fopen("output.hex", "w");
		
		// Applying the initial reset
		reset = 1;
		#(FULL_CLOCK);
		reset = 0;
		#(HALF_CLOCK);
		
		enablePRNG = 0;
		
		for( i = 0; i < 5; i = i + 1) begin
			fetchNewSample = 1;
			#(FULL_CLOCK);
			fetchNewSample = 0;
			#(FULL_CLOCK);
		end
		
		enablePRNG = 1;
		
		for( i = 0; i < NUM_ITER; i = i + 1) begin
			fetchNewSample = 1;
			#(FULL_CLOCK);
			fetchNewSample = 0;
			#(FULL_CLOCK);
			$fwrite(fid, "%b\n", randomArray);
		end
		
		enablePRNG = 0;
		
		for( i = 0; i < 5; i = i + 1) begin
			fetchNewSample = 1;
			#(FULL_CLOCK);
			fetchNewSample = 0;
			#(FULL_CLOCK);
		end
		
		$stop;
		
	end
endmodule
