module datapath #(
    parameter INITIAL_PC = 32'h00400000 // Αρχική τιμή του PC
)(
    input wire clk,                 // Ρολόι
    input wire rst,                 // Reset
    input wire [31:0] instr,        // Εντολή από τη μνήμη
    input wire PCSrc,               // Επιλογή διακλάδωσης
    input wire ALUSrc,              // Επιλογή εισόδου για τον δεύτερο τελεστή της ALU
    input wire RegWrite,            // Εγγραφή στο αρχείο καταχωρητών
    input wire MemToReg,            // Επιλογή τιμής για εγγραφή στους καταχωρητές
    input wire [3:0] ALUCtrl,       // Σήμα ελέγχου της ALU
    input wire loadPC,              // Φόρτωση νέας τιμής στο PC
    input wire [31:0] dReadData,    // Δεδομένα από τη μνήμη δεδομένων
    output wire [31:0] PC,          // Τρέχουσα διεύθυνση PC
    output wire Zero,               // Έξοδος μηδενισμού της ALU
    output wire [31:0] dAddress,    // Διεύθυνση για μνήμη δεδομένων
    output wire [31:0] dWriteData,  // Δεδομένα προς εγγραφή στη μνήμη
    output wire [31:0] WriteBackData // Δεδομένα προς εγγραφή στους καταχωρητές
);

    // Εσωτερικά σήματα
    reg [31:0] pc_reg, pc_next;        // Καταχωρητής και επόμενη τιμή του PC
    wire [31:0] branch_offset;         // Offset διακλάδωσης
    wire [31:0] alu_op2;               // Δεύτερη είσοδος της ALU
    wire [31:0] alu_result;            // Αποτέλεσμα ALU
    wire [31:0] imm_I, imm_S, imm_B;  // Άμεσες τιμές για τύπους I, S, B
    wire [4:0] rs1, rs2, rd;          // Πεδία εντολής (καταχωρητές)
    wire [31:0] readData1, readData2; // Είσοδοι από το αρχείο καταχωρητών
    wire [31:0] reg_write_data;       // Δεδομένα εγγραφής στους καταχωρητές

    // ---------------------------------------------
    // Program Counter (PC)
    // ---------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) 
            pc_reg <= INITIAL_PC; // Reset PC
        else if (loadPC) 
            pc_reg <= pc_next;    // Ενημέρωση PC
    end

    assign PC = pc_reg;

    // Υπολογισμός επόμενης τιμής PC
    assign pc_next = PCSrc ? (pc_reg + branch_offset) : (pc_reg + 4);

    // ---------------------------------------------
    // Immediate Generation
    // ---------------------------------------------
    assign imm_I = {{20{instr[31]}}, instr[31:20]}; // Άμεση τιμή τύπου I
    assign imm_S = {{20{instr[31]}}, instr[31:25], instr[11:7]}; // Άμεση τιμή τύπου S
    assign imm_B = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; // Άμεση τιμή τύπου B

    // ---------------------------------------------
    // Register File (Αρχείο Καταχωρητών)
    // ---------------------------------------------
    assign rs1 = instr[19:15]; // Πρώτος τελεστής
    assign rs2 = instr[24:20]; // Δεύτερος τελεστής
    assign rd = instr[11:7];   // Καταχωρητής εγγραφής

    regfile register_file (
        .clk(clk),
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(rd),
        .writeData(reg_write_data),
        .write(RegWrite),
        .readData1(readData1),
        .readData2(readData2)
    );

    // ---------------------------------------------
    // ALU
    // ---------------------------------------------
    assign alu_op2 = ALUSrc ? imm_I : readData2; // Επιλογή δεύτερου τελεστή

    ALU alu (
        .op1(readData1),
        .op2(alu_op2),
        .alu_op(ALUCtrl),
        .result(alu_result),
        .zero(Zero)
    );

    assign dAddress = alu_result; // Διεύθυνση μνήμης
    assign dWriteData = readData2; // Δεδομένα προς εγγραφή στη μνήμη

    // ---------------------------------------------
    // Write Back
    // ---------------------------------------------
    assign reg_write_data = MemToReg ? dReadData : alu_result;
    assign WriteBackData = reg_write_data;

    // ---------------------------------------------
    // Branch Offset
    // ---------------------------------------------
    assign branch_offset = imm_B;

endmodule
