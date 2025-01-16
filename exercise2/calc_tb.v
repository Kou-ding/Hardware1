`timescale 1ns/1ps

module calc_tb;
    reg clk;
    reg btnc, btnl, btnu, btnr, btnd;
    reg [15:0] sw;
    wire [15:0] led;

    // Instantiate the calculator
    calc u_calc (
        .clk(clk),
        .btnc(btnc),
        .btnl(btnl),
        .btnu(btnu),
        .btnr(btnr),
        .btnd(btnd),
        .sw(sw),
        .led(led)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period (100 MHz)

    initial begin
        // Display waveforms
        $dumpfile("dump.vcd"); $dumpvars;

        // Initialize inputs
        clk = 0;
        btnc = 0; btnl = 0; btnu = 0; btnr = 0; btnd = 0;
        sw = 16'b0;

        // Simulation sequence
        $display("Starting testbench...");
        
        // Reset the calculator
        btnu = 1;
        #10; btnu = 0;
        if (led !== 16'h0000) $display("Error: Reset test failed!");
        else $display("Reset test passed!");

        // Test addition
        sw = 16'h354A; btnc = 1; btnd = 1;
        #10; btnd = 0; btnc = 0;
        if (led !== 16'h354A) $display("Error: Addition test failed!");
        else $display("Addition test passed!");

        // Test subtraction
        sw = 16'h1234; btnc = 1; btnr = 1; btnd = 1;
        #10; btnd = 0; btnc = 0; btnr = 0;
        if (led !== 16'h2316) $display("Error: Subtraction test failed!");
        else $display("Subtraction test passed!");

        // Test OR
        sw = 16'h1001; btnr = 1; btnd = 1;
        #10; btnd = 0; btnr = 0;
        if (led !== 16'h3317) $display("Error: OR test failed!");
        else $display("OR test passed!");

        // Test AND
        sw = 16'hF0F0; btnd = 0; btnd = 1;
        #10; btnd = 0;
        if (led !== 16'h3010) $display("Error: AND test failed!");
        else $display("AND test passed!");

        // Test XOR
        sw = 16'h1FA2; btnl = 1; btnc = 1; btnr = 1; btnd = 1;
        #10; btnd = 0; btnl = 0; btnc = 0; btnr = 0;
        if (led !== 16'h2FB2) $display("Error: XOR test failed!");
        else $display("XOR test passed!");

        // Test addition
        sw = 16'h6AA2; btnc = 1; btnd = 1;
        #10; btnd = 0; btnc = 0;
        if (led !== 16'h9A54) $display("Error: Addition test failed!");
        else $display("Addition test passed!");

        // Test Logical Shift Left
        sw = 16'h0004; btnl = 1; btnr = 1; btnd = 1;
        #10; btnd = 0; btnl = 0; btnr = 0;
        if (led !== 16'hA540) $display("Error: Logical Shift Left test failed!");
        else $display("Logical Shift Left test passed!");

        // Test Arithmetic Shift Right
        sw = 16'h0001; btnl = 1; btnc = 1; btnd = 1;
        #10; btnd = 0; btnl = 0; btnc = 0;
        if (led !== 16'hD2A0) $display("Error: Arithmetic Shift Right test failed!");
        else $display("Arithmetic Shift Right test passed!");

        // Test Less Than
        sw = 16'h46FF; btnl = 1; btnd = 1;
        #10; btnd = 0; btnl = 0;
        if (led !== 16'h0001) $display("Error: Less Than test failed!");
        else $display("Less Than test passed!");

        $display("Testbench completed!");
        $finish;
    end
endmodule