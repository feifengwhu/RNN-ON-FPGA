module tb_sigmoid();
    
    parameter BITWIDTH = 18;
    parameter HALF_CLOCK = 100;
    parameter FULL_CLOCK = 2*HALF_CLOCK;
    
    // The golden inputs/outputs ROM
    reg  [BITWIDTH-1:0] ROM_input     [0:262143];   
    reg  [BITWIDTH-1:0] ROM_goldenOut [0:262143];   

    // DUT Connecting wires/regs
    reg  [BITWIDTH-1:0] operand;
    wire [BITWIDTH-1:0] result;

    reg clock;
    reg reset;

    // File descriptors for the error/output dumps
    integer fid, fid_error_dump;

    // Clock generation
    always begin
        #(HALF_CLOCK) clock = ~clock;
        #(HALF_CLOCK) clock = ~clock;
    end

    // Loads golden inputs/outputs to ROM
    initial begin
        $readmemh("sigmoid_goldenIN.hex", ROM_input);
        $readmemh("sigmoid_goldenOUT.hex", ROM_goldenOut);
        fid_error_dump = $fopen("error_dump.txt", "w");
        fid = $fopen("myout.hex", "w");
    end
    
    // DUT Instantiation
    sigmoid SIGMOID01  
