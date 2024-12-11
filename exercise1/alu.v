module alu (
    input [31:0] op1,        // 32-bit signed operand 1 (two's complement)
    input [31:0] op2,        // 32-bit signed operand 2 (two's complement)
    input [3:0] alu_op,      // 4-bit ALU operation selector
    output reg zero,         // 1-bit flag indicating result is zero
    output reg [31:0] result // 32-bit result of ALU operation
);

    // ALU operation codes (using parameters)
    parameter [3:0] ALUOP_AND   = 4'b0000; // Logical AND 
    parameter [3:0] ALUOP_OR    = 4'b0001; // Logical OR
    parameter [3:0] ALUOP_ADD   = 4'b0010; // Addition
    parameter [3:0] ALUOP_SUB   = 4'b0110; // Subtraction
    parameter [3:0] ALUOP_SLT   = 4'b0100; // Signed Less Than
    parameter [3:0] ALUOP_SRL   = 4'b1000; // Logical Shift Right
    parameter [3:0] ALUOP_SLL   = 4'b1001; // Logical Shift Left
    parameter [3:0] ALUOP_SRA   = 4'b1010; // Arithmetic Shift Right
    parameter [3:0] ALUOP_XOR   = 4'b0101; // Exclusive OR

    always @(*) begin
        case (alu_op)
            ALUOP_AND:   result = op1 & op2; // Logical AND
            ALUOP_OR:    result = op1 | op2; // Logical OR
            ALUOP_ADD:   result = op1 + op2; // Addition
            ALUOP_SUB:   result = op1 - op2; // Subtraction
            ALUOP_SLT:   result = ($signed(op1) < $signed(op2)) ? 1 : 0; // Signed Less Than
            ALUOP_SRL:   result = op1 >> op2[4:0]; // Logical Shift Right
            ALUOP_SLL:   result = op1 << op2[4:0]; // Logical Shift Left
            ALUOP_SRA:   result = $signed(op1) >>> op2[4:0]; // Arithmetic Shift Right
            ALUOP_XOR:   result = op1 ^ op2; // Exclusive OR
            default:     result = 32'b0; // Default case (should not occur)
        endcase

        // Set zero flag: result is zero if the result is 0
        if (result == 32'b0)
            zero = 1;
        else
            zero = 0;
    end

endmodule