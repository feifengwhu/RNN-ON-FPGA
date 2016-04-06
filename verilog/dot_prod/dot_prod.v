module dot_prod #(parameter NROW = 16,
                  parameter NCOL = 16,
                  parameter QN   = 6,
                  parameter QM   = 11,
                  parameter BITWIDTH = QN + QM + 1,
                  parameter MEMORY_BITWIDTH  = BITWIDTH*NROW,
                  parameter DSP48_PER_ROW    = 2, 
                  parameter N_DSP48          = NROW/DSP48_PER_ROW, 
                  parameter ADDR_BITWIDTH = 4)
                 (input signed      [MEMORY_BITWIDTH-1:0] weightRow, 
                  input signed      [BITWIDTH-1:0]        inputVector, 
                  input         clk,
                  input         reset,
                  output reg    dataReady,
                  output reg        [ADDR_BITWIDTH-1:0]        colAddress,
                  output reg signed [MEMORY_BITWIDTH-1:0]      outputVector);

    
    parameter DSP48_INPUT_BITWIDTH = BITWIDTH*N_DSP48;
    parameter DSP48_OUTPUT_BITWIDTH = (2*BITWIDTH+1)*N_DSP48;
    parameter MAC_BITWIDTH = (2*BITWIDTH+1);

    // Internal register definition
    reg [DSP48_PER_ROW:0] rowMux;
    reg                   resetMAC;
    reg signed [DSP48_INPUT_BITWIDTH -1:0] weightMAC;
    reg signed [DSP48_OUTPUT_BITWIDTH-1:0] outputMAC_interm;
    integer i;

    // The control signal FSM
    always @(posedge clk) begin
        if( reset == 1'b1) begin 
            rowMux      <= 2'd0;
            colAddress  <= 4'd0; 
            resetMAC    <= 1'b1;
        end
        else begin
            colAddress <= colAddress + 4'b1;

            if (colAddress == NCOL-1) begin
                rowMux   <= rowMux + 2'b1;
                resetMAC <= 1'b1;
            end 
            else 
                resetMAC <= 1'b0;
            
            if (rowMux == DSP48_PER_ROW-1) 
                dataReady <= 1'b1;
            else
                dataReady <= 1'b0;
        end            
    end       

    // The MAC multiplexer that selects the appropriate weight row for the MAC
    always @(rowMux) begin
        for(i = 0; i < N_DSP48; i = i + 1) begin
            weightMAC[i*BITWIDTH +: BITWIDTH] <= weightRow[(i*DSP48_PER_ROW+rowMux)*BITWIDTH +: BITWIDTH];    
        end
    end
    
    always @(*) begin 
        for(i = 0; i < N_DSP48; i = i + 1) begin
            outputMAC_interm[i*MAC_BITWIDTH +: MAC_BITWIDTH] = weightMAC[i*BITWIDTH +: BITWIDTH] * inputVector;
        end
    end
    
    always @(posedge clk) begin
        if (resetMAC == 1'b0) begin
            for(i = 0; i < N_DSP48; i = i + 1) begin
                outputVector[(i*DSP48_PER_ROW+rowMux)*BITWIDTH +: BITWIDTH] <= outputVector[(i*DSP48_PER_ROW+rowMux)*BITWIDTH +: BITWIDTH] + (outputMAC_interm[i*MAC_BITWIDTH +: MAC_BITWIDTH] >>> BITWIDTH);
            end
        end
        else begin
            for(i = 0; i < N_DSP48; i = i + 1) begin
                outputVector[(i*DSP48_PER_ROW+rowMux)*BITWIDTH +: BITWIDTH] <= 18'd0;
            end
        end
    end
endmodule
