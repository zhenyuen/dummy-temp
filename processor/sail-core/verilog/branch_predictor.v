/*
	Authored 2018-2019, Ryan Voo.

	All rights reserved.
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions
	are met:

	*	Redistributions of source code must retain the above
		copyright notice, this list of conditions and the following
		disclaimer.

	*	Redistributions in binary form must reproduce the above
		copyright notice, this list of conditions and the following
		disclaimer in the documentation and/or other materials
		provided with the distribution.

	*	Neither the name of the author nor the names of its
		contributors may be used to endorse or promote products
		derived from this software without specific prior written
		permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
	"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
	LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
	COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
	INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
	LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
	ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/

`include "../include/sail-core-defines.v"

/*
 *		Branch Predictor FSM
 */

module branch_predictor
	#(parameter kSIZE = `kSAIL_MICROARCHITECTURE_BRANCH_PREDICTOR_ADDRESSING_SIZE)(
		clk,
		actual_branch_decision,
		branch_decode_sig,
		branch_mem_sig,
		in_addr,
		offset,
		// branch_addr,
		prediction,
	);

	/*
	 *	inputs
	 */
	input		clk;
	input		actual_branch_decision;
	input		branch_decode_sig;
	input		branch_mem_sig;
	input [31:0]	in_addr;
	input [31:0]	offset;

	/*
	 *	outputs
	 */
	// output [31:0]	branch_addr;
	output		prediction;

	/*
	 *	internal state
	 */
	reg [kSIZE - 1:0] 	branch_history; // left shift register
	reg [1:0] 			bht[2 ** kSIZE - 1:0]; // branch prediction table
	// reg 				bias[2 ** kSIZE - 1:0] // bias table
	


	reg [kSIZE - 1:0]	addr_flag_1;
	reg [kSIZE - 1:0]	addr_flag_2;
	wire [kSIZE - 1:0]	addr_flag_curr;

	reg		branch_mem_sig_reg;

	/*
	 *	The `initial` statement below uses Yosys'bht support for nonzero
	 *	initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design and to thereby set the values.
	 */
	integer j;

	initial begin
		for (j=0; j<2 ** kSIZE; j=j+1) bht[j] = 2'b00;
		branch_mem_sig_reg = 1'b0;
		branch_history = kSIZE'b0;
	end

	always @(negedge clk) begin
		branch_mem_sig_reg <= branch_mem_sig;
	end

	/*
	 *	Using this microarchitecture, branches can't occur consecutively
	 *	therefore can use branch_mem_sig as every branch is followed by
	 *	a bubble, so a 0 to 1 transition
	 */
	always @(posedge clk) begin
		if (branch_mem_sig_reg) begin
			branch_history <= {branch_history[kSIZE-2:0], actual_branch_decision};

			bht[addr_flag_2][1] <= (bht[addr_flag_2][1]&bht[addr_flag_2][0]) | (bht[addr_flag_2][0]&actual_branch_decision) | (bht[addr_flag_2][1]&actual_branch_decision);
			bht[addr_flag_2][0] <= (bht[addr_flag_2][1]&(!bht[0])) | ((!bht[addr_flag_2][0])&actual_branch_decision) | (bht[addr_flag_2][1]&actual_branch_decision);

		end
		addr_flag_2 <= addr_flag_1;
		addr_flag_1 <= addr_flag_curr;
	end

	// assign branch_addr = in_addr + offset;
	assign addr_flag_curr = in_addr[kSIZE + 1:2] ^ branch_history;
	assign prediction = bht[addr_flag_curr][1] & branch_decode_sig;
endmodule
