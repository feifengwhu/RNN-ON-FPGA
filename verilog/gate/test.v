module test();

    reg [17:0] ram [0:4][0:15][0:1];
    reg [17*16:0] temp;
    
    integer i;


    initial begin
        $readmemb("goldenIn_Wy.bin", ram);

        #(10);

        for(i = 0; i < 16; i = i + 1) begin
            temp[i*18 +: 18] <= ram[0][i][0];
        end
        
        #(10);
        
        $display("%x", temp[17:0]);
        $display("%x", temp[35:18]);
    end
endmodule
