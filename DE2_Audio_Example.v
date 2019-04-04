
module DE2_Audio_Example (
	// Inputs
	LEDR,
	CLOCK_50,
	KEY,

	AUD_ADCDAT,

	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,

	I2C_SDAT,

	// Outputs
	AUD_XCK,
	AUD_DACDAT,

	I2C_SCLK,
	SW
);


/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input		[17:0]	SW;
input [3:0] KEY;
input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;
inout				I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;
output				I2C_SCLK;


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


wire [15:0] display_data = right_channel_audio_out[31:15];
wire [15:0] display_data_scaled;

output	reg [15:0]	LEDR;

// Internal Registers

reg [16:0] delay_cnt, delay;
reg snd;
reg slow_counter_out; 
reg fast_counter_out;

assign tick = (fast_counter_out == 0) ? 1 : 0;
/*****************************************************************************
 *                             Sequential Logic                              *
 *****************************************************************************/

// Counter for audio transformations.
always @(posedge CLOCK_50)
	if(delay_cnt == delay) begin
		delay_cnt <= 0;
		snd <= !snd;
	end else delay_cnt <= delay_cnt + 1;

// Counter for slide transformation
always @(posedge tick)
	if(slow_counter_out == 16'b1111111111111111) begin
		slow_counter_out <= 0;
	end else slow_counter_out <= slow_counter_out + 1;
	
always @(posedge CLOCK_50)
	if(fast_counter_out == 4'b1111) begin
		fast_counter_out <= 0;
	end else fast_counter_out <= fast_counter_out + 1;
	

// Set LEDR to reflect audio changes.
always @(negedge write_audio_out)
		LEDR[15:0] = left_channel_audio_out[31:16];

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

// Control the delay of the sampler.
assign delay = (slide == 0) ? SW[16:0] : fast_counter_out;
assign slide = SW[17];

// Tell audio controller when to sample.
assign read_audio_in	= audio_in_available & audio_out_allowed;
assign left_channel_audio_out	= (SW == 0) ? left_channel_audio_in : snd ? 0 : left_channel_audio_in;
assign right_channel_audio_out	= (SW == 0) ? right_channel_audio_in: snd ? 0 : right_channel_audio_in;
assign write_audio_out = audio_in_available & audio_out_allowed;

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

Audio_Controller Audio_Controller (
	// Inputs
	.CLOCK_50						(CLOCK_50),
	.reset						(~KEY[0]),

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
	.reset						(~KEY[0])
);

endmodule
