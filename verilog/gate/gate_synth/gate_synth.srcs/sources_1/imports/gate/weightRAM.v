module weightRAM #(parameter NROW = 16,
                   parameter NCOL = 16,
                   parameter BITWIDTH = 18)
                  (addressIn,
                   addressOut,
                   writeEn,
                   clk,
                   reset,
                   rowIn,
                   rowOut);
   
    // Dependent parameters
    parameter OUTPUT_PORT_SIZE = BITWIDTH*NROW;
    parameter ADDR_BITWIDTH    = log2(NCOL);
    
    // The input/output definitions
    input       [ADDR_BITWIDTH-1:0]     addressIn;
    input       [ADDR_BITWIDTH-1:0]     addressOut;
    input                               clk;
    input                               reset;
    input                               writeEn;
    output reg  [OUTPUT_PORT_SIZE-1:0]  rowOut;
    input       [OUTPUT_PORT_SIZE-1:0]  rowIn;

    // The RAM registers
    reg [BITWIDTH-1:0] RAM_matrix [0:NROW-1] [0:NCOL-1];    

    // Loading the RAM with dummy values
    integer i, j;
    /* 
    initial begin        
        for(i = 0; i < NROW; i = i + 1) begin
            for(j = 0; j < NCOL; j = j + 1) begin
                $readmemb("goldenIn_W.bin", RAM_matrix);
                //RAM_matrix[i][j] <= (j)<<<11; 
            end
        end
    end
    */
    
    always @(negedge clk) begin
        if(writeEn == 1'b1) begin
            for(i = 0; i < NROW; i = i + 1) begin
                RAM_matrix[i][addressIn] <= rowIn[i*BITWIDTH +: BITWIDTH];
            end
        end
        else begin
            for(i = 0; i < NROW; i = i + 1) begin
                rowOut[i*BITWIDTH +: BITWIDTH] <= RAM_matrix[i][addressOut];
            end
        end
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
