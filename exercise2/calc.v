`timescale 1ns / 1ps

module calc(
    input clk,             // Ρολόι
    input btnc,            // Κεντρικό πλήκτρο
    input btnl,            // Αριστερό πλήκτρο
    input btnu,            // Πλήκτρο μηδενισμού
    input btnr,            // Δεξί πλήκτρο
    input btnd,            // Πλήκτρο ενημέρωσης
    input [15:0] sw,       // Διακόπτες (εισαγωγή δεδομένων)
    output reg [15:0] led  // Έξοδοι LED (τιμή συσσωρευτή)
);

    // Σήματα
    reg [15:0] accumulator;           // Συσσωρευτής
    wire [31:0] extended_acc;         // Επέκταση προσήμου του συσσωρευτή
    wire [31:0] extended_sw;          // Επέκταση προσήμου των διακοπτών
    wire [31:0] alu_result;           // Αποτέλεσμα της ALU
    reg [3:0] alu_op;                 // Επιλογέας λειτουργίας ALU
    wire zero_flag;                   // Σημαία μηδενικού της ALU

    // Επέκταση προσήμου
    assign extended_acc = {{16{accumulator[15]}}, accumulator};
    assign extended_sw = {{16{sw[15]}}, sw};

    // ALU instance
    alu uut (
        .op1(extended_acc),
        .op2(extended_sw),
        .alu_op(alu_op),
        .zero(zero_flag),
        .result(alu_result)
    );

    // Καταχωρητής συσσωρευτή
    always @(posedge clk) begin
        if (btnu) begin
            accumulator <= 16'b0; // Μηδενισμός
        end else if (btnd) begin
            accumulator <= alu_result[15:0]; // Ενημέρωση με το αποτέλεσμα της ALU
        end
    end

    // Σύνδεση συσσωρευτή με LED
    always @(*) begin
        led = accumulator;
    end

    // Λογική για alu_op
    always @(*) begin
        alu_op[0] = btnr | (btnl & btnc);
        alu_op[1] = btnr | (~btnl & btnc);
        alu_op[2] = btnl & ~btnc;
        alu_op[3] = btnr & btnl & btnc;
    end

endmodule
