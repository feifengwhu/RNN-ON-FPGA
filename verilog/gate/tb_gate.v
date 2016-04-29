`timescale 1ns / 1ps

module tb_gate();
    
	parameter INPUT_SZ  = 4;
	parameter HIDDEN_SZ = 32;
	parameter QN = 6;
    parameter QM = 11;
	parameter DSP48_PER_ROW = 2;
    
    // Dependent Parameters
    parameter BITWIDTH         = QN + QM + 1;
    parameter INPUT_BITWIDTH   = BITWIDTH*INPUT_SZ;
    parameter LAYER_BITWIDTH   = BITWIDTH*HIDDEN_SZ;
	parameter ADDR_BITWIDTH    = $ln(HIDDEN_SZ)/$ln(2);
	parameter ADDR_BITWIDTH_X  = $ln(INPUT_SZ)/$ln(2);
    parameter HALF_CLOCK       = 1;
    parameter FULL_CLOCK       = 2*HALF_CLOCK;
    parameter MAX_SAMPLES      = 100;

    // DUT Connecting wires/regs
	reg    [ADDR_BITWIDTH_X-1:0] colAddressWrite_X;
	reg    [ADDR_BITWIDTH-1:0]   colAddressWrite_Y;
	wire   [ADDR_BITWIDTH_X-1:0] colAddressRead_X;
	wire   [ADDR_BITWIDTH-1:0]   colAddressRead_Y;
	reg    [LAYER_BITWIDTH-1:0]  weightMemInput_X;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_X;
	reg    [LAYER_BITWIDTH-1:0]  weightMemInput_Y;
	wire   [LAYER_BITWIDTH-1:0]  weightMemOutput_Y;
    wire   [LAYER_BITWIDTH-1:0]  gateOutput;
    wire                         dataReady_gate;
    reg  						 clock;
    reg  						 reset;
    reg  						 beginCalc;
    reg                          writeEn_X;
    reg                          writeEn_Y;
    reg signed [BITWIDTH-1:0] prevLayerOut ;
    reg signed [BITWIDTH-1:0] inputVec;
	reg signed [BITWIDTH-1:0] prevOutVec;
	reg signed [LAYER_BITWIDTH-1:0] biasVec;

    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input       [0:MAX_SAMPLES-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_goldenOut   [0:MAX_SAMPLES-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_prevOut     [0:MAX_SAMPLES-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_bias        [0:MAX_SAMPLES-1] [0:HIDDEN_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_X   [0:MAX_SAMPLES-1] [0:HIDDEN_SZ-1] [0:INPUT_SZ-1];
    reg  [BITWIDTH-1:0] ROM_weights_Y   [0:MAX_SAMPLES-1] [0:HIDDEN_SZ-1] [0:HIDDEN_SZ-1];

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    integer i=0,j=0,k=0,l=0;
    real    quantError=0;
    
    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        /*
        for(i = 0; i < MAX_SAMPLES; i = i + 1) begin
            for(j = 0; j < INPUT_SZ; j = j + 1) begin
				ROM_input[i][j*BITWIDTH +: BITWIDTH] <= 18'b00_0000_100_0000_0000;
			end
        end        
        
        for(i = 0; i < HIDDEN_SZ; i = i + 1) begin
            biasVec[i*BITWIDTH +: BITWIDTH] <= 18'b00_0000_000_0000_0001;
            prevLayerOut[i*BITWIDTH +: BITWIDTH] <= 18'b00_0000_100_0000_0000;
        end
        */

        $readmemb("goldenIn_x.bin",  ROM_input);
        $readmemb("goldenIn_y.bin",  ROM_prevOut);
        $readmemb("goldenOut.bin",   ROM_goldenOut);
        $readmemb("goldenIn_b.bin",  ROM_bias);
        $readmemb("goldenIn_Wx.bin", ROM_weights_X);
        $readmemb("goldenIn_Wy.bin", ROM_weights_Y);
        
    end
    
    // DUT Instantiation
    gate #(INPUT_SZ, HIDDEN_SZ, QN, QM, DSP48_PER_ROW) GATE (inputVec, prevOutVec, weightMemOutput_X, weightMemOutput_Y, biasVec, beginCalc,
														     clock, reset, colAddressRead_X, colAddressRead_Y, dataReady_gate, gateOutput);
    weightRAM  #(HIDDEN_SZ,  INPUT_SZ, BITWIDTH)  WRAM_X (colAddressWrite_X, colAddressRead_X, writeEn_X, clock, reset, weightMemInput_X, weightMemOutput_X);
    weightRAM  #(HIDDEN_SZ, HIDDEN_SZ, BITWIDTH)  WRAM_Y (colAddressWrite_Y, colAddressRead_Y, writeEn_Y, clock, reset, weightMemInput_Y, weightMemOutput_Y);
    
    // Keeping track of the simulation time
    real time_start, time_end;

    always @(negedge clock) begin
        if( reset == 1'b1) begin
            inputVec   <= {BITWIDTH{1'b0}};
            prevOutVec <= {BITWIDTH{1'b0}};
        end
        else begin
            inputVec   <= ROM_input  [i][colAddressRead_X];
            prevOutVec <= ROM_prevOut[i][colAddressRead_Y];
        end
    end

    // Running the simulation
    initial begin
        time_start = $realtime;

        $display("Simulation started at %f", time_start);

        // Initializing the clock and applying the initial reset
        writeEn_X = 0;
        writeEn_Y = 0;
        clock   = 1;
        reset   = 0;
        beginCalc = 0;
    
        @(posedge clock);

        reset     <= 1;
        writeEn_Y <= 1;
        writeEn_X <= 1;

        for(k = 0; k < HIDDEN_SZ; k = k + 1) begin
            if(k < INPUT_SZ) begin
                colAddressWrite_Y = k;
                colAddressWrite_X = k;
            end
            else begin
                colAddressWrite_Y = k;
                writeEn_X <= 0;
            end

            biasVec[k*BITWIDTH+:BITWIDTH] <= ROM_bias[i][k];

            for(l = 0; l < HIDDEN_SZ; l = l + 1) begin
                weightMemInput_Y[l*BITWIDTH+:BITWIDTH] <= ROM_weights_Y[i][l][k];
                weightMemInput_X[l*BITWIDTH+:BITWIDTH] <= ROM_weights_X[i][l][k];
            end
            @(posedge clock);
        end
        reset <= 0;
        writeEn_Y <= 0;

        beginCalc = 1;
        #(FULL_CLOCK);
        beginCalc = 0;

        for(i=0; i < MAX_SAMPLES; i = i + 1) begin
            @(posedge dataReady_gate);
            
            #(HALF_CLOCK);
            
            for(j=0; j < HIDDEN_SZ; j = j + 1) begin
                $display("OUTP %b\nREAL %b", gateOutput[j*BITWIDTH+:BITWIDTH], ROM_goldenOut[i][j]);
                //$fwrite(fid, "0x%X", outputVec[j*BITWIDTH+:BITWIDTH]);
                quantError = quantError + (ROM_goldenOut[i][j] - gateOutput[j*BITWIDTH+:BITWIDTH])/(2.0**QM);
                //$display("Error: %b",(ROM_goldenOut[i][j] ^ outputVec[j*BITWIDTH+:BITWIDTH]) & ({ {(QN+1){1'b1}}, {(QM){1'b0}} }));
            end
 
            @(posedge clock);
            reset     <= 1;
            writeEn_Y <= 1;
            writeEn_X <= 1;

            for(k = 0; k < HIDDEN_SZ; k = k + 1) begin
                if(k < INPUT_SZ) begin
                    colAddressWrite_Y = k;
                    colAddressWrite_X = k;
                end
                else begin
                    colAddressWrite_Y = k;
                    writeEn_X <= 0;
                end

                biasVec[k*BITWIDTH+:BITWIDTH] <= ROM_bias[i+1][k];

                for(l = 0; l < HIDDEN_SZ; l = l + 1) begin
                    weightMemInput_Y[l*BITWIDTH+:BITWIDTH] <= ROM_weights_Y[i+1][l][k];
                    weightMemInput_X[l*BITWIDTH+:BITWIDTH] <= ROM_weights_X[i+1][l][k];
                end
                @(posedge clock);
            end
            reset <= 0;
            writeEn_Y <= 0;
            
            beginCalc = 1;
            #(FULL_CLOCK);  
            beginCalc = 0; 

            //$display("Simulated %d samples\n", i);
            
        end
       
        $display("Average Quantization Error: %f", quantError/(MAX_SAMPLES*HIDDEN_SZ));
 
        $stop; 
    end
endmodule
            
    
        

