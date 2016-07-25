module test();

	reg signed [36:0] numA = 18'h3f800;
	reg signed [36:0] numB = 18'h00400;
	reg signed [37:0] res = 37'd1 << 11;
	reg signed [17:0] resNorm;
	reg clock;

	// Clock generation

	initial begin
		res = ($signed(numA[17:0]) * $signed(numB[17:0])) + $signed(res);
		resNorm = res>>11;
		$display("%h\n", resNorm);
	end


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
//'0x5c634690'

 //
