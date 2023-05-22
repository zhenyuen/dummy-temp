module DSPMulh(clk, input1, input2, out);
    input clk;
    input [31:0] input1;
    input [31:0] input2;
    output [31:0] out;

	wire co;
	wire accumco;
	wire signextout;

	SB_MAC16 i_sbmac16_lower
	(
		.A(input1[15 : 0]),
		.B(input2[15 : 0]),
		.C(16'b0),
		.D(16'b0),
		.O(),
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
		.ADDSUBTOP(1'b0),
		.ADDSUBBOT(1'b0),
		.CO(co),
		.CI(1'b0),
		.ACCUMCI(1'b0),
		.ACCUMCO(accumco),
		.SIGNEXTIN(1'b0),
		.SIGNEXTOUT(signextout)
	);
    // mult_16x16_bypass_ signed [24:0] 000 0000011 0000011 0000 0110
    defparam i_sbmac16_lower.B_SIGNED = 1'b0 ;
    defparam i_sbmac16_lower.A_SIGNED = 1'b0 ;
    defparam i_sbmac16_lower.MODE_8x8 = 1'b0 ;

    defparam i_sbmac16_lower.BOTADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16_lower.BOTADDSUB_UPPERINPUT = 1'b0 ;
    defparam i_sbmac16_lower.BOTADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16_lower.BOTOUTPUT_SELECT = 2'b11 ;

    defparam i_sbmac16_lower.TOPADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16_lower.TOPADDSUB_UPPERINPUT = 1'b0 ;
    defparam i_sbmac16_lower.TOPADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16_lower.TOPOUTPUT_SELECT = 2'b11 ;

    defparam i_sbmac16_lower.PIPELINE_16x16_MULT_REG2 = 1'b0 ;
    defparam i_sbmac16_lower.PIPELINE_16x16_MULT_REG1 = 1'b0; 
    defparam i_sbmac16_lower.BOT_8x8_MULT_REG = 1'b0;
    defparam i_sbmac16_lower.TOP_8x8_MULT_REG = 1'b0;

    defparam i_sbmac16_lower.D_REG = 1'b0;
    defparam i_sbmac16_lower.B_REG = 1'b1;
    defparam i_sbmac16_lower.A_REG = 1'b1;
    defparam i_sbmac16_lower.C_REG = 1'b0;

	
	SB_MAC16 i_sbmac16_upper
	(
		.A(input2[31 : 16]),
		.B(input2[31 : 16]),
		.C(16'b0),
		.D(16'b0),
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
		.ADDSUBTOP(1'b0),
		.ADDSUBBOT(1'b0),
		.CO(),
		.CI(co),
		.ACCUMCI(accumco),
		.ACCUMCO(),
		.SIGNEXTIN(signextout),
		.SIGNEXTOUT()
	);
    // mult_16x16_bypass_ signed [24:0] 000 0000011 0000011 0000 0110
    defparam i_sbmac16_upper.B_SIGNED = 1'b0 ;
    defparam i_sbmac16_upper.A_SIGNED = 1'b0 ;
    defparam i_sbmac16_upper.MODE_8x8 = 1'b0 ;

    defparam i_sbmac16_upper.BOTADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16_upper.BOTADDSUB_UPPERINPUT = 1'b0 ;
    defparam i_sbmac16_upper.BOTADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16_upper.BOTOUTPUT_SELECT = 2'b11 ;

    defparam i_sbmac16_upper.TOPADDSUB_CARRYSELECT = 2'b00 ;
    defparam i_sbmac16_upper.TOPADDSUB_UPPERINPUT = 1'b0 ;
    defparam i_sbmac16_upper.TOPADDSUB_LOWERINPUT = 2'b00 ;
    defparam i_sbmac16_upper.TOPOUTPUT_SELECT = 2'b11 ;

    defparam i_sbmac16_upper.PIPELINE_16x16_MULT_REG2 = 1'b0 ;
    defparam i_sbmac16_upper.PIPELINE_16x16_MULT_REG1 = 1'b0; 
    defparam i_sbmac16_upper.BOT_8x8_MULT_REG = 1'b0;
    defparam i_sbmac16_upper.TOP_8x8_MULT_REG = 1'b0;

    defparam i_sbmac16_upper.D_REG = 1'b0;
    defparam i_sbmac16_upper.B_REG = 1'b1;
    defparam i_sbmac16_upper.A_REG = 1'b1;
    defparam i_sbmac16_upper.C_REG = 1'b0;
     
endmodule


