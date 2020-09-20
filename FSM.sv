// TCES 330: Project B
// Rohan Seam & Trung Do
//
// This module is to implement the Finite state machine to control the other modules within the 
// processor. Inputs are a clock signal, reset signal, and IR. The reset signal resets the state
// machine back to its initial state, while the IR is an instruction for the state machine to 
// process. The other outputs represent control signals that determine the functionality of 
// external modules. The OutState represents the current state of the FSM. 
module FSM(Clock, reset, IR, PC_clr, PC_up, IR_ld, D_addr, D_wr, RF_s, 
			  RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0, OutState, OutNextState);
	input Clock, reset;					// clock and reset signal (Active Low)
	input [15:0] IR;						// Instruction from IR
	output logic PC_clr,					// PC clear command
					 PC_up,					// PC increment command
					 IR_ld,					// Instruction load command
					 D_wr, 					// Data memory write enable
					 RF_s,					// Mux 2 to 1 select line
					 RF_W_en;				// Register file write enable
	output [3:0] OutState;				// Display the current state of the FSM
	output [3:0] OutNextState;			// The next state of the FSM
	output logic [7:0] D_addr;			// Data memory address
	output logic [3:0] RF_W_addr,		// Register file write address
							 RF_Ra_addr,	// Register file A-side read adress
							 RF_Rb_addr;	// Register file B-side read adress
	output logic [2:0] ALU_s0;			// ALU function select line
	
	localparam Init	= 4'd0,
				  Fetch	= 4'd1,
				  Decode	= 4'd2,
				  NOOP	= 4'd3,
				  LOAD_A = 4'd4,
				  LOAD_B = 4'd5,
				  STORE	= 4'd6,
				  ADD		= 4'd7,
				  SUB		= 4'd8,
				  HALT	= 4'd9;

	logic [3:0] CurrentState = Init, NextState;		// Initialize to Init state
	
	assign OutState = CurrentState;
	assign OutNextState = NextState;
	
	always_comb begin
		PC_clr = 0;												// Initialize values to 0
		PC_up	 = 0;
		IR_ld	 = 0;
		D_wr	 = 0;
		RF_s	 = 0;
		RF_W_en= 0;
		D_addr = 0;
		RF_W_addr = 0;
		RF_Ra_addr= 0;
		RF_Rb_addr= 0;
		ALU_s0 = 0;
		
		case(CurrentState)
			Init: begin
				PC_clr = 1;										// PC = 0
				NextState = Fetch;
			end
			
			Fetch: begin
				IR_ld = 1;										// Load instruction
				PC_up = 1;										// PC = PC + 1
				NextState = Decode;
			end
			
			Decode: begin
				case(IR[15:12])								// Decode opcode
					4'b0000: NextState = NOOP;
					4'b0010: NextState = LOAD_A;
					4'b0001: NextState = STORE;
					4'b0011: NextState = ADD;
					4'b0100: NextState = SUB;
					4'b0101: NextState = HALT;
					default: NextState = NOOP;				// else go to NOOP
				endcase
			end
			
			NOOP: NextState = Fetch;						// Delay clock 
			
			LOAD_A: begin
				D_addr = IR[11:4]; 
				RF_s = 1;
				RF_W_addr = IR[3:0];
				NextState = LOAD_B;
			end
			
			LOAD_B: begin
				D_addr = IR[11:4]; 
				RF_s = 1;
				RF_W_addr = IR[3:0];
				RF_W_en = 1;
				NextState = Fetch;
			end
			
			STORE: begin
				D_addr = IR[7:0];
				D_wr = 1;
				RF_Ra_addr = IR[11:8];
				NextState = Fetch;
			end
			
			ADD: begin
				RF_W_addr = IR[3:0];							
				RF_W_en = 1;
				RF_Ra_addr = IR[11:8];
				RF_Rb_addr = IR[7:4];
				ALU_s0 = 1;										// Set ALU to correct operation (ADD)
				RF_s = 0;
				NextState = Fetch;
			end
			
			SUB: begin
				RF_W_addr = IR[3:0];							
				RF_W_en = 1;
				RF_Ra_addr = IR[11:8];
				RF_Rb_addr = IR[7:4];
				ALU_s0 = 2;										// Set ALU to correct operation (SUB)
				RF_s = 0;
				NextState = Fetch;
			end

			HALT: NextState = HALT;
			
			default: NextState = Init;
		endcase
	end
	
	// Reset to default state (Init) if reset is high. Otherwise, propagate to the next
	// state in the FSM on the positive edge of the clock.
	always_ff @(posedge Clock) begin
		if (~reset) CurrentState <= Init;
		else CurrentState <= NextState;				// Go to the next state we set
	end
endmodule 

