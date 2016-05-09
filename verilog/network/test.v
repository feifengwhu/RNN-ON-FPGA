module test();
	integer i, fid;
	reg [3:0] test;
	
	initial begin
		fid = $fopen("test.bin", "r");
		for (i=0; i < 10; i = i + 1) begin
			$fscanf(fid, "%b\n", test);
			$display ("Content: %b", test);
		end
	end
	
endmodule
