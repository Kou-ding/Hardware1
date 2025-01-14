`timescale 1ns / 1ps

module regfile_tb();

    parameter DATAWIDTH = 32;

    reg clk;
    reg [4:0] readReg1, readReg2, writeReg;
    reg [DATAWIDTH-1:0] writeData;
    reg write;
    wire [DATAWIDTH-1:0] readData1, readData2;

    // Instantiate regfile
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

    // Ρολόι
    initial clk = 0;
    always #5 clk = ~clk; // Περίοδος 10 ns

    initial begin
        $display("Ξεκινά το Testbench...");
        // Αρχικοποίηση σημάτων
        readReg1 = 0;
        readReg2 = 0;
        writeReg = 0;
        writeData = 0;
        write = 0;

        // Test 1: Εγγραφή και ανάγνωση σε καταχωρητές
        #10 writeReg = 5'b00001; writeData = 32'hDEADBEEF; write = 1;
        #10 write = 0;
        #10 readReg1 = 5'b00001; readReg2 = 5'b00010;

        if (readData1 !== 32'hDEADBEEF) $display("Test FAILED: Write/Read Reg 1!");

        // Test 2: Προτεραιότητα στην εγγραφή
        #10 writeReg = 5'b00001; writeData = 32'h12345678; write = 1;
        readReg1 = 5'b00001;
        #10;
        if (readData1 !== 32'h12345678) $display("Test FAILED: Write Priority!");

        // Test 3: Έλεγχος μηδενικού καταχωρητή
        #10 writeReg = 5'b00000; writeData = 32'hFFFFFFFF; write = 1;
        #10 write = 0; readReg1 = 5'b00000;
        if (readData1 !== 32'h00000000) $display("Test FAILED: Zero Register!");

        // Test 4: Ανάγνωση από διαφορετικούς καταχωρητές
        #10 writeReg = 5'b00010; writeData = 32'hCAFEBABE; write = 1;
        #10 write = 0; readReg2 = 5'b00010;
        if (readData2 !== 32'hCAFEBABE) $display("Test FAILED: Read Reg 2!");

        $display("Όλα τα τεστ ολοκληρώθηκαν!");
        $finish;
    end

endmodule
