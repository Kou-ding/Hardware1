`timescale 1ns / 1ps

module calc_tb();

    reg clk;
    reg btnc, btnl, btnu, btnr, btnd;
    reg [15:0] sw;
    wire [15:0] led;

    // Instantiate calc
    calc uut (
        .clk(clk),
        .btnc(btnc),
        .btnl(btnl),
        .btnu(btnu),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
    );

    // Ρολόι
    initial clk = 0;
    always #5 clk = ~clk; // Περίοδος 10 ns

    initial begin
        // Αρχικοποίηση
        btnc = 0; btnl = 0; btnu = 0; btnr = 0; btnd = 0; sw = 16'b0;

        $display("Ξεκινάει το Testbench...");

        // Reset
        #10 btnu = 1; #10 btnu = 0;
        if (led !== 16'h0000) $display("Test FAILED: Reset!");

        // ADD
        #10 btnc = 1; sw = 16'h354a; btnd = 1; #10 btnd = 0; btnc = 0;
        if (led !== 16'h354a) $display("Test FAILED: ADD!");

        // SUB
        #10 btnc = 1; btnr = 1; sw = 16'h1234; btnd = 1; #10 btnd = 0; btnc = 0; btnr = 0;
        if (led !== 16'h2316) $display("Test FAILED: SUB!");

        // OR
        #10 btnr = 1; sw = 16'h1001; btnd = 1; #10 btnd = 0; btnr = 0;
        if (led !== 16'h3317) $display("Test FAILED: OR!");

        // AND
        #10 sw = 16'hf0f0; btnd = 1; #10 btnd = 0;
        if (led !== 16'h3010) $display("Test FAILED: AND!");

        // XOR
        #10 btnl = 1; btnr = 1; btnc = 1; sw = 16'h1fa2; btnd = 1; #10 btnd = 0; btnl = 0; btnr = 0; btnc = 0;
        if (led !== 16'h2fb2) $display("Test FAILED: XOR!");

        // ADD
        #10 btnc = 1; sw = 16'h6aa2; btnd = 1; #10 btnd = 0; btnc = 0;
        if (led !== 16'h9a54) $display("Test FAILED: ADD!");

        // Logical Shift Left
        #10 btnl = 1; btnr = 1; sw = 16'h0004; btnd = 1; #10 btnd = 0; btnl = 0; btnr = 0;
        if (led !== 16'ha540) $display("Test FAILED: LSL!");

        // Arithmetic Shift Right
        #10 btnl = 1; btnc = 1; sw = 16'h0001; btnd = 1; #10 btnd = 0; btnl = 0; btnc = 0;
        if (led !== 16'hd2a0) $display("Test FAILED: ASR!");

        // Less Than
        #10 btnl = 1; sw = 16'h46ff; btnd = 1; #10 btnd = 0; btnl = 0;
        if (led !== 16'h0001) $display("Test FAILED: LT!");

        $display("Όλα τα τεστ ολοκληρώθηκαν!");
        $finish;
    end

endmodule
