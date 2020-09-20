// TCES 330: Project B
// Rohan Seam & Trung Do
//
// This module is to implement a decoder that takes an input and deciphers to give the output 
// to be displayed to a hex display. The input a is the 4 bit value that needs to be decoded, 
// while the hex output is a 7 bit output to be displayed to the hex display.
module Decoder(hex,leds);
	input [3:0] hex;					// hex number input
	output logic [0:6] leds;		// seven segment output display on HEX
	
	always @(hex) begin
		case(hex)						// 15 cases to display 0 to F.
			4'b0000: leds = 7'b0000001;
			4'b0001: leds = 7'b1001111;
			4'b0010: leds = 7'b0010010;
			4'b0011: leds = 7'b0000110;
			4'b0100: leds = 7'b1001100;
			4'b0101: leds = 7'b0100100;
			4'b0110: leds = 7'b0100000;
			4'b0111: leds = 7'b0001111;
			4'b1000: leds = 7'b0000000;
			4'b1001: leds = 7'b0000100;
			4'b1010: leds = 7'b0001000;
			4'b1011: leds = 7'b1100000;
			4'b1100: leds = 7'b0110001;
			4'b1101: leds = 7'b1000010;
			4'b1110: leds = 7'b0110000;
			4'b1111: leds = 7'b0111000;
		endcase
	end
endmodule 