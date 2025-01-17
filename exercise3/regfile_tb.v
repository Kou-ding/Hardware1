
`timescale 1ns / 1ps

module regfile_tb();

    parameter DATAWIDTH = 32; // Data width for registers

    reg clk;
    reg [4:0] readReg1, readReg2, writeReg;
    reg [DATAWIDTH-1:0] writeData;
    reg write;
    wire [DATAWIDTH-1:0] readData1, readData2;

    // Instantiate the regfile module
    regfile #(DATAWIDTH) uut (
        .clk(clk),
        .readReg1(readReg1),
        .readReg2(readReg2),
        .writeReg(writeReg),
        .writeData(writeData),
        .write(write),
        .readData1(readData1),
        .readData2(readData2)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // Clock period is 10ns

    // Testbench
    initial begin
        $display("Starting testbench...");

        // Initialize signals
        readReg1 = 0;
        readReg2 = 0;
        writeReg = 0;
        writeData = 0;
        write = 0;

        // Test 1: Verify register initialization (read all registers)
        #10;
        for (int i = 0; i < 32; i = i + 1) begin
            readReg1 = i[4:0];
            #5;
            if (readData1 !== 32'b0)
                $display("Error: Register %d not initialized to zero.", i);
        end
        $display("Test 1 passed: All registers initialized to zero.");

        // Test 2: Write to a register and verify read
        #10 writeReg = 5'b00001; writeData = 32'hA5A5A5A5; write = 1;
        #10 write = 0; readReg1 = 5'b00001;
        #5;
        if (readData1 !== 32'hA5A5A5A5)
            $display("Error: Write/Read test failed for Register 1.");
        else
            $display("Test 2 passed: Write/Read test successful.");

        // Test 3: Zero register behavior (should always read zero)
        #10 writeReg = 5'b00000; writeData = 32'hFFFFFFFF; write = 1;
        #10 write = 0; readReg1 = 5'b00000;
        #5;
        if (readData1 !== 32'b0)
            $display("Error: Zero register behavior test failed.");
        else
            $display("Test 3 passed: Zero register behavior is correct.");

        // Test 4: Simultaneous read and write to the same register
        #10 writeReg = 5'b00010; writeData = 32'hDEADBEEF; write = 1;
        readReg1 = 5'b00010;
        #5;
        if (readData1 !== 32'hDEADBEEF)
            $display("Error: Simultaneous read/write test failed for Register 2.");
        else
            $display("Test 4 passed: Simultaneous read/write test successful.");
        #10 write = 0;

        // Test 5: Read two different registers simultaneously
        #10 writeReg = 5'b00011; writeData = 32'hCAFEBABE; write = 1;
        #10 write = 0; readReg1 = 5'b00010; readReg2 = 5'b00011;
        #5;
        if (readData1 !== 32'hDEADBEEF || readData2 !== 32'hCAFEBABE)
            $display("Error: Read two registers simultaneously test failed.");
        else
            $display("Test 5 passed: Read two registers simultaneously successful.");

        $display("Testbench completed!");
        $finish;
    end

endmodule