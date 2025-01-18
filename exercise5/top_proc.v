`timescale 1ns/1ps

`include "datapath.v"
`include "ram.v"
`include "rom.v"
`include "rom_bytes.data"

module top_proc #(parameter INITIAL_PC = 32'h00400000) (
    input clk,
    input rst,
    input [31:0] instr,
    input [31:0] dReadData,
    output [31:0] PC,
    output [31:0] dAddress,
    output [31:0] dWriteData,
    output MemRead,
    output MemWrite,
    output [31:0] WriteBackData
);

    // FSM States
    typedef enum reg [2:0] {
        STATE_IF,  // Instruction Fetch
        STATE_ID,  // Instruction Decode
        STATE_EX,  // Execute
        STATE_MEM, // Memory Access
        STATE_WB   // Write Back
    } state_t;

    reg [2:0] currentState, nextState;

    // Control signals
    reg PCSrc, ALUSrc, RegWrite, MemToReg, loadPC;
    reg [3:0] ALUCtrl;
    reg MemReadReg, MemWriteReg;

    // Internal signals
    wire Zero;

    // Instantiate datapath
    datapath #(INITIAL_PC) dp (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .ALUCtrl(ALUCtrl),
        .loadPC(loadPC),
        .dReadData(dReadData),
        .PC(PC),
        .Zero(Zero),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData)
    );

    // FSM: State transitions
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            currentState <= STATE_IF;
        end else begin
            currentState <= nextState;
        end
    end

    // FSM: Next state logic and control signals
    always @(*) begin
        // Default values for control signals
        PCSrc = 0;
        ALUSrc = 0;
        RegWrite = 0;
        MemToReg = 0;
        loadPC = 0;
        ALUCtrl = 4'b0000; // Default operation: AND
        MemReadReg = 0;
        MemWriteReg = 0;

        case (currentState)
            STATE_IF: begin
                loadPC = 1;
                nextState = STATE_ID;
            end

            STATE_ID: begin
                // Decode logic based on instruction opcode
                case (instr[6:0])
                    7'b0110011: nextState = STATE_EX; // R-type
                    7'b0010011: nextState = STATE_EX; // I-type
                    7'b0000011: nextState = STATE_MEM; // Load (LW)
                    7'b0100011: nextState = STATE_MEM; // Store (SW)
                    7'b1100011: nextState = STATE_EX; // Branch (BEQ)
                    default: nextState = STATE_IF; // Default: Fetch next instruction
                endcase
            end

            STATE_EX: begin
                case (instr[6:0])
                    7'b0110011: begin // R-type
                        ALUSrc = 0;
                        RegWrite = 1;
                        ALUCtrl = {instr[30], instr[14:12]};
                        nextState = STATE_WB;
                    end
                    7'b0010011: begin // I-type
                        ALUSrc = 1;
                        RegWrite = 1;
                        ALUCtrl = {instr[30], instr[14:12]};
                        nextState = STATE_WB;
                    end
                    7'b1100011: begin // BEQ
                        ALUSrc = 0;
                        ALUCtrl = 4'b0110; // Subtraction for BEQ
                        PCSrc = Zero;
                        nextState = STATE_IF;
                    end
                endcase
            end

            STATE_MEM: begin
                case (instr[6:0])
                    7'b0000011: begin // Load (LW)
                        MemReadReg = 1;
                        nextState = STATE_WB;
                    end
                    7'b0100011: begin // Store (SW)
                        MemWriteReg = 1;
                        nextState = STATE_IF;
                    end
                endcase
            end

            STATE_WB: begin
                case (instr[6:0])
                    7'b0000011: begin // Load (LW)
                        MemToReg = 1;
                        RegWrite = 1;
                    end
                endcase
                nextState = STATE_IF;
            end

            default: nextState = STATE_IF;
        endcase
    end

    // Output assignments
    assign MemRead = MemReadReg;
    assign MemWrite = MemWriteReg;

endmodule

// `include "alu.v"
// `include "regfile.v"

// module top_proc #(
//     parameter INITIAL_PC = 32'h00400000 // Initial PC value
// )(
//     input wire clk,
//     input wire rst,
//     input wire [31:0] instr,      // Instruction from instruction memory
//     input wire [31:0] dReadData, // Data read from data memory
//     output wire [31:0] PC,        // Program Counter
//     output wire [31:0] dAddress, // Data memory address
//     output wire [31:0] dWriteData, // Data memory write data
//     output reg MemRead,           // Data memory read enable
//     output reg MemWrite,          // Data memory write enable
//     output wire [31:0] WriteBackData // Data written back to registers (debugging)
// );

