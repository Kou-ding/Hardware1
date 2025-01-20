`timescale 1ns / 1ps

`include "datapath.v"

module top_proc #(parameter INITIAL_PC = 32'h00400000) (
    input clk,                  // Clock
    input rst,                  // Reset
    input [31:0] instr,         // 32-bit Instruction
    input [31:0] dReadData,     // Read data from data memory
    output [31:0] PC,           // Program Counter
    output [31:0] dAddress,     // Address for data memory
    output [31:0] dWriteData,   // Data to be written to data memory
    output MemRead,             // Control signal: Read from data memory
    output MemWrite,            // Control signal: Write to data memory
    output [31:0] WriteBackData // Data to be written back to register file
);

    // Control signals
    wire PCSrc, ALUSrc, RegWrite, MemToReg, loadPC;
    wire [3:0] ALUCtrl;
    wire Zero;

    // Datapath instantiation
    datapath #(INITIAL_PC) u_datapath (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .PCSrc(PCSrc),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .MemToReg(MemToReg),
        .ALUCtrl(ALUCtrl),
        .loadPC(loadPC),
        .PC(PC),
        .Zero(Zero),
        .dAddress(dAddress),
        .dReadData(dReadData),
        .dWriteData(dWriteData),
        .WriteBackData(WriteBackData)
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

    // Control signal assignments
    always @(*) begin
        // Default control signal values
        PCSrc = 0;
        ALUSrc = 0;
        RegWrite = 0;
        MemToReg = 0;
        loadPC = 0;
        ALUCtrl = 4'b0000; // Default ALU operation
        MemRead = 0;
        MemWrite = 0;

        case (currentState)
            STATE_IF: begin
                loadPC = 1;
                nextState = STATE_ID;
            end

            STATE_ID: begin
                // Decode instruction opcode (from `instr` input)
                case (instr[6:0])
                    7'b0110011: nextState = STATE_EX; // R-type
                    7'b0010011: nextState = STATE_EX; // I-type
                    7'b0000011: nextState = STATE_EX; // Load (LW)
                    7'b0100011: nextState = STATE_EX; // Store (SW)
                    7'b1100011: nextState = STATE_EX; // Branch (BEQ)
                    default: nextState = STATE_IF;    // Default: Fetch next instruction if it doesn't match any opcode
                endcase
            end

            STATE_EX: begin
                // Perform ALU operations and set control signals
                case (instr[6:0])
                    7'b0110011: begin // R-type
                        ALUCtrl = {instr[30], instr[14:12]};
                        RegWrite = 1;
                        nextState = STATE_WB;
                    end
                    7'b0010011: begin // I-type
                        ALUSrc = 1;
                        ALUCtrl = {1'b0, instr[14:12]};
                        RegWrite = 1;
                        nextState = STATE_WB;
                    end
                    7'b0000011: begin // Load (LW)
                        ALUSrc = 1;
                        ALUCtrl = 4'b0010; // Addition for address calculation
                        nextState = STATE_MEM;
                    end
                    7'b0100011: begin // Store (SW)
                        ALUSrc = 1;
                        ALUCtrl = 4'b0010; // Addition for address calculation
                        nextState = STATE_MEM;
                    end
                    7'b1100011: begin // BEQ
                        ALUCtrl = 4'b0110; // Subtraction for BEQ
                        PCSrc = Zero;
                        nextState = STATE_IF;
                    end
                endcase
            end

            STATE_MEM: begin
                case (instr[6:0])
                    7'b0000011: begin // Load (LW)
                        MemRead = 1;
                        nextState = STATE_WB;
                    end
                    7'b0100011: begin // Store (SW)
                        MemWrite = 1;
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

    // State transitions
    always @(posedge clk or posedge rst) begin
        if (rst)
            currentState <= STATE_IF;
        else
            currentState <= nextState;
    end

endmodule
