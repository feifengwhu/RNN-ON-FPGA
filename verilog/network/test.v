module test();
	integer i, fid, stuff;
	reg [17:0]  temp; 
	reg [143:0] test;
	
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
	
endmodule
