module array_prod #(parameter ARRAY_LEN = 16,
                     parameter QN   = 6,
                     parameter QM   = 11)
                 (weightRow, 
                  inputVector, 
                  clk,
                  reset,
                  dataReady,
                  finalResult);

    parameter BITWIDTH         = QN + QM + 1;
	parameter ADDR_BITWIDTH    = log2(ARRAY_LEN);
	parameter ARRAY_BITWIDTH   = ARRAY_LEN * BITWIDTH;
	parameter MUX_SIZE         = ARRAY_LEN/4;
	parameter MUX_BITWIDTH     = log2(MUX_SIZE);
    parameter N_DSP48          = 4; 
    parameter DSP48_INPUT_BITWIDTH  = BITWIDTH*N_DSP48;
    parameter DSP48_OUTPUT_BITWIDTH = (2*BITWIDTH+1)*N_DSP48;
    parameter MAC_BITWIDTH       = (2*BITWIDTH+1);
    parameter INT_ADDER_BITWIDTH = (2*BITWIDTH);
	
	input signed [ARRAY_BITWIDTH-1:0] weightRow; 
	input signed [ARRAY_BITWIDTH-1:0] inputVector; 
	input                      clk;
	input        			   reset;
	output reg  			   		  dataReady;
	output reg signed [BITWIDTH-1:0] finalResult;
	
    // Internal register definition
    reg [1:0] rowMux;
    reg signed [DSP48_OUTPUT_BITWIDTH -1:0] outputMAC;
    reg signed [INT_ADDER_BITWIDTH -1:0] Adder1;
    integer i;

    // FSM Registers
    reg [2:0] state;
    reg [2:0] NEXTstate;
    reg [MUX_BITWIDTH-1:0] NEXTrowMux;
    reg clearMAC;
    parameter IDLE = 3'd0;
    parameter CALC = 3'd1;
    parameter FINALSUM  = 3'd2;
    parameter FINALSUM2 = 3'd3;
    parameter END  = 3'd4;
    
	always @(posedge clk) begin
		if (reset)
            outputMAC <= {DSP48_OUTPUT_BITWIDTH{1'b0}};
        else
			for (i=0; i < N_DSP48; i = i + 1) begin
				outputMAC[i*MAC_BITWIDTH +: MAC_BITWIDTH] <=  $signed(weightRow[(i*2+rowMux)*BITWIDTH +: BITWIDTH]) * $signed(inputVector[(i*2+rowMux)*BITWIDTH +: BITWIDTH]);
			end	
    end
    
    always @(posedge clk) begin
		if(reset) begin
			Adder1 <= {INT_ADDER_BITWIDTH{1'b0}};
		end
		else begin
			Adder1[0 +: BITWIDTH]        <= (outputMAC[0 +: MAC_BITWIDTH] >>> QM)       + (outputMAC[MAC_BITWIDTH +: MAC_BITWIDTH]   >>> QM);
			Adder1[BITWIDTH +: BITWIDTH] <= (outputMAC[2*MAC_BITWIDTH +: MAC_BITWIDTH] >>> QM) + (outputMAC[3*MAC_BITWIDTH +: MAC_BITWIDTH] >>> QM);
		end
	end
    
    always @(posedge clk) begin
		if(reset)
			finalResult <= {BITWIDTH{1'b0}};
		else
			finalResult <= finalResult + Adder1[0 +: BITWIDTH] + Adder1[BITWIDTH +: BITWIDTH];
	end

// The control signal FSM
    always @(posedge clk) begin
        if(reset == 1'b1) begin 
            state  <= 3'd0;
            rowMux <= {MUX_BITWIDTH{1'b0}};
        end
        else begin
            state      <= NEXTstate;
            rowMux     <= NEXTrowMux;
        end            
    end      
    
    // Combinational block that produces the next state 
    always @(*) begin
        case(state)
            IDLE : 
                NEXTstate = CALC;
            CALC :
                if (rowMux == (MUX_SIZE-1))
                    NEXTstate = FINALSUM;
                else
                    NEXTstate = CALC;
            FINALSUM :
                NEXTstate = FINALSUM2;
            FINALSUM2 :
                NEXTstate = END;
			END	:
				NEXTstate = IDLE;
            default:
                NEXTstate = IDLE;
        endcase   
    end

    // Combinational block that produces the control signals
    always @(*) begin
        case(state)
            IDLE : 
            begin
                dataReady      = 1'b0;  
                NEXTrowMux     = 1;     
            end
            
            CALC :
            begin
                dataReady      = 1'b0;
                NEXTrowMux     = rowMux + 1;
            end
            
            FINALSUM :
            begin
                dataReady      = 1'b0;  
                NEXTrowMux     = {MUX_BITWIDTH{1'b0}};      
            end
            
            FINALSUM2 :
            begin
                dataReady      = 1'b0;  
                NEXTrowMux     = {MUX_BITWIDTH{1'b0}};      
            end
                   
            END :
            begin
                dataReady      = 1'b1;  
                NEXTrowMux     = {MUX_BITWIDTH{1'b0}};      
            end
            
            default:
            begin
                dataReady      = 1'b0;     
                NEXTrowMux     = {MUX_BITWIDTH{1'b0}};      
            end
        endcase   
    end

    
function integer log2;
	input [31:0] argument;
	integer k;
	begin
		 log2 = -1;
		 k = argument;  
		 while( k > 0 ) begin
			log2 = log2 + 1;
			k = k >> 1;
		 end
	end
endfunction
    
endmodule
