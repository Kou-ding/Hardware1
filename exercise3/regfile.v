`timescale 1ns / 1ps

module regfile #(parameter DATAWIDTH = 32)(
    input clk,                      // Ρολόι
    input [4:0] readReg1,           // Διεύθυνση για θύρα ανάγνωσης 1
    input [4:0] readReg2,           // Διεύθυνση για θύρα ανάγνωσης 2
    input [4:0] writeReg,           // Διεύθυνση για θύρα εγγραφής
    input [DATAWIDTH-1:0] writeData,// Δεδομένα προς εγγραφή
    input write,                    // Σήμα εγγραφής
    output reg [DATAWIDTH-1:0] readData1, // Δεδομένα ανάγνωσης από θύρα 1
    output reg [DATAWIDTH-1:0] readData2  // Δεδομένα ανάγνωσης από θύρα 2
);

    // Αρχείο καταχωρητών (32 × DATAWIDTH-bit)
    reg [DATAWIDTH-1:0] registers [31:0];

    // Αρχικοποίηση καταχωρητών σε μηδενικά
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = {DATAWIDTH{1'b0}};
        end
    end

    // Ανάγνωση από τους καταχωρητές
    always @(*) begin
        if (write && (writeReg == readReg1)) begin
            // Προτεραιότητα στην εγγραφή
            readData1 = writeData;
        end else begin
            readData1 = registers[readReg1];
        end

        if (write && (writeReg == readReg2)) begin
            // Προτεραιότητα στην εγγραφή
            readData2 = writeData;
        end else begin
            readData2 = registers[readReg2];
        end
    end

    // Εγγραφή στον καταχωρητή
    always @(posedge clk) begin
        if (write && (writeReg != 5'b0)) begin
            registers[writeReg] <= writeData;
        end
    end

endmodule
