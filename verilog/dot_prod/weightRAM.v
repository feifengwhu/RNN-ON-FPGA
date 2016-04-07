module weightRAM #(parameter NROW = 16,
                   parameter NCOL = 16,
                   parameter BITWIDTH = 18,
                   parameter OUTPUT_PORT_SIZE = BITWIDTH*NROW,
                   parameter ADDR_BITWIDTH = 4)
                  (input       [ADDR_BITWIDTH-1:0] address,
                   input                       clk,
                   input                       reset,
                   output reg  [OUTPUT_PORT_SIZE-1:0]  rowOutput);
   
    // The RAM registers
    reg [BITWIDTH-1:0] RAM_matrix [0:NROW-1] [0:NCOL-1];    

    // Loading the RAM with dummy values
    integer i, j;
    initial begin        
        for(i = 0; i < NROW; i = i + 1) begin
            for(j = 0; j < NCOL; j = j + 1) begin
                RAM_matrix[i][j] <= (NROW*i+j)<<<11; 
            end
        end
    end

    always @(posedge clk) begin
        for(i = 0; i < NROW; i = i + 1) begin
            rowOutput[i*BITWIDTH +: BITWIDTH] <= RAM_matrix[i][address];
        end
    end

endmodule
