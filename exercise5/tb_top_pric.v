module top_proc_tb;

    reg clk, rst;
    reg [31:0] instr, dReadData;
    wire [31:0] PC, dAddress, dWriteData, WriteBackData;
    wire MemRead, MemWrite;

    top_proc uut (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .dReadData(dReadData),
        .PC(PC),
        .dAddress(dAddress),
        .dWriteData(dWriteData),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .WriteBackData(WriteBackData)
    );

    // Ρολόι
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;

        // Εντολές ελέγχου
        instr = 32'b...; // ADD
        #10;
        instr = 32'b...; // LW
        #10;
        instr = 32'b...; // SW
        #10;
        instr = 32'b...; // BEQ
        #10;

        $finish;
    end
endmodule
