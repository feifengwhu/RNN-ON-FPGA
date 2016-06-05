module test();
	parameter BITWIDTH = 18;
	parameter QM = 11;
	parameter real e = 2.718281828459045;
	integer i, j, fid, stuff;
	real tempreal, costFuncIntermediate;
	wire [17:0]  test; 
	reg [17:0]  minusTest;
	reg [17:0]  expShift = 11'b1;
	reg [3:0] a = 5;
	reg [3:0] b = 8;
	reg [17:0] c;
	reg mo=1;
	
	assign test = 18'h0212f;
	
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
	#(10);
	costFuncIntermediate = (mo - sigmoid(test>>>QM));
	c = costFuncIntermediate * (2**QM);
	$display("%h", c);
	$display("%h", test);
	$display("%h", expShift>>>QM);
	$display("%h", test>>>QM);
	$display("%f", sigmoid(test>>>QM));
	$display("%f", costFuncIntermediate);
	
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
