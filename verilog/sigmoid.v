module sigmoid  #(parameter QN = 6,
                  parameter QM = 11) 
                 (input       [QN+QM:0] operand,
                  input                 clk,
                  input                 reset,
                  output reg  [QN+QM:0] result);
   
    parameter BITWIDTH = QN + QM + 1;

    // The polynomial coefficients. FORMAT: pn_ix, where n is the degree of the associated x term, and x is the corresponding interval 
    reg signed [QN+QM:0] p2_i1 =       
    reg signed [QN+QM:0] p1_i1 =       
    reg signed [QN+QM:0] p0_i1 =       
    reg signed [QN+QM:0] p2_i2 =       
    reg signed [QN+QM:0] p1_i2 =       
    reg signed [QN+QM:0] p0_i2 =       
    reg signed [QN+QM:0] p2_i3 =       
    reg signed [QN+QM:0] p1_i3 =       
    reg signed [QN+QM:0] p0_i3 =       
    reg signed [QN+QM:0] p2_i4 =       
    reg signed [QN+QM:0] p1_i4 =       
    reg signed [QN+QM:0] p0_i4 =       

    reg signed [QN+QM:0] p2;
    reg signed [QN+QM:0] p1;
    reg signed [QN+QM:0] p0;

    // The state register
    reg state = 1'b0;
    reg signed [2*BITWIDTH:0] outputInt;
    reg signed [BITWIDTH-1:0] multiplierMux;
    reg signed [BITWIDTH-1:0] adderMux;
    reg signed [BITWIDTH-1:0] operandPipe1;
    reg signed [BITWIDTH-1:0] operandPipe2;

    // Interval selector logic
    always @(*) begin
        if (operandPipe1[17:11] < -7'd6) begin
            p2 <= 18'd0;  
            p1 <= 18'd0;   
            p0 <= 18'd0;   
        end
        else if (operandPipe1[17:11] < -7'd3) begin
            p2 <= p2_i1;
            p1 <= p1_i1;
            p0 <= p0_i1;
        end
        else if (operandPipe1[17:11] < 7'd0) begin
            p2 <= p2_i2;
            p1 <= p1_i2;
            p0 <= p0_i2;
        end
        else if (operandPipe1[17:11] < 7'd3) begin
            p2 <= p2_i3;
            p1 <= p1_i3;
            p0 <= p0_i3;
        end
        else if (operandPipe1[17:11] < 7'd6) begin
            p2 <= p2_i4;
            p1 <= p1_i4;
            p0 <= p0_i4;
        end
        else  begin
            p2 <= 0;
            p1 <= 0;
            p0 <= 18'd1;
        end
    end

    // The coefficient multiplier input Muxes
    always @(*) begin
        if (state = 1'b0) begin
            multiplierMux = p2;
            addedMux = p1;
        end
        else begin
            multiplierMux = result;
            addedMux = p0;
        end
    end
            
    // The input operand pipeline
    always @(posedge clk) begin
        operandPipe1 <= operand;
        operandPipe2 <= operandPipe1;
    end

    // The DSP Slices 
    always @(posedge clk) begin
        count  <= count + 1'b1;
        outputInt <= multiplierMux * operandPipe2;
        result <= outputInt + adderMux; 
    end        

endmodule
