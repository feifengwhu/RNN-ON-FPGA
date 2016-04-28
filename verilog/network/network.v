module network  #(parameter INPUT_SZ  =  2,
                  parameter HIDDEN_SZ = 16,
                  parameter NUM_OUTPUT_SYMBOLS = 2,
                  parameter QN        =  6,
                  parameter QM        = 11,
                  parameter DSP48_PER_ROW = 2)
                 (inputVec,
                  trainingFlag,
                  clock,
                  reset,
                  newSample,
                  dataoutReady,
                  outputVec);

    // Dependent parameters
    parameter BITWIDTH = QN + QM + 1;
    parameter INPUT_BITWIDTH  = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH  = BITWIDTH*LAYER_SZ;
    parameter OUTPUT_BITWIDTH = $ln(NUM_OUTPUT_SYMBOLS)/$ln(2);

    // Input/Output definitions
    input [INPUT_BITWIDTH-1:0] inputVec;
    input                      trainingFlag;
    input                      clock;
    input                      reset;
    input                      newSample;
    output reg                       dataoutReady;
    output reg [OUTPUT_BITWIDTH-1:0] outputVec;
            

    // Connecting wires and auxiliary registers
    reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_wZX;
    reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_wZY;
    wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_wZX;
    wire   [ADDR_BITWIDTH-1:0]   colAddressRead_wZY;
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
    reg                          clock;
    reg                          reset;
    reg                          beginCalc;
    reg                          writeEn_wZX;
    reg                          writeEn_wZY;
    reg                          writeEn_wIX;
    reg                          writeEn_wIY;
    reg                          writeEn_wFX;
    reg                          writeEn_wFY;
    reg                          writeEn_wOX;
    reg                          writeEn_wOY;
    reg signed [BITWIDTH-1:0]    prevLayerOut;
    reg signed [BITWIDTH-1:0]    inputVecSample;
    reg signed [BITWIDTH-1:0]    prevOutVecSample;
    reg signed [LAYER_BITWIDTH-1:0] bZ;
    reg signed [LAYER_BITWIDTH-1:0] bI;
    reg signed [LAYER_BITWIDTH-1:0] bF;
    reg signed [LAYER_BITWIDTH-1:0] bO;
    reg signed [LAYER_BITWIDTH-1:0] elemWiseMult_out;

    // Internal control registers
    reg [1:0] muxStageSelector;
    reg signed  [LAYER_BITWIDTH-1:0] ZI_prod;
    reg signed  [LAYER_BITWIDTH-1:0] CF_prod;
    wire signed [LAYER_BITWIDTH-1:0] layer_C;
    reg signed  [LAYER_BITWIDTH-1:0] elemWiseMult_op1;
    reg signed  [LAYER_BITWIDTH-1:0] elemWiseMult_op2;

    // Module Instatiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE_Z (inputVecSample, prevOutVecSample, wZX_in, wZY_in, bZ, beginCalc,
                                                             clock, reset, colAddressRead_wZX, colAddressRead_wZY, gateReady_Z, gate_Z);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_Z_X (colAddressWrite_wZX, colAddressRead_wZX, writeEn_wZX, clock, reset, wZX_in, wZX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_Z_Y (colAddressWrite_wZY, colAddressRead_wZY, writeEn_wZY, clock, reset, wZY_in, wZY_out);
 
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE_I (inputVecSample, prevOutVecSample, wIX_in, wIY_in, bI, beginCalc,
                                                             clock, reset, colAddressRead_wIX, colAddressRead_wIY, gateReady_I, gate_I);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_I_X (colAddressWrite_wIX, colAddressRead_wIX, writeEn_wIX, clock, reset, wIX_in, wIX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_I_Y (colAddressWrite_wIY, colAddressRead_wIY, writeEn_wIY, clock, reset, wIY_in, wIY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE_F (inputVecSample, prevOutVecSample, wFX_in, wFY_in, bF, beginCalc,
                                                             clock, reset, colAddressRead_wFX, colAddressRead_wFY, gateReady_F, gate_F);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_F_X (colAddressWrite_wFX, colAddressRead_wFX, writeEn_wFX, clock, reset, wFX_in, wFX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_F_Y (colAddressWrite_wFY, colAddressRead_wFY, writeEn_wFY, clock, reset, wFY_in, wFY_out);

    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE_O (inputVecSample, prevOutVecSample, wOX_in, wOY_in, bz, beginCalc,
                                                             clock, reset, colAddressRead_wOX, colAddressRead_wOY, gateReady_O, gate_O);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_O_X (colAddressWrite_wOX, colAddressRead_wOX, writeEn_wOX, clock, reset, wOX_in, wOX_out);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_O_Y (colAddressWrite_wOY, colAddressRead_wOY, writeEn_wOY, clock, reset, wOY_in, wOY_out);

    genvar i;
    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            sigmoid sigmoid_i #(QN,QM) ( ,elemWise_mult2);
        end 
    endgenerate 

    generate 
        for (i = 0; i < HIDDEN_SZ; i = i + 1) begin
            tanh tanh_i #(QN,QM) ();
        end 
    endgenerate 

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        case (muxStageSelector) :
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
        endcase
    end

    // Selecting the source for the elementwise multiplication first operand
    always @(*) begin
        if(muxStageSelector == 2'd1)
            elemWise_mult1 = prev_C;
        else
            elemWise_mult1 = tanh_result;
    end  
    
    // Partial Non-liearity/Elementwise Block Result --- z signal X i signal
    always @(posedge z_ready) begin
        ZI_prod <= elemWiseMult_out;
    end

    // Partial Non-liearity/Elementwise Block Result --- c signal X f signal
    always @(posedge f_ready) begin
        CF_prod <= elemWiseMult_out;
    end
     
    // Saving the current layer output (that serves as input to the gate modules
    always @(posedge y_ready) begin
        prevLayerOut <= elemWise_out;
    end

    // The C signal --- The memory element
    assign layer_C = ZI_prod + CF_prod;
    always @(posedge newSample) begin
        prev_C <= layer_C;
    end
    
    // The elementwise multiplication DSP slices
    always @(posedge clk) begin
        for(i=0; i < HIDDEN_SZ; i = i + 1) begin
            elemWise_out[(i*DSP48_PER_ROW+rowMux)*BITWIDTH +: BITWIDTH] <= 
                    ({{(QM+QN+2){elemWise_mult2[(i+1)*BITWIDTH-1]}}, elemWise_mult2[i*BITWIDTH +: BITWIDTH]} * {{(QM+QM+2){elemWise_mult1[BITWIDTH-1]}}, elemWise_mult1} >>> QM);
        end
    end

    // --------------------- FINITE STATE MACHINE --------------------- //
