`define	kFofE_HFOSC_CLOCK_DIVIDER_FOR_1Hz	12000000

module blink(led);
	output		led;

	wire		clk;
	reg		LEDstatus = 1;
	reg [31:0]	count = 0;

	/*
	 *	Creates a 48MHz clock signal from
	 *	internal oscillator of the iCE40
	 */
	SB_HFOSC OSCInst0 (
		.CLKHFPU(1'b1),
		.CLKHFEN(1'b1),
		.CLKHF(clk)
	);

	defparam OSCInst0.CLKHF_DIV = "0b01"; // Blinks at 12,000,000 based on lattice design entry appendix
	/*
	 *	Blinks LED at approximately 1Hz. The constant kFofE_CLOCK_DIVIDER_FOR_1Hz
	 *	(defined above) is calibrated to yield a blink rate of about 1Hz.
	 */
	always @(posedge clk) begin
		if (count > `kFofE_HFOSC_CLOCK_DIVIDER_FOR_1Hz) begin
			LEDstatus <= !LEDstatus;
			count <= 0;
		end
		else begin
			count <= count + 1;
		end
	end

	/*
	 *	Assign output led to value in LEDstatus register
	 */
	assign	led = LEDstatus;
endmodule
