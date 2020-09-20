// TCES 330: Project B
// Rohan Seam & Trung Do
//
// This module is to implement the datapath that will instantiate the data memory, the 2 to 1
// MUX, the register file, and the ALU modules. 
module Datapath(Clock, D_Addr, D_Wr, RF_s, RF_W_Addr, RF_W_en, RF_Ra_Addr, 
					 RF_Rb_Addr, ALU_s0, ALU_inA, ALU_inB, ALU_out);
	
	input Clock;
	input D_Wr, RF_s, RF_W_en;
	input [7:0] D_Addr;
	input [3:0] RF_W_Addr, RF_Ra_Addr, RF_Rb_Addr;
	input [2:0] ALU_s0;
	
	output [15:0] ALU_inA, ALU_inB, ALU_out;
	logic [15:0] mux_out;											// Output from the 2 to 1 MUX
	logic [15:0] data_out;											// Output from the Data Memory
	
	// Instantiate the Register (16x16)
	// Register(Clk, write, W_addr, W_data, Ra_addr, Ra_data, Rb_addr, Rb_data);
	Register R1(Clock, RF_W_en, RF_W_Addr, mux_out, RF_Ra_Addr, ALU_inA, RF_Rb_Addr, ALU_inB);
	
	// Instantiate the MUX (2 to 1)
	// mux_16w_2_to_1(s, A, B, Q);
	mux_16w_2_to_1 m1(RF_s, data_out, ALU_out, mux_out);
	
	// Instantiate the Data Memory (256x16)
	DataMemory D1(.address(D_Addr), .clock(Clock), .data(ALU_inA), .wren(D_Wr), .q(data_out));
	
	// Instantiate the ALU 
	// ALU(A, B, Sel, Q);
	ALU A1(ALU_inA, ALU_inB, ALU_s0, ALU_out);
	
endmodule 

// Testbench
`timescale 1ns/1ns
module Datapath_testbench();
	logic Clock;
	logic D_Wr, RF_s, RF_W_en;
	logic [7:0] D_Addr;
	logic [3:0] RF_W_Addr, RF_Ra_Addr, RF_Rb_Addr;
	logic [2:0] ALU_s0;
	logic [15:0] ALU_inA, ALU_inB, ALU_out;
	integer i;
	
	// Instantiate the data path
	Datapath DUT(Clock, D_Addr, D_Wr, RF_s, RF_W_Addr, RF_W_en, RF_Ra_Addr, 
					 RF_Rb_Addr, ALU_s0, ALU_inA, ALU_inB, ALU_out);
					 
	// Clock signal
	always begin  	
		Clock = 0;  	
		#10;  	
		Clock = 1;  	
		#10;  
	end 
	
	initial begin
		$display("\t \t   Time, \t D_Addr, \t D_Wr, \t RF_s, \t RF_W_Addr, \t RF_W_en, \t RF_Ra_Addr, \t RF_Rb_Addr, \t ALU_s0, \t ALU_inA, \t ALU_inB, \t ALU_out");
		
		// Read from the data memory and check ALU operation ADD and write to memory address 6.
		D_Addr = 6; D_Wr = 1; RF_s = 1; RF_W_en = 1; RF_W_Addr = 1; RF_Ra_Addr = 1; RF_Rb_Addr = 1; ALU_s0 = 1; #30;
		assert(ALU_out == ALU_inA + ALU_inB) 
		else $error("Incorrect! ALU_out = %d, ALU_inA = %d, ALU_inB = %d", ALU_out, ALU_inA, ALU_inB);
		$display("\t \t   Memory[6] = %h", DUT.data_out);
		
		// Confirm the memory contains contents of ALU_inA at memory address 6.
		D_Wr = 0; #40;
		assert(ALU_inA == DUT.data_out)
		else $error("Incorrect! Memory[6] = %d", DUT.data_out);
		
		// Test reading from memory, registers, and perform ALU add operation.
		D_Wr = 1; RF_s = 0; ALU_s0 = 1; #120;
		for(i = 0; i < 4; i++) begin
			D_Addr = $urandom_range(0,16); RF_W_Addr = $urandom_range(0,16); RF_Ra_Addr = $urandom_range(0,16);
			RF_Rb_Addr = $urandom_range(0,16); #20;
			
			assert(ALU_out == ALU_inA + ALU_inB) 
			else $error("Incorrect!");
		end
		
		// Test reading from memory, registers, and perform ALU zero operation.
		D_Wr = 0; RF_s = 1; ALU_s0 = 0; #120;
		for(i = 0; i < 4; i++) begin
			D_Addr = $urandom_range(0,16); RF_W_Addr = $urandom_range(0,16); RF_Ra_Addr = $urandom_range(0,16);
			RF_Rb_Addr = $urandom_range(0,16); #20;
				
			assert(ALU_out == 0) 
			else $error("Incorrect!");
		end
		
		// Test reading from memory, registers, and perform ALU subtract operation.
		D_Wr = 0; RF_s = 1; ALU_s0 = 2; #120;
		for(i = 0; i < 4; i++) begin
			D_Addr = $urandom_range(0,16); RF_W_Addr = $urandom_range(0,16); RF_Ra_Addr = $urandom_range(0,16);
			RF_Rb_Addr = $urandom_range(0,16); #20;
				
			assert(ALU_out == ALU_inA - ALU_inB) 
			else $error("Incorrect!");
		end
		$stop;
	end
	
	initial $monitor($time,,,,,,,,D_Addr,,,,,,,,,D_Wr,,,,,,,,,RF_s,,,,,,,,RF_W_Addr,,,,,,,,,,,,,RF_W_en,,,,,,,,,,,RF_Ra_Addr,,,,,,,,,,,,,RF_Rb_Addr,,,,,,,,,,,,ALU_s0,,,,,,,,,"%h",ALU_inA,,,,,,,,"%h",ALU_inB,,,,,,,,"%h",ALU_out);
endmodule 