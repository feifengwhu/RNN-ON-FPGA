module test();
	parameter BITWIDTH = 18;
	parameter QM = 11;
	parameter real e = 2.718281828459045;
	integer i, j, fid, stuff;
	real tempreal, costFuncIntermediate;
	wire [17:0]  test; 
	reg [17:0]  minusTest;
	reg [17:0]  expShift = 11'b1;
	reg [17:0] a;
	reg [17:0] b;
	reg [17:0] c;
	reg signed [11:0] alpha = 4;
	reg signed [11:0] beta  = 9;
	reg mo=1;
	
	assign test = 18'h0023f;
	
	always @(*) begin
		expShift = test;
	end
	
	initial begin
	/*
		test      =  (1 << expShift);
		minusTest =  (~(1 << expShift)) + 1;
		
		$display("%32b\n", test);
		$display("%32b\n", minusTest);
		
		c = a - b;
		
		$display("%5b\n", c);
	*/
	/*
	#(10);
	costFuncIntermediate = (mo - sigmoid(test>>>QM));
	c = costFuncIntermediate * (2**QM);
	$display("%h", c);
	$display("%h", test);
	$display("%h", expShift>>>QM);
	$display("%h", test>>>QM);
	$display("%f", sigmoid(test>>>QM));
	$display("%f", costFuncIntermediate);
	*/
	
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
