// TCES 330: Project B
// Trung Do & Rohan Seam
//
// This module is to implement the control unit that will initialize the program counter,
// the instruction memory, instruction register, and finite state machine. 
module ControlUnit(Clock, Reset, PC_Out, IR_Out, OutState, NextState, D_Addr, 
						 D_Wr,RF_s, RF_W_en, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr, ALU_s0);

	input Clock;
	input Reset;
	
	output [6:0] PC_Out;																		// Location of instruction
	output [15:0] IR_Out;																	// Instruction from IR
	output [3:0] OutState, NextState, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr;		
	output [7:0] D_Addr;																		// Address for data memory to be read
	output [2:0] ALU_s0;																		// ALU select signal
	output D_Wr, RF_s, RF_W_en;															// Enable bits
	
	logic PC_clr, PC_up, IR_ld;
	logic [15:0] instr_in;
	
	// Instantiate the PC
	// PC(Clock, Clr, Up, addr);
	PC P1(Clock, PC_clr, PC_up, PC_Out);
	
	// Instantiate the IR
	// IR(Clock, ld, instr_in, instr_out);
	IR I1(Clock, IR_ld, instr_in, IR_Out);
	
	// Instantiate the instruction memory
	InstMemory I2(.address(PC_Out), .clock(Clock), .q(instr_in));

	// Instantiate the FSM
	// FSM(Clock, reset, IR, PC_clr, PC_up, IR_ld, D_addr, D_wr, RF_s, 
	//		 RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0, OutState, OutNextState);
	FSM F1(Clock, Reset, IR_Out, PC_clr, PC_up, IR_ld, D_Addr, D_Wr, RF_s, RF_W_Addr, RF_W_en, 
			 RF_Ra_Addr, RF_Rb_Addr, ALU_s0, OutState, NextState);
	
	
endmodule 

// Testbench
`timescale 1ns/1ns
module ControlUnit_testbench();
	logic Clock;
	logic Reset;
	logic [6:0] PC_Out;																		
	logic [15:0] IR_Out;																	
	logic [3:0] OutState, NextState, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr;		
	logic [7:0] D_Addr;																		
	logic [2:0] ALU_s0;																	
	logic D_Wr, RF_s, RF_W_en;
	
	// Instantiate the Control Unit
	ControlUnit DUT(Clock, Reset, PC_Out, IR_Out, OutState, NextState, D_Addr, 
						 D_Wr,RF_s, RF_W_en, RF_Ra_Addr, RF_Rb_Addr, RF_W_Addr, ALU_s0);
						 
	// Clock signal
	always begin  	
		Clock = 0;  	
		#10;  	
		Clock = 1;  	
		#10;  
	end 
	
	initial begin
		$display("\t\t  Time \tReset \tPC_Out \tIR_Out \tOutState \tNextState \tD_addr \tD_wr \tRF_s \tRF_W_en \tRF_Ra_addr \tRF_Rb_addr \tRF_W_addr \tALU_s0");
		Reset = 1; #800;
		Reset = 0; #100;
		$stop;
	end
	
	initial $monitor($time,,,,,Reset,,,,,,PC_Out,,,,IR_Out,,,,,,,,OutState,,,,,,,,,,NextState,,,,,,,,D_Addr,,,,,,,D_Wr,,,,,,RF_s,,,,,,,RF_W_en,,,,,,,,,RF_Ra_Addr,,,,,,,,,,,,RF_Rb_Addr,,,,,,,,,,RF_W_Addr,,,,,,,,,ALU_s0);
endmodule 