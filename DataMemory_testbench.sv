// TCES 330: Project B
// Rohan Seam & Trung Do
//
// This module is to test the 1-port RAM for our Data memory. The data memory is of size 
// 256x16. 
`timescale 1ns/1ns
module DataMemory_testbench();
	logic Clock;
	logic [7:0] D_Addr;				// Address to read/write to in Memory
	logic [15:0] ALU_inA;			// Data to be written to Data Memory
	logic D_wr;							// Write enable signal from FSM
	logic [15:0] data_out;			// Data from Data Memory

	// Instantiate the Data Memory
	DataMemory D1(.address(D_Addr), .clock(Clock), .data(ALU_inA), .wren(D_wr), .q(data_out));
	
	// Clock implementation.
	always begin  	
		Clock = 0;  	
		#10;  	
		Clock = 1;  	
		#10;  
	end 
	
	initial begin
		// first test reading of RAM
	   $display("	Reading Ram");
	   D_wr = 0; // Write disabled
	   D_Addr = 0; #30;      // provide the address to read
	   @(posedge Clock)
	   $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
	   D_Addr = 6; #30;      // change to another address
	   @(posedge Clock)
	   $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
	   
		// Check address 11 
		D_Addr = 11; #30;
		@(posedge Clock)
		$display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
		
      	   // now test writing to RAM 
	   $display("	Writing Ram");
	   D_wr = 1;  // enable writing
	   D_Addr = 0; ALU_inA = 42; #30; // a new value to location 0 but the writing will take another clock cycle 
	   @(posedge Clock)           // at this cycle expected to read the old value at location 0
	   $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
		
		// Writing value to location 6. Testing replacement
		D_Addr = 6; ALU_inA = 1; #30;
		@(posedge Clock)
      $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
		
           // reading again to see if the write has changed the value at a specific location 
	   $display("	Reading Ram");
	   D_wr = 0;   // disable the writing
	   D_Addr = 1; #30; 
	   @(posedge Clock)
	   $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
		
      D_Addr = 0; #30;
	   @(posedge Clock)
	   $display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);

		// Read data and check if location 6 has 1.
		D_Addr = 6; #30;
		@(posedge Clock)
		$display($stime, ": Address = %d, ", D_Addr, "Data Read = %h", data_out);
		
	   $stop;
	end
endmodule 