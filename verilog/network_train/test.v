module test();
	parameter BITWIDTH = 18;
	parameter QM = 11;
	parameter real e = 2.718281828459045;
	integer i, j, fid, stuff;
	real tempreal;
	reg signed [17:0]  test; 
	reg [17:0]  minusTest;
	reg [11:0]  expShift = 11'b1;
	reg [3:0] a = 5;
	reg [3:0] b = 8;
	reg [3:0] c;
	
	initial begin
	/*
		test      =  (1 << expShift);
		minusTest =  (~(1 << expShift)) + 1;
		
		$display("%32b\n", test);
		$display("%32b\n", minusTest);
		
		c = a - b;
		
		$display("%5b\n", c);
	*/
	test = 18'b111111000000000000;
	tempreal = ($signed(test)) / (2.0**QM);
	$display("%f", sigmoid(test));
	
	end
		
function real sigmoid;
	input [BITWIDTH-1:0] bit_number;
	real conv;
	begin
		conv = ($signed(test)) / (2.0**QM);
		sigmoid = 1/(1+ e**(-conv)); 
	end
endfunction
endmodule
