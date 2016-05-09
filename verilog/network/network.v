module network  #(parameter INPUT_SZ   =  2,
                  parameter HIDDEN_SZ  = 16,
                  parameter OUTPUT_SZ  =  1,//NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW_G = 2,
                  parameter DSP48_PER_ROW_M = 2)
                 (inputVec,
                  trainingFlag,
                  clock,
                  reset,
                  newSample,
                  dataoutReady,
                  outputVec);

    // Dependent parameters
    parameter BITWIDTH           = QN + QM + 1;
    parameter INPUT_BITWIDTH     = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH     = BITWIDTH*HIDDEN_SZ;
    parameter MULT_BITWIDTH      = (2*BITWIDTH+1);
    parameter ELEMWISE_BITWIDTH  = MULT_BITWIDTH*HIDDEN_SZ;
    parameter OUTPUT_BITWIDTH    = OUTPUT_SZ * BITWIDTH; //log2(NUM_OUTPUT_SYMBOLS);
	parameter ADDR_BITWIDTH      = log2(HIDDEN_SZ);
	parameter ADDR_BITWIDTH_X    = log2(INPUT_SZ);
	parameter MUX_BITWIDTH		  = log2(DSP48_PER_ROW_M);  
	parameter N_DSP48            = HIDDEN_SZ/DSP48_PER_ROW_M; 
	
    // Input/Output definitions
    input [INPUT_BITWIDTH-1:0]       inputVec;
    input                            trainingFlag;
    input                            clock;
    input                            reset;
    input                            newSample;
    output reg                       dataoutReady;
    output reg [OUTPUT_BITWIDTH-1:0] outputVec;
            

    // Connecting wires and auxiliary registers
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wZX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wZY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wZX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wZY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wIX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wIY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wIX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wIY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wFX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wFY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wFX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wFY;
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wOX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wOY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wOX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wOY;
    reg    [LAYER_BITWIDTH-1:0]  wZX_in;
    wire   [LAYER_BITWIDTH-1:0]  wZX_out;
    reg    [LAYER_BITWIDTH-1:0]  wZY_in;
    wire   [LAYER_BITWIDTH-1:0]  wZY_out;
    reg    [LAYER_BITWIDTH-1:0]  wIX_in;
    wire   [LAYER_BITWIDTH-1:0]  wIX_out;
    reg    [LAYER_BITWIDTH-1:0]  wIY_in;
    wire   [LAYER_BITWIDTH-1:0]  wIY_out;
    reg    [LAYER_BITWIDTH-1:0]  wFX_in;
    wire   [LAYER_BITWIDTH-1:0]  wFX_out;
    reg    [LAYER_BITWIDTH-1:0]  wFY_in;
    wire   [LAYER_BITWIDTH-1:0]  wFY_out;
    reg    [LAYER_BITWIDTH-1:0]  wOX_in;
    wire   [LAYER_BITWIDTH-1:0]  wOX_out;
    reg    [LAYER_BITWIDTH-1:0]  wOY_in;
    wire   [LAYER_BITWIDTH-1:0]  wOY_out;
    wire   [LAYER_BITWIDTH-1:0]  gate_Z;
    wire   [LAYER_BITWIDTH-1:0]  gate_I;
    wire   [LAYER_BITWIDTH-1:0]  gate_F;
    wire   [LAYER_BITWIDTH-1:0]  gate_O;
    wire                         gateReady_Z;
    wire                         gateReady_I;
    wire                         gateReady_F;
    wire                         gateReady_O;
    reg                          beginCalc;
    reg                          writeEn_wZX;
    reg                          writeEn_wZY;
    reg                          writeEn_wIX;
    reg                          writeEn_wIY;
    reg                          writeEn_wFX;
    reg                          writeEn_wFY;
    reg                          writeEn_wOX;
    reg                          writeEn_wOY;
    reg                          z_ready;
    reg                          f_ready;
    reg                          y_ready;
    reg signed [LAYER_BITWIDTH-1:0]    prevLayerOut;
    reg signed [BITWIDTH-1:0]    inputVecSample;
    reg signed [BITWIDTH-1:0]    prevOutVecSample;
    reg signed [LAYER_BITWIDTH-1:0] bZ;
    reg signed [LAYER_BITWIDTH-1:0] bI;
    reg signed [LAYER_BITWIDTH-1:0] bF;
    reg signed [LAYER_BITWIDTH-1:0] bO;
    reg signed [ELEMWISE_BITWIDTH-1:0] elemWiseMult_out;

    // Internal datapath registers
    reg [1:0] muxStageSelector;
    reg signed  [LAYER_BITWIDTH-1:0] ZI_prod;
    reg signed  [LAYER_BITWIDTH-1:0] CF_prod;
    wire signed [LAYER_BITWIDTH-1:0] layer_C;
    reg signed  [LAYER_BITWIDTH-1:0] prev_C;
    reg signed  [MUX_BITWIDTH-1:0] rowMux;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_op1;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_op2;
    reg signed  [LAYER_BITWIDTH-1:0] elemWise_mult1;
    wire signed  [LAYER_BITWIDTH-1:0] elemWise_mult2;
    wire signed  [LAYER_BITWIDTH-1:0] tanh_result;
    
    // FSM associated registers

    integer j;

    // Module Instatiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_Z (inputVecSample, prevOutVecSample, wZX_in, wZY_in, bZ, beginCalc,
                                                             clock, reset, colAddressRead_wZX, colAddressRead_wZY, gateReady_Z, gate_Z);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_Z_X (colAddressWrite_wZX, colAddressRead_wZX, writeEn_wZX, clock, reset, wZX_in, wZX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_Z_Y (colAddressWrite_wZY, colAddressRead_wZY, writeEn_wZY, clock, reset, wZY_in, wZY_out);
 
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_I (inputVecSample, prevOutVecSample, wIX_in, wIY_in, bI, beginCalc,
                                                             clock, reset, colAddressRead_wIX, colAddressRead_wIY, gateReady_I, gate_I);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_I_X (colAddressWrite_wIX, colAddressRead_wIX, writeEn_wIX, clock, reset, wIX_in, wIX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_I_Y (colAddressWrite_wIY, colAddressRead_wIY, writeEn_wIY, clock, reset, wIY_in, wIY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_F (inputVecSample, prevOutVecSample, wFX_in, wFY_in, bF, beginCalc,
                                                             clock, reset, colAddressRead_wFX, colAddressRead_wFY, gateReady_F, gate_F);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_F_X (colAddressWrite_wFX, colAddressRead_wFX, writeEn_wFX, clock, reset, wFX_in, wFX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_F_Y (colAddressWrite_wFY, colAddressRead_wFY, writeEn_wFY, clock, reset, wFY_in, wFY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW_G) GATE_O (inputVecSample, prevOutVecSample, wOX_in, wOY_in, bO, beginCalc,
                                                             clock, reset, colAddressRead_wOX, colAddressRead_wOY, gateReady_O, gate_O);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_O_X (colAddressWrite_wOX, colAddressRead_wOX, writeEn_wOX, clock, reset, wOX_in, wOX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_O_Y (colAddressWrite_wOY, colAddressRead_wOY, writeEn_wOY, clock, reset, wOY_in, wOY_out);

    genvar i;
    
    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            sigmoid #(QN,QM) sigmoid_i (elemWise_op2[i*BITWIDTH +: BITWIDTH], clock, reset, elemWise_mult2[i*BITWIDTH +: BITWIDTH]);
        end 
    endgenerate 

    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            tanh #(QN,QM) tanh_i (elemWise_op1[i*BITWIDTH +: BITWIDTH], clock, reset, tanh_result[i*BITWIDTH +: BITWIDTH]);
        end 
    endgenerate 

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        case (muxStageSelector) 
            2'd0 : begin
                elemWise_op1 <= gate_Z;
                elemWise_op2 <= gate_I;
            end
        
            2'd1 : begin
                elemWise_op1 <= 18'b0;
                elemWise_op2 <= gate_F;
            end

            2'd2 : begin
                elemWise_op1 <= layer_C;
                elemWise_op2 <= gate_O;
            end
            
            default : begin
				elemWise_op1 <= gate_Z;
                elemWise_op2 <= gate_I;
            end
        endcase
    end

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        if(muxStageSelector == 2'd1)
            elemWise_mult1 = prev_C;
        else
            elemWise_mult1 = tanh_result;
    end  
    
    // Partial Non-liearity/Elementwise Block Result --- z signal TIMES i signal
    always @(posedge z_ready) begin
        for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			ZI_prod[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: BITWIDTH];
		end
    end

    // Partial Non-liearity/Elementwise Block Result --- c signal TIMES f signal
    always @(posedge f_ready) begin
        for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			CF_prod[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: BITWIDTH];
		end
    end
     
    // Saving the current layer output (that serves as input to the gate modules)
    always @(posedge y_ready) begin
        for(j=0; j < HIDDEN_SZ; j = j + 1) begin
			prevLayerOut[j*BITWIDTH +: BITWIDTH] <= elemWiseMult_out[j*MULT_BITWIDTH +: BITWIDTH];
		end
    end

    // The C signal --- The memory element
    assign layer_C = ZI_prod + CF_prod;
    always @(posedge newSample) begin
        prev_C <= layer_C;
    end
    
    // The elementwise multiplication DSP slices
    always @(posedge clock) begin
        for(j=0; j < N_DSP48; j = j + 1) begin
            elemWiseMult_out[(j*DSP48_PER_ROW_M+rowMux)*MULT_BITWIDTH +: MULT_BITWIDTH] <= (($signed(elemWise_mult2[(j*DSP48_PER_ROW_M+rowMux)*BITWIDTH +: BITWIDTH]) * 
																							 $signed(elemWise_mult1[(j*DSP48_PER_ROW_M+rowMux)*BITWIDTH +: BITWIDTH])) >>> QM);
        end
    end

    // --------------------- FINITE STATE MACHINE --------------------- //
    
    // The state tags
    parameter IDLE        = 4'd0;
    parameter GATE_CALC   = 4'd1;
    parameter NON_LIN_1A  = 4'd2;
    parameter NON_LIN_2A  = 4'd3;
    parameter ELEM_PROD_A = 4'd4;
    parameter NON_LIN_1B  = 4'd5;
    parameter NON_LIN_2B  = 4'd6;
    parameter ELEM_PROD_B = 4'd7;
    parameter NON_LIN_1C  = 4'd8;
    parameter NON_LIN_2C  = 4'd9;
    parameter ELEM_PROD_C = 4'd10;
    parameter END         = 4'd11;
    
    // The FSM registers
    reg [3:0] state;
    reg [3:0] NEXTstate;
    reg       sigmoidEnable;
    reg       tanhEnable;
    
    // The FSM that controls the gate
    always @(posedge clock) begin
		if (reset == 1'b1) begin
			state <= 3'd0;
		end
		else begin
			state <= NEXTstate;
		end
	end
	
	// Combinational logic that produces the next state
	always @(*) begin
		case(state)		
			IDLE :
			begin
				if ( newSample == 1'b1)
					NEXTstate = GATE_CALC;
				else
					NEXTstate = IDLE;
			end
			
			GATE_CALC:
			begin
				if (gateReady_Z == 1'b1 || gateReady_I == 1'b1 || gateReady_F == 1'b1 || gateReady_O == 1'b1)
					NEXTstate = NON_LIN_1A;
				else 
					NEXTstate = GATE_CALC;
			end
			
			NON_LIN_1A:		
			begin
				NEXTstate = NON_LIN_2A;
			end
			
			NON_LIN_2A:		
			begin
				NEXTstate = ELEM_PROD_A;
			end	
			
			ELEM_PROD_A:
			begin

			end
			
			NON_LIN_1B:		
			begin
				NEXTstate = NON_LIN_2B;
			end
			
			NON_LIN_2B:		
			begin
				NEXTstate = ELEM_PROD_B;
			end	
			
			ELEM_PROD_B:
			begin

			end
			
			NON_LIN_1C:		
			begin
				NEXTstate = NON_LIN_2C;
			end
			
			NON_LIN_2C:		
			begin
				NEXTstate = ELEM_PROD_C;
			end	
			
			ELEM_PROD_C:
			begin

			end
			
			END :
				NEXTstate = IDLE;
				
			default:
				NEXTstate = IDLE;
				
		endcase
	end
	
	// Combinational block that produces the outputs and control signals
	always @(*) begin
		case(state)		
			IDLE :
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			GATE_CALC:
			begin
				beginCalc        = 1'b1;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			NON_LIN_1A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			NON_LIN_2A:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			ELEM_PROD_A:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			NON_LIN_1B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b1;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			NON_LIN_2B:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			ELEM_PROD_B:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b1;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			NON_LIN_1C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b1;
				y_ready          = 1'b0;
			end
			
			NON_LIN_2C:		
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b1;
				tanhEnable       = 1'b1;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			ELEM_PROD_C:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd2;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
			
			END :
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'd0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b1;
			end
				
			default:
			begin
				beginCalc        = 1'b0;
				muxStageSelector = 2'b0;
				sigmoidEnable    = 1'b0;
				tanhEnable       = 1'b0;
				z_ready          = 1'b0;
				f_ready          = 1'b0;
				y_ready          = 1'b0;
			end
				
		endcase
	end
    
    // ---------------------------------------------------------------- //
    
        
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
