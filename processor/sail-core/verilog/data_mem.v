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



//Data cache

module data_mem (clk, hfclk, addr, write_data, memwrite, memread, sign_mask, read_data, led, clk_stall);
	input			clk;
	input			hfclk;
	input [31:0]		addr;
	input [31:0]		write_data;
	input			memwrite;
	input			memread;
	input [3:0]		sign_mask;
	output reg [31:0]	read_data;
	output [7:0]		led;
	output reg		clk_stall;	//Sets the clock high

	/*
	 *	led register
	 */
	reg [31:0]		led_reg;

	/*
	 *	Current state
	 */
	integer			state = 0;

	/*
	 *	Possible states
	 */
	parameter		IDLE = 0;
	parameter		LOAD_BUFFER=8;
	parameter		READ_BUFFER = 1;
	parameter		READ = 2;
	parameter		READ_COMPLETE = 4;
	parameter		WRITE = 3;
	parameter		WRITE_COMPLETE = 5;
	// parameter		POST_IDLE_1 = 4;
	// parameter		POST_IDLE_2 = 5;
	// parameter 		POST_READ_BUFFER_1 = 6;
	// parameter 		POST_READ_BUFFER_2 = 7;


	/*
	 *	Line buffer
	 */
	reg [31:0]		word_buf;

	/*
	 *	Read buffer
	 */
	wire [31:0]		read_buf;

	/*
	 *	Buffer to identify read or write operation
	 */
	reg			memread_buf;
	reg			memwrite_buf;

	/*
	 *	Buffers to store write data
	 */
	reg [31:0]		write_data_buffer;

	/*
	 *	Buffer to store address
	 */
	reg [31:0]		addr_buf;

	/*
	 *	Sign_mask buffer
	 */
	reg [3:0]		sign_mask_buf;

	/*
	 *	Block memory registers
	 *
	 *	(Bad practice: The constant for the size should be a `define).
	 */
	reg [31:0]		data_block[0:1023];

	/*
	 *	wire assignments
	 */
	wire [9:0]		addr_buf_block_addr;
	wire [1:0]		addr_buf_byte_offset;

	wire [31:0]		replacement_word;

	assign			addr_buf_block_addr	= addr_buf[11:2];
	assign			addr_buf_byte_offset	= addr_buf[1:0];

	/*
	 *	Regs for multiplexer output
	 */
	wire [7:0]		buf0;
	wire [7:0]		buf1;
	wire [7:0]		buf2;
	wire [7:0]		buf3;

	assign 			buf0	= word_buf[7:0];
	assign 			buf1	= word_buf[15:8];
	assign 			buf2	= word_buf[23:16];
	assign 			buf3	= word_buf[31:24];

	/*
	 *	Byte select decoder
	 */
	wire bdec_sig0;
	wire bdec_sig1;
	wire bdec_sig2;
	wire bdec_sig3;

	assign bdec_sig0 = (~addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
	assign bdec_sig1 = (~addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);
	assign bdec_sig2 = (addr_buf_byte_offset[1]) & (~addr_buf_byte_offset[0]);
	assign bdec_sig3 = (addr_buf_byte_offset[1]) & (addr_buf_byte_offset[0]);


	/*
	 *	Constructing the word to be replaced for write byte
	 */
	wire[7:0] byte_r0;
	wire[7:0] byte_r1;
	wire[7:0] byte_r2;
	wire[7:0] byte_r3;

	assign byte_r0 = (bdec_sig0==1'b1) ? write_data_buffer[7:0] : buf0;
	assign byte_r1 = (bdec_sig1==1'b1) ? write_data_buffer[7:0] : buf1;
	assign byte_r2 = (bdec_sig2==1'b1) ? write_data_buffer[7:0] : buf2;
	assign byte_r3 = (bdec_sig3==1'b1) ? write_data_buffer[7:0] : buf3;

	/*
	 *	For write halfword
	 */
	wire[15:0] halfword_r0;
	wire[15:0] halfword_r1;

	assign halfword_r0 = (addr_buf_byte_offset[1]==1'b1) ? {buf1, buf0} : write_data_buffer[15:0];
	assign halfword_r1 = (addr_buf_byte_offset[1]==1'b1) ? write_data_buffer[15:0] : {buf3, buf2};

	/* a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0] */
	wire write_select0;
	wire write_select1;

	wire[31:0] write_out1;
	wire[31:0] write_out2;

	assign write_select0 = ~sign_mask_buf[2] & sign_mask_buf[1];
	assign write_select1 = sign_mask_buf[2];

	assign write_out1 = (write_select0) ? {halfword_r1, halfword_r0} : {byte_r3, byte_r2, byte_r1, byte_r0};
	assign write_out2 = (write_select0) ? 32'b0 : write_data_buffer;

	assign replacement_word = (write_select1) ? write_out2 : write_out1;
	/*
	 *	Combinational logic for generating 32-bit read data
	 */

	wire select0;
	wire select1;
	wire select2;

	wire[31:0] out1;
	wire[31:0] out2;
	wire[31:0] out3;
	wire[31:0] out4;
	wire[31:0] out5;
	wire[31:0] out6;
	/* a is sign_mask_buf[2], b is sign_mask_buf[1], c is sign_mask_buf[0]
	 * d is addr_buf_byte_offset[1], e is addr_buf_byte_offset[0]
	 */

	assign select0 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & ~addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & addr_buf_byte_offset[1] & addr_buf_byte_offset[0]) | (~sign_mask_buf[2] & sign_mask_buf[1] & addr_buf_byte_offset[1]); //~a~b~de + ~ade + ~abd
	assign select1 = (~sign_mask_buf[2] & ~sign_mask_buf[1] & addr_buf_byte_offset[1]) | (sign_mask_buf[2] & sign_mask_buf[1]); // ~a~bd + ab
	assign select2 = sign_mask_buf[1]; //b

	assign out1 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf1[7]}}, buf1} : {24'b0, buf1}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf0[7]}}, buf0} : {24'b0, buf0});
	assign out2 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{24{buf3[7]}}, buf3} : {24'b0, buf3}) : ((sign_mask_buf[3]==1'b1) ? {{24{buf2[7]}}, buf2} : {24'b0, buf2});
	assign out3 = (select0) ? ((sign_mask_buf[3]==1'b1) ? {{16{buf3[7]}}, buf3, buf2} : {16'b0, buf3, buf2}) : ((sign_mask_buf[3]==1'b1) ? {{16{buf1[7]}}, buf1, buf0} : {16'b0, buf1, buf0});
	assign out4 = (select0) ? 32'b0 : {buf3, buf2, buf1, buf0};

	assign out5 = (select1) ? out2 : out1;
	assign out6 = (select1) ? out4 : out3;

	assign read_buf = (select2) ? out6 : out5;

	/*
	 *	This uses Yosys's support for nonzero initial values:
	 *
	 *		https://github.com/YosysHQ/yosys/commit/0793f1b196df536975a044a4ce53025c81d00c7f
	 *
	 *	Rather than using this simulation construct (`initial`),
	 *	the design should instead use a reset signal going to
	 *	modules in the design.
	 */
	initial begin
		$readmemh("verilog/data.hex", data_block);
		clk_stall = 0;
	end

	/*
	 *	LED register interfacing with I/O
	 */
	always @(posedge clk) begin
		if(memwrite == 1'b1 && addr == 32'h2000) begin
			led_reg <= write_data;
		end
	end

	wire [31:0] dsp_sub_out;

	DSPSub dsp_sub(
		.clk(clk),
		.input1({22'b0, addr_buf_block_addr}),
		.input2(32'h1000),
		.out(dsp_sub_out)
	);

	always @(posedge hfclk) begin
		case (state)
			IDLE: begin
				memread_buf <= memread;
				memwrite_buf <= memwrite;
				addr_buf <= addr;
				write_data_buffer <= write_data;
				sign_mask_buf <= sign_mask;
			end
		endcase
	end
	/*
	 *	State machine
	 */
	always @(posedge clk) begin
		case (state)
			IDLE: begin
				if(memwrite || memread) begin
					// memread_buf <= memread;
					// memwrite_buf <= memwrite;
					// addr_buf <= addr;
					// write_data_buffer <= write_data;
					// sign_mask_buf <= sign_mask;
					state <= READ_BUFFER;
					clk_stall <= 1;
				end
			end

			READ_BUFFER: begin
				/*
				 *	Subtract out the size of the instruction memory.
				 *	(Bad practice: The constant should be a `define).
				 */
				word_buf <= data_block[dsp_sub_out];
				if(memread_buf) begin
					state <= READ;
				end
				else if(memwrite_buf) begin
					state <= WRITE;
				end
			end

			READ: begin
				clk_stall <= 0;
				read_data <= read_buf;
				state <= IDLE;
			end

			WRITE: begin
				clk_stall <= 0;

				/*
				 *	Subtract out the size of the instruction memory.
				 *	(Bad practice: The constant should be a `define).
				 */
				data_block[dsp_sub_out] <= replacement_word;
				state <= IDLE;
			end

		endcase

		// CUSTOM

		// clk_stall = 1;
		// addr_buf <= addr;
		// write_data_buffer <= write_data;
		// sign_mask_buf <= sign_mask;
		// word_buf <= data_block[dsp_sub_out];

		// if(memread) begin
		// 	read_data = read_buf;
		// 	clk_stall = 0;
		// end
		// else if(memwrite) begin
		// 	data_block[dsp_sub_out] = replacement_word;
		// 	clk_stall = 0;
		// end
	end

	/*
	 *	Test led
	 */
	assign led = led_reg[7:0];
endmodule


module DSPSub(clk, input1, input2, out);
    input [31:0] input1;
    input [31:0] input2;
	input clk;
    output [31:0] out;


	SB_MAC16 i_sbmac16
	(
		.A(input2[31:16]),
		.B(input2[15:0]),
		.C(input1[31:16]),
		.D(input1[15:0]),
		.O(out),
		.CLK(clk),
		.CE(1'b0), // clock enabled input? What happens if we disable?
		.IRSTTOP(1'b0),
		.IRSTBOT(1'b0),
		.ORSTTOP(1'b0),
		.ORSTBOT(1'b0),
		.AHOLD(1'b0),
		.BHOLD(1'b0),
		.CHOLD(1'b0),
		.DHOLD(1'b0),
		.OHOLDTOP(1'b0),
		.OHOLDBOT(1'b0),
		.OLOADTOP(1'b0),
		.OLOADBOT(1'b0),
		.ADDSUBTOP(1'b1),
		.ADDSUBBOT(1'b1),
		.CO(),
		.CI(1'b0),
		.ACCUMCI(1'b0),
		.ACCUMCO(),
		.SIGNEXTIN(1'b0),
		.SIGNEXTOUT()
	);

    // add_sub_32_bypassed_unsigned [24:0] 001_0010000_0010000_0000_0000
    // bypass, take from adder/subtractor output directly, do not store in accumulator register
    defparam i_sbmac16.B_SIGNED = 1'b0 ;
    defparam i_sbmac16.A_SIGNED = 1'b0 ;
    defparam i_sbmac16.MODE_8x8 = 1'b1 ;

    defparam i_sbmac16.BOTADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT = 1'b1 ;
    defparam i_sbmac16.BOTADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16.BOTOUTPUT_SELECT = 2'b00 ; //lower [15:0] of adder/subtractor

    defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16.TOPADDSUB_UPPERINPUT = 1'b1 ;
    defparam i_sbmac16.TOPADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16.TOPOUTPUT_SELECT = 2'b00 ; // higher [31:16] of adder/subtractor

    defparam i_sbmac16.PIPELINE_16x16_MULT_REG2 = 1'b0 ;
    defparam i_sbmac16.PIPELINE_16x16_MULT_REG1 = 1'b0; 
    defparam i_sbmac16.BOT_8x8_MULT_REG = 1'b0;
    defparam i_sbmac16.TOP_8x8_MULT_REG = 1'b0;

    defparam i_sbmac16.D_REG = 1'b0;
    defparam i_sbmac16.B_REG = 1'b0;
    defparam i_sbmac16.A_REG = 1'b0;
    defparam i_sbmac16.C_REG = 1'b0;
     
endmodule