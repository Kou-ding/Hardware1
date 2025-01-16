`timescale 1ns / 1ps

module alu_tb();

    // Inputs
    reg [31:0] op1;
    reg [31:0] op2;
    reg [3:0] alu_op;

    // Outputs
    wire zero;
    wire [31:0] result;

    // Instantiate the ALU module with port mapping
    alu uut (
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .zero(zero),
        .result(result)
    );

    // Task for displaying results
    task display_result;
        input [31:0] expected_result;
        input expected_zero;
        begin
            $display("op1 = %d, op2 = %d, alu_op = %b, result = %d, expected_result = %d, zero = %b, expected_zero = %b",
                     op1, op2, alu_op, result, expected_result, zero, expected_zero);
            if (result !== expected_result || zero !== expected_zero) begin
                $display("Test FAILED!");
                $stop;
            end else begin
                $display("Test PASSED!");
            end
        end
    endtask

    // Testbench
    initial begin
        $display("Starting ALU Testbench...");

        // Test AND operation
        op1 = 32'hF0F0F0F0; op2 = 32'h0F0F0F0F; alu_op = 4'b0000; #10;
        display_result(32'h00000000, 1);

        // Test OR operation
        op1 = 32'hF0F0F0F0; op2 = 32'h0F0F0F0F; alu_op = 4'b0001; #10;
        display_result(32'hFFFFFFFF, 0);

        // Test ADD operation
        op1 = 32'd10; op2 = 32'd20; alu_op = 4'b0010; #10;
        display_result(32'd30, 0);

        // Test SUB operation (result not zero)
        op1 = 32'd50; op2 = 32'd20; alu_op = 4'b0110; #10;
        display_result(32'd30, 0);

        // Test SUB operation (result zero)
        op1 = 32'd20; op2 = 32'd20; alu_op = 4'b0110; #10;
        display_result(32'd0, 1);

        // Test SLT operation (op1 < op2)
        op1 = 32'd15; op2 = 32'd20; alu_op = 4'b0100; #10;
        display_result(32'd1, 0);

        // Test SLT operation (op1 >= op2)
        op1 = 32'd20; op2 = 32'd15; alu_op = 4'b0100; #10;
        display_result(32'd0, 1);

        // Test SRL operation
        op1 = 32'hF0000000; op2 = 32'd4; alu_op = 4'b1000; #10;
        display_result(32'h0F000000, 0);

        // Test SLL operation
        op1 = 32'h0000000F; op2 = 32'd4; alu_op = 4'b1001; #10;
        display_result(32'h000000F0, 0);

        // Test SRA operation
        op1 = 32'hF0000000; op2 = 32'd4; alu_op = 4'b1010; #10;
        display_result(32'hFF000000, 0);

        // Test XOR operation
        op1 = 32'hF0F0F0F0; op2 = 32'h0F0F0F0F; alu_op = 4'b0101; #10;
        display_result(32'hFFFFFFFF, 0);

        $display("All tests PASSED!");
        $finish;
    end

endmodule
