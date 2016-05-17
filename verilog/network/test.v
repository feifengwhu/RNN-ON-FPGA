module test();
	integer i, j, fid, stuff;
	reg [143:0]  test; 
	reg [143:0] matrix [7:0];
	parameter BITWIDTH=18;
	parameter INPUT_SZ=8;
	parameter HIDDEN_SZ=8;
	
	/*
	initial begin
		$fscanf(fid_in,  "%b\n", inputVec)
		$display("Res: %f", i / (2**11));//Qnm2real(temp));
	end
	*/
	/*
	initial begin
		fid = $fopen("goldenIn_bz.bin", "r");
		for (i=0; i < 2; i = i + 1) begin
			stuff = $fscanf(fid, "%b\n", temp);
			#(10);
			test[i*18 +: 18] = temp;
			$display ("Content: %b", test);
			$display ("Return: %b", temp);
		end
	end
	*/
	
	initial begin
	
		fid = $fopen("goldenIn_Rz.bin", "r");		
	
		for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
                stuff = $fscanf(fid, "%b\n", matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
	
		for(i = 0; i < INPUT_SZ; i = i + 1) begin
            for(j = 0; j < HIDDEN_SZ; j = j + 1) begin
               $display("Content: %x",  matrix[i][j*BITWIDTH +: BITWIDTH]);
            end
        end
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
