# Waveform Visualizer - CSCB58 Final Project

This project is an FPGA application on the Altera DE2-115 board that visualizes sound waves from a microphone input.
It outputs the sound waves it receives onto the onboard LED bar (although at a somewhat low sensitivity).
The user is also able to listen to the input from a speaker, and is also able to transform that input using the onboard switches.

## Usage

Connect a microphone to the microphone jack and connect a speaker to the speaker jack.
To perform audio transformations, use SW[16:0] and provide sound input to the microphone.

SW[17] is a switch that "slides" the audio pitch from high to low. Just configure the speed you wish in the Verilog code in the counter.

In general, the higher the switch count, the lower the voice.
Some configurations might give some surprising results!

## Credits

The audio controller (and most of our troubles) came from: http://www.eecg.toronto.edu/~jayar/ece241_08F/AudioVideoCores/audio/audio.html
