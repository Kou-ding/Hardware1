module top_proc #(
    parameter INITIAL_PC = 32'h00400000
)(
    input clk,
    input rst,
    input [31:0] instr,
    input [31:0] dReadData,
    output reg [31:0] PC,
    output [31:0] dAddress,
    output [31:0] dWriteData,
    output reg MemRead,
    output reg MemWrite,
    output [31:0] WriteBackData
);

    // Εσωτερικά σήματα
    reg [2:0] state; // Καταστάσεις FSM
    reg [3:0] ALUCtrl;
    reg ALUSrc, MemtoReg, RegWrite, loadPC, PCSrc;

    // Wires για τη σύνδεση με το datapath
    wire Zero;
    wire [31:0] ALUResult, branch_offset;

    // Αρχικοποίηση PC
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            PC <= INITIAL_PC;
        end else if (loadPC) begin
            if (PCSrc)
                PC <= PC + branch_offset; // Διακλάδωση
            else
                PC <= PC + 4; // Κανονική εντολή
        end
    end

    // FSM: Μηχανή πέντε καταστάσεων
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 3'b000; // Κατάσταση IF
        end else begin
            case (state)
                3'b000: state <= 3'b001; // IF -> ID
                3'b001: state <= 3'b010; // ID -> EX
                3'b010: state <= 3'b011; // EX -> MEM
                3'b011: state <= 3'b100; // MEM -> WB
                3'b100: state <= 3'b000; // WB -> IF
                default: state <= 3'b000; // Default στην IF
            endcase
        end
    end

    // Σήματα ελέγχου για κάθε κατάσταση
    always @(*) begin
        // Προεπιλεγμένες τιμές
        MemRead = 0;
        MemWrite = 0;
        RegWrite = 0;
        MemtoReg = 0;
        ALUSrc = 0;
        loadPC = 0;
        PCSrc = 0;

        case (state)
            3'b000: begin // IF
                loadPC = 1;
            end
            3'b001: begin // ID
                // Δεν απαιτούνται σήματα
            end
            3'b010: begin // EX
                ALUSrc = (instr[6:0] == 7'b0000011 || instr[6:0] == 7'b0100011); // LW/SW
                ALUCtrl = ...; // Αποκωδικοποίηση opcode/funct3/funct7
            end
            3'b011: begin // MEM
                if (instr[6:0] == 7'b0000011) // LW
                    MemRead = 1;
                else if (instr[6:0] == 7'b0100011) // SW
                    MemWrite = 1;
            end
            3'b100: begin // WB
                if (instr[6:0] == 7'b0000011) // LW
                    MemtoReg = 1;
                RegWrite = 1;
            end
        endcase
    end

    // Σύνδεση με datapath
    datapath u_datapath (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .PC(PC),
        .dAddress(dAddress),
        .dReadData(dReadData),
        .dWriteData(dWriteData),
        .ALUCtrl(ALUCtrl),
        .ALUSrc(ALUSrc),
        .Zero(Zero),
        .branch_offset(branch_offset)
    );

endmodule
