`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc 2011
// Engineer: Michelle Yu  
//				 Josh Sackos
// Create Date:    07/23/2012 
//
// Module Name:    DisplayController
// Project Name:   PmodKYPD_Demo
// Target Devices: Nexys3
// Tool versions:  Xilinx ISE 14.1 
// Description: This file defines a DisplayController that controls the seven segment display that works with 
// 				 the output of the Decoder.
//
// Revision History: 
// 						Revision 0.01 - File Created (Michelle Yu)
//							Revision 0.02 - Converted from VHDL to Verilog (Josh Sackos)
//////////////////////////////////////////////////////////////////////////////////////////////////////////

// ==============================================================================================
// 												Define Module
// ==============================================================================================
module DisplayController(
    DispVal,
    anode,
    segOut
    );

// ==============================================================================================
// 											Port Declarations
// ==============================================================================================

    input [3:0] DispVal;			// Output from the Decoder
    output [3:0] anode;				// Controls the display digits
    output [6:0] segOut;			// Controls which digit to display

// ==============================================================================================
// 							  		Parameters, Regsiters, and Wires
// ==============================================================================================
	
	// Output wires and registers
	wire [3:0] anode;
	reg [6:0] segOut;

// ==============================================================================================
// 												Implementation
// ==============================================================================================
	
	// only display the rightmost digit
	assign anode = 4'b1110;
	
	//------------------------------
	//		   Segment Decoder
	// Determines cathode pattern
	//   to display digit on SSD
	//------------------------------
	always @(DispVal) begin
			case (DispVal)

					4'h0 : segOut <= 7'b1000000;  // 0
					4'h1 : segOut <= 7'b1111001;  // 1
					4'h2 : segOut <= 7'b0100100;  // 2
					4'h3 : segOut <= 7'b0110000;  // 3
					4'h4 : segOut <= 7'b0011001;  // 4
					4'h5 : segOut <= 7'b0010010;  // 5
					4'h6 : segOut <= 7'b0000010;  // 6
					4'h7 : segOut <= 7'b1111000;  // 7
					4'h8 : segOut <= 7'b0000000;  // 8
					4'h9 : segOut <= 7'b0010000;  // 9
					4'hA : segOut <= 7'b0001000; 	// A
					4'hB : segOut <= 7'b0000011;	// B
					4'hC : segOut <= 7'b1000110;	// C
					4'hD : segOut <= 7'b0100001;	// D
					4'hE : segOut <= 7'b0000110;	// E
					4'hF : segOut <= 7'b0001110;	// F
					default : segOut <= 7'b0111111;
					
			endcase
	end

endmodule
