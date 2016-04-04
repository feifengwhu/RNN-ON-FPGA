module tanh     #(parameter QN = 6,
                  parameter QM = 11) 
                 (input signed  [QN+QM:0] operand,
                  input                 clk,
                  input                 reset,
                  output reg  [QN+QM:0] result);
   
    parameter BITWIDTH = QN + QM + 1;

    // The polynomial coefficients. FORMAT: pn_ix, where n is the degree of the associated x term, and x is the corresponding interval 
    reg signed [QN+QM:0] p0_i1 = 18'b111111110011010001;
    reg signed [QN+QM:0] p1_i1 = 18'b000000001110111001;
    reg signed [QN+QM:0] p2_i1 = 18'b000000000010111000;
    reg signed [QN+QM:0] p0_i2 = 18'b000000000000000110;    
    reg signed [QN+QM:0] p1_i2 = 18'b000000100010101100;
    reg signed [QN+QM:0] p2_i2 = 18'b000000001010000111;
    reg signed [QN+QM:0] p0_i3 = 18'b111111111111111001;
    reg signed [QN+QM:0] p1_i3 = 18'b000000100010101111;
    reg signed [QN+QM:0] p2_i3 = 18'b111111110101110111;
    reg signed [QN+QM:0] p0_i4 = 18'b000000001100110001;
    reg signed [QN+QM:0] p1_i4 = 18'b000000001110111001;
    reg signed [QN+QM:0] p2_i4 = 18'b111111111101000111;

    reg signed [QN+QM:0] p2;
    reg signed [QN+QM:0] p1;
    reg signed [QN+QM:0] p0;

    // The state register
    reg state = 1'b0;
    wire signed [2*BITWIDTH:0] outputInt;
    reg signed [BITWIDTH-1:0] multiplierMux;
    reg signed [BITWIDTH-1:0] adderMux;
    reg signed [BITWIDTH-1:0] operandPipe1;
    reg signed [BITWIDTH-1:0] operandPipe2;

    // Interval selector logic
    always @(*) begin
        if (operand < $signed(18'b111110100000000000)) begin
            p2 <= 18'd0;  
            p1 <= 18'd0;   
            p0 <= 18'b111111100000000000;   
        end
        else if (operand < $signed(18'b111111100000000000)) begin
            p2 <= p2_i1;
            p1 <= p1_i1;
            p0 <= p0_i1;
        end
        else if (operand < $signed(18'd0)) begin
            p2 <= p2_i2;
            p1 <= p1_i2;
            p0 <= p0_i2;
        end
        else if (operand < $signed(18'b000000100000000000)) begin
            p2 <= p2_i3;
            p1 <= p1_i3;
            p0 <= p0_i3;
        end
        else if (operand < $signed(18'b000001100000000000)) begin
            p2 <= p2_i4;
            p1 <= p1_i4;
            p0 <= p0_i4;
        end
        else begin
            p2 <= 18'd0;
            p1 <= 18'd0;
            p0 <= 18'b000000100000000000;
        end
    end

    // The coefficient multiplier input Muxes
    always @(*) begin
        if(reset == 1'b1) begin
            multiplierMux <= 18'd0;
            adderMux      <= 18'd0;
        end
        else begin
            if (state == 1'b0) begin
                multiplierMux <= p2;
                adderMux <= p1;
            end
            else begin
                multiplierMux <= result;
                adderMux <= p0;
            end
        end
    end
            
    
    // The DSP Slices 
    always @(posedge clk) begin
        if (reset == 1'b1) begin
            state     <= 1'b0;
            result    <= 18'b0; 
        end
        else begin
            state     <= state + 1'b1;
            result    <= (outputInt>>>QM) + adderMux; 
        end
    end        

    assign outputInt = multiplierMux * operand;

endmodule
