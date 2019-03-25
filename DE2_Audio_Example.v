
module DE2_Audio_Example (
	// Inputs

	input CLOCK_27,
	input			CLOCK_50,	
	input		[3:0]	KEY,	//	On Board 50 MHz
	input	[17:0]	SW,						//	Toggle Switch[17:0]
	output	[6:0]	HEX0,					//	Seven Segment Digit 0
	output	[6:0]	HEX1,					//	Seven Segment Digit 1
	output	[6:0]	HEX2,					//	Seven Segment Digit 2
	output	[6:0]	HEX3,					//	Seven Segment Digit 3
	output	reg [17:0]	LEDR,					//	LED Red[17:0]

	inout			AUD_ADCLRCK,			//	Audio CODEC ADC LR Clock
	input			AUD_ADCDAT,				//	Audio CODEC ADC Data
	inout			AUD_DACLRCK,			//	Audio CODEC DAC LR Clock
	output			AUD_DACDAT,				//	Audio CODEC DAC Data
	inout			AUD_BCLK,				//	Audio CODEC Bit-Stream Clock
	output			AUD_XCK,				//	Audio CODEC Chip Clock

	inout			I2C_SDAT,				//	I2C Data
	output			I2C_SCLK,				//	I2C Clock

	output			VGA_CLK,   				//	VGA Clock
	output			VGA_HS,					//	VGA H_SYNC
	output			VGA_VS,					//	VGA V_SYNC
	output			VGA_BLANK_N,				//	VGA BLANK
	output			VGA_SYNC_N,				//	VGA SYNC
	output	[7:0]	VGA_R,   				//	VGA Red[9:0]
	output	[7:0]	VGA_G,	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B 
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs


// Outputs




/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
// Internal Wires
wire				audio_in_available;
wire		[31:0]	left_channel_audio_in;
wire		[31:0]	right_channel_audio_in;
wire				read_audio_in;

wire				audio_out_allowed;
wire		[31:0]	left_channel_audio_out;
wire		[31:0]	right_channel_audio_out;
wire				write_audio_out;

wire vga_color;
wire [8:0] vga_x;
wire [7:0] vga_y;
wire vga_plot;

wire play = SW[0];
wire [3:0] scale = SW[8:5];

wire [31:0] display_data = play ? left_channel_audio_out : left_channel_audio_in;
reg [31:0] display_data_scaled;

// Internal Registers

reg [18:0] delay_cnt, delay;
reg snd;

wire reset = ~KEY[0];

// And all we needed was a sign-extended shift...
/*
always @(*)
	case(scale)
		0: display_data_scaled = display_data;
		1: display_data_scaled = {{2{display_data[15]}}, display_data[14:1]};
		2: display_data_scaled = {{3{display_data[15]}}, display_data[14:2]};
		3: display_data_scaled = {{4{display_data[15]}}, display_data[14:3]};
		4: display_data_scaled = {{5{display_data[15]}}, display_data[14:4]};
		5: display_data_scaled = {{6{display_data[15]}}, display_data[14:5]};
		6: display_data_scaled = {{7{display_data[15]}}, display_data[14:6]};
		7: display_data_scaled = {{8{display_data[15]}}, display_data[14:7]};
		8: display_data_scaled = {{9{display_data[15]}}, display_data[14:8]};
		9: display_data_scaled = {{10{display_data[15]}}, display_data[14:9]};
		10: display_data_scaled = {{11{display_data[15]}}, display_data[14:10]};
		11: display_data_scaled = {{12{display_data[15]}}, display_data[14:11]};
		12: display_data_scaled = {{13{display_data[15]}}, display_data[14:12]};
		13: display_data_scaled = {{14{display_data[15]}}, display_data[14:13]};
		14: display_data_scaled = {{15{display_data[15]}}, display_data[14:14]};
		15: display_data_scaled = {16{display_data[15]}};
	endcase
*/

// State Machine Registers

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/


/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

assign delay = {SW[3:0], 15'd3000};

wire [15:0] sound = (SW == 0) ? 0 : snd ? 16'd10000000 : -16'd10000000;


assign read_audio_in			= audio_in_available & audio_out_allowed;

assign left_channel_audio_out	= left_channel_audio_in+sound;
assign right_channel_audio_out	= right_channel_audio_in+sound;
assign write_audio_out			= audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(reset),

	.clear_audio_in_memory		(),
	.read_audio_in				(read_audio_in),
	
	.clear_audio_out_memory		(),
	.left_channel_audio_out		(left_channel_audio_out),
	.right_channel_audio_out	(right_channel_audio_out),
	.write_audio_out			(write_audio_out),

	.AUD_ADCDAT					(AUD_ADCDAT),

	// Bidirectionals
	.AUD_BCLK					(AUD_BCLK),
	.AUD_ADCLRCK				(AUD_ADCLRCK),
	.AUD_DACLRCK				(AUD_DACLRCK),


	// Outputs
	.audio_in_available			(audio_in_available),
	.left_channel_audio_in		(left_channel_audio_in),
	.right_channel_audio_in		(right_channel_audio_in),

	.audio_out_allowed			(audio_out_allowed),

	.AUD_XCK					(AUD_XCK),
	.AUD_DACDAT					(AUD_DACDAT),

);

avconf #(.USE_MIC_INPUT(1)) avc (
	.I2C_SCLK					(I2C_SCLK),
	.I2C_SDAT					(I2C_SDAT),
	.CLOCK_50					(CLOCK_50),
	.reset						(reset)
);

vga_adapter VGA(
			.resetn(!reset),
			.clock(CLOCK_50),
			.colour(vga_colour),
			.x(vga_x),
			.y(vga_y),
			.plot(vga_plot),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";


		/*
vga_adapter VGA(
			.resetn(!reset),
			.clock(CLOCK_50),
			.colour(vga_color),
			.x(vga_x),
			.y(vga_y),
			.plot(vga_plot),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC_N),CLOCK_27
			.clock_25(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "TRUE";
*/
display disp(CLOCK_50, reset, pause, display_data, vga_x, vga_y, vga_color, vga_plot);

hex2seg h4(scale, HEX0);

endmodule