// Testbench
module FSM_testbench();
	logic Clock, reset;				
	logic [15:0] IR;				
	logic PC_clr, PC_up, IR_ld, D_wr, RF_s, RF_W_en;			
	logic [3:0] OutState;
	logic [3:0] OutNextState;
	logic [7:0] D_addr;		
	logic [3:0] RF_W_addr, RF_Ra_addr, RF_Rb_addr;		
	logic [2:0] ALU_s0;		
	integer I;
	
	// Instantiate the FSM
	FSM DUT(Clock, reset, IR, PC_clr, PC_up, IR_ld, D_addr, D_wr, RF_s,
			  RF_W_addr, RF_W_en, RF_Ra_addr, RF_Rb_addr, ALU_s0, OutState, OutNextState);
			  
	// Clock
	always begin  	
		Clock = 0;  	
		#10;  	
		Clock = 1;  	
		#10;  
	end 
	
	initial begin
		$display("\t\t  Time \treset \tIR \tOutState \tPC_clr \tPC_up \tIR_ld \tD_addr \tD_wr \tRF_s \tRF_W_addr \tRF_W_en \tRF_Ra_addr \tRF_Rb_addr \tALU_s0 \tNextState");
		reset = 1;
		for (I = 0; I < 16; I++) begin
			IR[15:12] = I[3:0]; IR[11:8] = 4; IR[7:4] = 4; IR[3:0] = 4; #10;
			
			// Compare output to expected for each opcode. Decode and Fetch are tested for NOOP -> HALT
			
			// NOOP
			if (IR[15:12] == 4'b0) begin 
				assert(PC_clr == 1) else $error("incorrect! PC_clr = %d", PC_clr);
			end 
			
			// STORE
			else if (IR[15:12] == 4'd1) begin 
				assert(PC_up == 1 && IR_ld == 1) else $error("incorrect!");
			end
			
			// LOAD_A
			else if (IR[15:12] == 4'd2) begin 
				wait(DUT.CurrentState == DUT.LOAD_A); #5;
				assert(RF_s == 1 && D_addr == IR[11:4] && RF_W_addr == IR[3:0]) 
				else $error("incorrect! CurrentState = %d", DUT.CurrentState);
			end 
			
			// ADD
			else if (IR[15:12] == 4'd3) begin 
				//#15; 
				wait(DUT.CurrentState == DUT.ADD); #5;
				assert(RF_W_en == 1 && RF_W_addr == IR[3:0] && RF_Ra_addr == IR[11:8] && 
						 RF_Rb_addr == IR[7:4] && ALU_s0 == 1 && RF_s == 0)
				else $error("incorrect! NextState = %d and CurrentState = %d", DUT.NextState, DUT.CurrentState); 
			end

			// SUB 
			else if (IR[15:12] == 4'd4) begin  
				wait(DUT.CurrentState == DUT.SUB); #5;
				assert(RF_W_en == 1 && RF_W_addr == IR[3:0] && RF_Ra_addr == IR[11:8] && 
						 RF_Rb_addr == IR[7:4] && ALU_s0 == 2 && RF_s == 0) 
				else $error("Incorrect!"); 
			end 
			
			// HALT
			else if (IR[15:12] == 4'd5) begin 
				wait(DUT.NextState == DUT.HALT) 
				assert(DUT.NextState == DUT.HALT) 
				else $error("Incorrect! NextState = %d", DUT.NextState);
			end 
			
			// NOOP
			else begin
				wait(DUT.NextState == DUT.NOOP);
				assert(DUT.NextState == DUT.NOOP && PC_clr == 0 && PC_up == 0 && IR_ld == 0 && D_wr == 0 && 
						 RF_s == 0 && RF_W_en == 0 && RF_W_addr == 0 && RF_Ra_addr == 0 && RF_Rb_addr == 0 && 
						 ALU_s0 == 0)
				else $error("Incorrect! NextState = %d", DUT.NextState);
			end
		end
		
		// Test cases with reset = 1, current state should be default state (Init).
		reset = 0;
		for (I = 0; I < 16; I++) begin
			IR[15:12] = I[3:0]; IR[11:8] = 4; IR[7:4] = 4; IR[3:0] = 4; #250;
			assert(DUT.CurrentState == DUT.Init && PC_clr == 1) 
			else $error("Incorrect! CurrentState = %d", DUT.CurrentState);
		end
		$stop;
	end
	
	initial $monitor($time,,,,,reset,,,,,"%h",IR,,,,,,,,"%d",OutState,,,,,,,PC_clr,,,,,,,,PC_up,,,,,,,IR_ld,,,,,,D_addr,,,,,,,D_wr,,,,,,,RF_s,,,,,,,,,RF_W_addr,,,,,,,,,,,RF_W_en,,,,,,,,,RF_Ra_addr,,,,,,,,,,,RF_Rb_addr,,,,,,,,,,ALU_s0,,,,,,,OutNextState);
endmodule 

