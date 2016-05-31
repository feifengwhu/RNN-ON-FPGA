module test();
	integer i, j, fid, stuff;
	reg [17:0]  test; 
	reg [17:0]  minusTest;
	reg [11:0]  expShift = 11'b1;
	reg [3:0] a = 5;
	reg [3:0] b = 8;
	reg [3:0] c;
	
	initial begin
		test      =  (1 << expShift);
		minusTest =  (~(1 << expShift)) + 1;
		
		$display("%32b\n", test);
		$display("%32b\n", minusTest);
		
		c = a - b;
		
		$display("%5b\n", c);
		
		
	end
		
	
function integer Qnm2real;
	input [17:0] arg;
	real res;
	begin
		res = arg; 
		//res = res / (2**11);
	end
endfunction	
	
	
endmodule
