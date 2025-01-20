`timescale 1ns / 1ps

module regfile #(parameter DATAWIDTH = 32)(
    input clk,                      // Clock
    input [4:0] readReg1,           // Address for read port 1
    input [4:0] readReg2,           // Address for read port 2
    input [4:0] writeReg,           // Address for write port
    input [DATAWIDTH-1:0] writeData,// Data to write
    input write,                    // Write enable
    output reg [DATAWIDTH-1:0] readData1, // Read data at port 1
    output reg [DATAWIDTH-1:0] readData2  // Read data at port 2
);

    // Register file (32 × DATAWIDTH-bit)
    reg [DATAWIDTH-1:0] registers [31:0];

    // Register initialization
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = {DATAWIDTH{1'b0}};
        end
    end

    // Read data from the register file
    always @(*) begin
        // Read data from the registers (1)
        if (write && (writeReg == readReg1))begin // Write priority
            readData1 = writeData;
        end else begin
            readData1 = registers[readReg1];
        end
        // Read data from the register (2)
        if (write && (writeReg == readReg2))begin // Write priority
            readData2 = writeData;
        end else begin
            readData2 = registers[readReg2];
        end
    end

    // Write data to the register file
    always @(posedge clk) begin
        if (write && (writeReg != 5'b0)) begin
            registers[writeReg] <= writeData;
        end
    end

endmodule