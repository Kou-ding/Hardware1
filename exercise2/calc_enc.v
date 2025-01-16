module calc_enc(
    input btnc,
    input btnl,
    input btnr,
    output [3:0] alu_op
);
    // Logic of alu_op based on the schematics
    wire n_btnc, n_btnl, n_btnr;
    wire and1, and2, and3, and4, and5, and6, and7, and8, and9, and10, and11;

    // NOT gates
    not (n_btnc, btnc);
    not (n_btnl, btnl);
    not (n_btnr, btnr);

    // Logic for alu_op[0]
    and (and1, btnr, n_btnc);
    and (and2, btnr, btnl);
    or  (alu_op[0], and1, and2);

    // Logic for alu_op[1]
    and (and3, n_btnl, btnc);
    and (and4, btnc, n_btnr);
    or  (alu_op[1], and3, and4);

    // Logic for alu_op[2]
    and (and5, btnc, btnr);
    and (and6, btnl, n_btnc);
    and (and7, and6, n_btnr);
    or  (alu_op[2], and5, and7);

    // Logic for alu_op[3]
    and (and8, btnl, n_btnc);
    and (and9, and8, btnr);
    and (and10, btnc, btnl);
    and (and11, and10, n_btnr);
    or  (alu_op[3], and9, and11);

    // Behavioural logic
    // assign alu_op[0] = (btnr & ~btnc) | (btnr & btnl);
    // assign alu_op[1] = (~btnl & btnc) | (btnc & ~btnr);
    // assign alu_op[2] = (btnc & btnr) | ((btnl & ~btnc) & ~btnr);
    // assign alu_op[3] = ((btnl & ~btnc) & btnr) | ((btnc & btnl) & ~btnr);
endmodule
