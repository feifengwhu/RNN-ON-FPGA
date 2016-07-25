`timescale 1ns / 1ps

module tb_dot_prod();

    // User defined parameters
    parameter NROW = 32;
    parameter NCOL = 4;
    parameter QN   = 6;
    parameter QM   = 11;
    parameter DSP48_PER_ROW    = 8;

    // Dependent Parameters
    parameter BITWIDTH          = QN + QM + 1;
    parameter MEMORY_BITWIDTH   = BITWIDTH*NROW;
    parameter LAYER_BITWIDTH    = BITWIDTH*NCOL;
	  parameter ADDR_BITWIDTH     = log2(NCOL);
    parameter HALF_CLOCK        = 1;
    parameter FULL_CLOCK        = 2*HALF_CLOCK;
    parameter MAX_SAMPLES       = 100;

    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input     [0:MAX_SAMPLES-1] [0:NCOL-1];
    reg  [BITWIDTH-1:0] ROM_goldenOut [0:MAX_SAMPLES-1] [0:NROW-1];
    reg  [BITWIDTH-1:0] ROM_weights   [0:MAX_SAMPLES-1] [0:NROW-1] [0:NCOL-1];

    // DUT Connecting wires/regs
    wire [MEMORY_BITWIDTH-1:0]   weightMemOutput;
    wire [ADDR_BITWIDTH-1:0]     colAddressRead;
    reg  [ADDR_BITWIDTH-1:0]     colAddressWrite = {ADDR_BITWIDTH{1'b0}};
    reg  [MEMORY_BITWIDTH-1:0]   weightMemInput;
    reg                          writeEn;
    wire [MEMORY_BITWIDTH-1:0]   outputVec;
    wire dataReady;
    reg clock;
    reg reset;
    reg signed [MEMORY_BITWIDTH-1:0] inputVecRAM;
    reg signed [BITWIDTH-1:0] inputVec;

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;
    integer i=0, j=0, k=0, l=0;

    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        //for(i = 0; i < NCOL; i = i + 1) begin
            //inputVec <=  18'b00_0001_000_0000_0000;
       //end

    $readmemb("goldenIn_x.bin", ROM_input);
    $readmemb("goldenIn_W.bin", ROM_weights);
    $readmemb("goldenOut.bin", ROM_goldenOut);
        //fid_error_dump = $fopen("error_dump.txt", "w");
        //fid = $fopen("myout.hex", "w");

    end

    // DUT Instantiation
    dot_prod   #(NROW,NCOL,QN,QM,DSP48_PER_ROW) DOTPROD  (weightMemOutput, inputVec, clock, reset, dataReady, colAddressRead, outputVec);
    weightRAM  #(NROW,NCOL,BITWIDTH)            WRAM     (colAddressWrite, colAddressRead, writeEn, clock, reset, weightMemInput, weightMemOutput);

    always @(posedge clock) begin
        if (reset == 1'b1)
            inputVec = {BITWIDTH{1'b0}};
        else begin
            inputVec = ROM_input[i][colAddressRead];
            //inputVec = 18'h00800;
        end
    end


    // Keeping track of the simulation time
    real time_start, time_end;
    real quantError=0;

    // Running the simulation
    initial begin
        time_start = $realtime;

        $display("Simulation started at %f", time_start);

        // Initializing the clock and applying the initial reset
        writeEn = 0;
        clock   = 1;
        reset   = 0;

        @(posedge clock);
        //#(FULL_CLOCK);
            reset   = 1;
            writeEn = 1;
            for(k = 0; k < NCOL; k = k + 1) begin
                colAddressWrite = k;
                for(l = 0; l < NROW; l = l + 1) begin
                    //weightMemInput[l*BITWIDTH+:BITWIDTH] <= 18'h00800;
                    weightMemInput[l*BITWIDTH+:BITWIDTH] <= ROM_weights[i][l][k];
                end
                @(posedge clock);
            end
            reset = 0;
            writeEn = 0;

        for(i=0; i < MAX_SAMPLES; i = i + 1) begin
            @(posedge dataReady);

            #(HALF_CLOCK);

            for(j=0; j < NROW ; j = j + 1) begin
                $display("OUTP %b\nREAL %b", outputVec[j*BITWIDTH+:BITWIDTH], ROM_goldenOut[i][j]);
                //$fwrite(fid, "0x%X", outputVec[j*BITWIDTH+:BITWIDTH]);
                quantError = quantError + ($signed(ROM_goldenOut[i][j]) - $signed(outputVec[j*BITWIDTH+:BITWIDTH]) )/(2.0**QM);
                //$display("Error: %b",(ROM_goldenOut[i][j] ^ outputVec[j*BITWIDTH+:BITWIDTH]) & ({ {(QN+1){1'b1}}, {(QM){1'b0}} }));
            end

	          #(FULL_CLOCK);

            @(posedge clock);

            reset   <= 1;
            writeEn <= 1;

            for(k = 0; k < NCOL; k = k + 1) begin
                colAddressWrite <= k;
                for(l = 0; l < NROW; l = l + 1) begin
                    //weightMemInput[l*BITWIDTH+:BITWIDTH] <= 18'h00800;
                    weightMemInput[l*BITWIDTH+:BITWIDTH] <= ROM_weights[i+1][l][k];
                end
                @(posedge clock);
            end
            reset <= 0;
            writeEn <= 0;

            $display("Simulated %d samples\n", i);

        end

        $display("Average Quantization Error: %f", quantError/(MAX_SAMPLES*NROW));

        $stop;
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
