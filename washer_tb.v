`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:44:07 07/21/2015
// Design Name:   WASHER
// Module Name:   C:/Users/ML/Desktop/wash/washer_tb.v
// Project Name:  clock
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: WASHER
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module washer_tb;
	reg POWER;
	reg STOP;
	reg SET_M;
	reg SET_W;
	reg CLK;

	// Outputs
	wire LED_1;
	wire LED_2;
	wire LED_3;
	wire LED_in;
	wire LED_out;
	wire LED_ST;
	wire LED_P;
	wire LED_A;
	wire [3:0] q_ctl;
	wire [7:0] q_out;

	// Instantiate the Unit Under Test (UUT)
	WASHER uut (
		.POWER(POWER), 
		.STOP(STOP), 
		.SET_M(SET_M), 
		.SET_W(SET_W), 
		.CLK(CLK), 
		.LED_1(LED_1), 
		.LED_2(LED_2), 
		.LED_3(LED_3), 
		.LED_in(LED_in), 
		.LED_out(LED_out), 
		.LED_ST(LED_ST), 
		.LED_P(LED_P), 
		.LED_A(LED_A), 
		.q_ctl(q_ctl), 
		.q_out(q_out)
	);

	 initial
			begin
				POWER=0;
				STOP=0;
				CLK=0;
				SET_W=0;
				SET_M=0;
				#20 POWER=1;
				#20 STOP=1;
				#10 STOP=0;    
			end
	always
		begin
			#1 CLK=~CLK;  
		end
endmodule

