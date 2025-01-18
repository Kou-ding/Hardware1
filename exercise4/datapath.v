`include "alu.v"
`include "regfile.v"

module datapath #(parameter INITIAL_PC = 32'h00400000) (
    input clk,                  // Clock
    input rst,                  // Reset
    input [31:0] instr,         // Instruction data from instruction memory
    input PCSrc,                // Program Counter (PC) source
    input ALUSrc,               // Second ALU operand source
    input RegWrite,             // Write data in register file
    input MemToReg,             // Input multiplexer for register file
    input [3:0] ALUCtrl,        // ALU control signals (show which operation to perform)
    input loadPC,               // Update PC
    input [31:0] dReadData,     // Data to be read from instruction memory
    output reg [31:0] PC,       // Program Counter
    output Zero,                // ALU zero flag
    output [31:0] dAddress,     // Address for data memory
    output [31:0] dWriteData,   // Data to be written to data memory
    output [31:0] WriteBackData // Data to be written back to register file
);

    // Internal signals
    reg [31:0] nextPC;
    wire [31:0] branchTarget, immediateValue, regData1, regData2;
    wire [31:0] aluOp2, aluResult;
    wire zeroFlag;
    reg [31:0] writeData;

    // Immediate generation (I-type, S-type, and B-type)
    wire [31:0] immI = {{20{instr[31]}}, instr[31:20]};
    wire [31:0] immS = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    wire [31:0] immB = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};

    // Register file instantiation
    wire [4:0] rs1 = instr[19:15];
    wire [4:0] rs2 = instr[24:20];
    wire [4:0] rd = instr[11:7];

    regfile #(32) u_regfile (
        .clk(clk),
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(rd),
        .writeData(writeData),
        .write(RegWrite),
        .readData1(regData1),
        .readData2(regData2)
    );

    // ALU
    assign aluOp2 = (ALUSrc) ? immI : regData2;
    alu u_alu (
        .op1(regData1),
        .op2(aluOp2),
        .alu_op(ALUCtrl),
        .zero(zeroFlag),
        .result(aluResult)
    );

    // Branch target calculation
    assign branchTarget = PC + immB;

    // Data memory interface
    assign dAddress = aluResult;
    assign dWriteData = regData2;

    // Write-back multiplexer
    assign WriteBackData = (MemToReg) ? dReadData : aluResult;

    // Program Counter logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= INITIAL_PC;
        end else if (loadPC) begin
            PC <= (PCSrc) ? branchTarget : PC + 4;
        end
    end

    // Zero flag output
    assign Zero = zeroFlag;
endmodule


// module datapath #(
//     parameter INITIAL_PC = 32'h00400000 // Initial value of Program Counter (PC)
// )(
//     input wire clk,                 // Clock
//     input wire rst,                 // Reset
//     input wire [31:0] instr,        // Instruction data from instruction memory
//     input wire PCSrc,               // Program Counter (PC) source
//     input wire ALUSrc,              // Second ALU operand source
//     input wire RegWrite,            // Write data in register file
//     input wire MemToReg,            // Input multiplexer for register file
//     input wire [3:0] ALUCtrl,       // ALU control signals (show which operation to perform)
//     input wire loadPC,              // Update PC
//     input wire [31:0] dReadData,    // Data to be read from instruction memory
//     output wire [31:0] PC,          // Program Counter
//     output wire Zero,               // ALU zero flag
//     output wire [31:0] dAddress,    // Address for data memory
//     output wire [31:0] dWriteData,  // Data to be written to data memory
//     output wire [31:0] WriteBackData // Data to be written back to register file
// );
//     // Include the alu module
//     alu u_alu (
//         .op1(op1),
//         .op2(op2),
//         .alu_op(ALUCtrl),
//         .result(result),
//         .zero(Zero)
//     );

//     // Include the regfile module
//     regfile u_regfile (
//         .clk(clk),
//         .readReg1(readReg1),
//         .readReg2(readReg2),
//         .writeReg(writeReg),
//         .writeData(writeData),
//         .write(RegWrite),
//         .readData1(readData1),
//         .readData2(readData2)
//     );

//     // Εσωτερικά σήματα
//     reg [31:0] pc_reg, pc_next;        // Καταχωρητής και επόμενη τιμή του PC
//     wire [31:0] branch_offset;         // Offset διακλάδωσης
//     wire [31:0] alu_op2;               // Δεύτερη είσοδος της ALU
//     wire [31:0] alu_result;            // Αποτέλεσμα ALU
//     wire [31:0] imm_I, imm_S, imm_B;  // Άμεσες τιμές για τύπους I, S, B
//     wire [4:0] rs1, rs2, rd;          // Πεδία εντολής (καταχωρητές)
//     wire [31:0] readData1, readData2; // Είσοδοι από το αρχείο καταχωρητών
//     wire [31:0] reg_write_data;       // Δεδομένα εγγραφής στους καταχωρητές

//     // ---------------------------------------------
//     // Program Counter (PC)
//     // ---------------------------------------------
//     always @(posedge clk or posedge rst) begin
//         if (rst) 
//             pc_reg <= INITIAL_PC; // Reset PC
//         else if (loadPC) 
//             pc_reg <= pc_next;    // Ενημέρωση PC
//     end

//     assign PC = pc_reg;

//     // Υπολογισμός επόμενης τιμής PC
//     assign pc_next = PCSrc ? (pc_reg + branch_offset) : (pc_reg + 4);

//     // ---------------------------------------------
//     // Immediate Generation
//     // ---------------------------------------------
//     assign imm_I = {{20{instr[31]}}, instr[31:20]}; // Άμεση τιμή τύπου I
//     assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // Άμεση τιμή τύπου S
//     assign imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // Άμεση τιμή τύπου B

//     // ---------------------------------------------
//     // Register File (Αρχείο Καταχωρητών)
//     // ---------------------------------------------
//     assign rs1 = instr[19:15]; // Πρώτος τελεστής
//     assign rs2 = instr[24:20]; // Δεύτερος τελεστής
//     assign rd = instr[11:7];   // Καταχωρητής εγγραφής

    

//     // ---------------------------------------------
//     // ALU
//     // ---------------------------------------------
//     assign alu_op2 = ALUSrc ? imm_I : readData2; // Επιλογή δεύτερου τελεστή

//     assign dAddress = alu_result; // Διεύθυνση μνήμης
//     assign dWriteData = readData2; // Δεδομένα προς εγγραφή στη μνήμη

//     // ---------------------------------------------
//     // Write Back
//     // ---------------------------------------------
//     assign reg_write_data = MemToReg ? dReadData : alu_result;
//     assign WriteBackData = reg_write_data;

//     // ---------------------------------------------
//     // Branch Offset
//     // ---------------------------------------------
//     assign branch_offset = imm_B;

// endmodule
