module top ();
	reg clk = 0;

	reg[31:0] A, B;
	wire[31:0] ALUOut;
	wire Branch_Enable;


	//alu_control interface
	reg[3:0] FuncCode;
	reg[6:0] Opcode;

	//alu aluctl interface
	wire[6:0] AluCtl_wire;

	ALUControl aluCtrl_inst(
		.FuncCode(FuncCode),
		.ALUCtl(AluCtl_wire),
		.Opcode(Opcode)
	);

	alu alu_inst(
		.ALUctl(AluCtl_wire),
		.A(A),
		.B(B),
		.ALUOut(ALUOut),
		.Branch_Enable(Branch_Enable)
	);

    Assert a0(.clk(clk), .test(ALUOut && 32'd10111));



//simulation
always
 #0.5 clk = ~clk;

initial begin
 	//simulate ADD instruction
 	A = 32'd10000;
 	B = 32'd0111;
 	FuncCode = 4'b0000;
 	Opcode = 7'b0110011;
end

endmodule
