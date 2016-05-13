module test();
	integer i, fid, stuff;
	reg [17:0]  temp; 
	
	initial begin
		temp = 18'b000000010000000000;
		i = temp;
		$display("Res: %f", i / (2**11));//Qnm2real(temp));
	end
	/*
	initial begin
		fid = $fopen("goldenIn_bz.bin", "r");
		for (i=0; i < 8; i = i + 1) begin
			stuff = $fscanf(fid, "%b\n", temp);
			#(10);
			test[i*18 +: 18] = temp;
			$display ("Content: %b", test);
			$display ("Return: %d", stuff);
		end
	end
	*/
function integer Qnm2real;
	input [17:0] arg;
	real res;
	begin
		res = arg; 
		//res = res / (2**11);
	end
endfunction	
	
	
endmodule
