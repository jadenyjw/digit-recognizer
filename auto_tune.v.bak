module auto_tune(
	CLOCK_50,
	reset,
	left_audio_in,
	right_audio_in, 
	left_audio_out, 
	right_audio_out
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

input			[AUDIO_DATA_WIDTH:1]	left_audio_in;
input			[AUDIO_DATA_WIDTH:1]	right_audio_in;

output		[AUDIO_DATA_WIDTH:1]	left_audio_out;
output		[AUDIO_DATA_WIDTH:1]	right_audio_out;
input				write_audio_out;




assign left_audio_out = left_audio_in;
assign right_audio_out = right_audio_in;




end module