//     // Control signals
//     reg [3:0] ALUCtrl;
//     reg ALUSrc, PCSrc, RegWrite, MemToReg, loadPC;
//     wire Zero;

//     // Datapath instantiation
//     datapath #(.INITIAL_PC(INITIAL_PC)) dp (
//         .clk(clk),
//         .rst(rst),
//         .instr(instr),
//         .PCSrc(PCSrc),
//         .ALUSrc(ALUSrc),
//         .RegWrite(RegWrite),
//         .MemToReg(MemToReg),
//         .ALUCtrl(ALUCtrl),
//         .loadPC(loadPC),
//         .dReadData(dReadData),
//         .PC(PC),
//         .Zero(Zero),
//         .dAddress(dAddress),
//         .dWriteData(dWriteData),
//         .WriteBackData(WriteBackData)
//     );

//     // FSM state encoding
//     typedef enum reg [2:0] {IF, ID, EX, MEM, WB} state_t;
//     state_t state;

//     // FSM logic
//     always @(posedge clk or posedge rst) begin
//         if (rst)
//             state <= IF;
//         else begin
//             case (state)
//                 IF: state <= ID;
//                 ID: state <= EX;
//                 EX: state <= MEM;
//                 MEM: state <= WB;
//                 WB: state <= IF;
//             endcase
//         end
//     end

//     // Control signal generation
//     always @(*) begin
//         // Default values
//         ALUCtrl = 4'b0000;
//         ALUSrc = 0;
//         PCSrc = 0;
//         RegWrite = 0;
//         MemToReg = 0;
//         MemRead = 0;
//         MemWrite = 0;
//         loadPC = 0;

//         case (state)
//             IF: loadPC = 1; // Fetch next instruction
//             ID: ;           // Decode stage (control signals generated here if needed)
//             EX: begin       // Execute stage
//                 ALUSrc = (instr[6:0] == 7'b0000011 || instr[6:0] == 7'b0100011); // LW/SW
//                 // ALU control logic
//                 case (instr[6:0])
//                     7'b0110011: begin // R-type instructions
//                         case ({instr[31:25], instr[14:12]}) // funct7 + funct3
//                             10'b0000000000: ALUCtrl = 4'b0010; // ADD
//                             10'b0100000000: ALUCtrl = 4'b0110; // SUB
//                             10'b0000000111: ALUCtrl = 4'b0000; // AND
//                             10'b0000000110: ALUCtrl = 4'b0001; // OR
//                             10'b0000000100: ALUCtrl = 4'b0101; // XOR
//                             10'b0000000001: ALUCtrl = 4'b1001; // SLL
//                             10'b0000000101: ALUCtrl = 4'b1000; // SRL
//                             10'b0100000101: ALUCtrl = 4'b1010; // SRA
//                             10'b0000000010: ALUCtrl = 4'b0100; // SLT
//                             default: ALUCtrl = 4'b1111;        // Invalid
//                         endcase
//                     end
//                     7'b0010011: begin // I-type instructions
//                         case (instr[14:12]) // funct3
//                             3'b000: ALUCtrl = 4'b0010; // ADDI
//                             3'b111: ALUCtrl = 4'b0000; // ANDI
//                             3'b110: ALUCtrl = 4'b0001; // ORI
//                             3'b100: ALUCtrl = 4'b0101; // XORI
//                             3'b001: ALUCtrl = 4'b1001; // SLLI
//                             3'b101: begin
//                                 if (instr[31:25] == 7'b0000000)
//                                     ALUCtrl = 4'b1000; // SRLI
//                                 else if (instr[31:25] == 7'b0100000)
//                                     ALUCtrl = 4'b1010; // SRAI
//                                 else
//                                     ALUCtrl = 4'b1111; // Invalid
//                             end
//                             default: ALUCtrl = 4'b1111; // Invalid
//                         endcase
//                     end
//                     7'b0000011, // LW
//                     7'b0100011: ALUCtrl = 4'b0010; // ADD for LW/SW
//                     7'b1100011: begin // B-type instructions (e.g., BEQ)
//                         if (instr[14:12] == 3'b000)
//                             ALUCtrl = 4'b0110; // SUB for BEQ
//                         else
//                             ALUCtrl = 4'b1111; // Invalid
//                     end
//                     default: ALUCtrl = 4'b1111; // Invalid
//                 endcase
//             end
//             MEM: begin // Memory access stage
//                 if (instr[6:0] == 7'b0000011) MemRead = 1; // LW
//                 if (instr[6:0] == 7'b0100011) MemWrite = 1; // SW
//             end
//             WB: begin // Write-back stage
//                 RegWrite = 1;
//                 MemToReg = (instr[6:0] == 7'b0000011); // LW
//             end
//         endcase
//     end

// endmodule
