module test();

	integer op;
	
	initial begin
	
	for(op = 2; op < 32; op = op + 1)
		$display("log2(%d) = %d", op, log2(op));
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
