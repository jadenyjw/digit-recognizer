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

output [AUDIO_DATA_WIDTH:1]	data_audio_out;



always @(*)
begin
	if(data_audio_in > 22)
		data_audio_out = 22;
	if(data_audio_in < 11)
		data_audio_out = 11;
	else
		data_audio_out = data_audio_in;
end





endmodule
