module auto_tune(
	CLOCK_50,
	reset,
	data_audio_in,
	data_audio_out
);


/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

localparam AUDIO_DATA_WIDTH	= 32;
localparam BIT_COUNTER_INIT	= 5'd31;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
// Inputs
input				CLOCK_50;
input				reset;

input			[AUDIO_DATA_WIDTH:1]	data_audio_in;

output		[AUDIO_DATA_WIDTH:1]	data_audio_out;




assign data_audio_out = data_audio_in & 32'b0101_0101_0101_0101;




endmodule
