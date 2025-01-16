`timescale 1ns / 1ps
`include "alu.v"
`include "calc_enc.v"

module calc(
    input clk,             // Clock: Ρολόι
    input btnc,            // Center Button: Κεντρικό πλήκτρο
    input btnl,            // Left Button: Αριστερό πλήκτρο
    input btnu,            // Up Button: Πλήκτρο μηδενισμού
    input btnr,            // Right Button: Δεξί πλήκτρο
    input btnd,            // Down Button: Πλήκτρο ενημέρωσης
    input [15:0] sw,       // Switch: Διακόπτες (εισαγωγή δεδομένων)
    output [15:0] led      // LED: Έξοδοι LED (τιμή συσσωρευτή)
);

    // Signals
    reg [15:0] accumulator;           // Accumulator: Συσσωρευτής
    wire [31:0] extended_accumulator; // Sign-extended Accumulator: Επέκταση προσήμου του συσσωρευτή
    wire [31:0] extended_sw;          // Sign-extended Switch: Επέκταση προσήμου των διακοπτών
    wire [31:0] result;               // Alu Result: Αποτέλεσμα της ALU
    reg [3:0] alu_op;                 // Alu Επιλογέας λειτουργίας ALU
    wire zero;                        // Σημαία μηδενικού της ALU

    // Sign extension of the accumulator and the switch
    assign extended_accumulator = {{16{accumulator[15]}}, accumulator};
    assign extended_sw = {{16{sw[15]}}, sw};

    // Instance unit of the alu module
    alu u_alu (
        .op1(extended_accumulator),
        .op2(extended_sw),
        .alu_op(alu_op),
        .zero(zero),
        .result(result)
    );

    // Instance unit of the calc_enc module for alu_op generation
    calc_enc u_calc_enc (
        .btnc(btnc),
        .btnl(btnl),
        .btnr(btnr),
        .alu_op(alu_op)
    );

    // Update the accumulator
    always @(posedge clk) begin
        if (btnu) begin
            accumulator <= 16'b0; // Reset
        end else if (btnd) begin
            accumulator <= result[31:0]; // Update
        end
    end

    // Reflect the accumulator to the LED
    assign led = accumulator;
endmodule