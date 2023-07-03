module MistakeRegister(clk, mistake, branch_mem_sig, out);
    input               clk;
    input               mistake;
    input		        branch_mem_sig;
	output      		out;
    reg                 state; // To store state that mistake occured, so next fetch instruction is PC+4
    reg		            branch_mem_sig_reg;


    initial begin
		state = 1'b0;
	end

    always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

    always @(posedge clk) begin
        if (branch_mem_sig_reg)
            state = mistake;
	end

    assign out = state;
endmodule