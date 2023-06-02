module DSPSub(input1, input2, out, carry_out);
	input [31:0] input1;
    input [31:0] input2;
    output [31:0] out;
	output carry_out;

	SB_MAC16 i_sbmac16
	(
		.A(input2[31 : 16]),
		.B(input2[15 : 0]),
		.C(input1[31 : 16]),
		.D(input1[15 : 0]),
		.O(out),
		.CLK(),
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
		.CO(carry_out),
		.CI(1'b0),
		.ACCUMCI(1'b0),
		.ACCUMCO(),
		.SIGNEXTIN(1'b0),
		.SIGNEXTOUT()
	);

    // add_sub_32_bypassed_unsigned [24:0] 001_0010000_1010000_0000_0000
    // bypass, take from adder/subtractor output directly, do not store in accumulator register
    defparam i_sbmac16.B_SIGNED = 1'b0 ;
    defparam i_sbmac16.A_SIGNED = 1'b0 ;
    defparam i_sbmac16.MODE_8x8 = 1'b1 ;

    defparam i_sbmac16.BOTADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16.BOTADDSUB_UPPERINPUT = 1'b1 ;
    defparam i_sbmac16.BOTADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16.BOTOUTPUT_SELECT = 2'b00 ; //lower [15:0] of adder/subtractor

    defparam i_sbmac16.TOPADDSUB_CARRYSELECT = 2'b10 ;
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