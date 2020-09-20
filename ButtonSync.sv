// TCES 330 
// Rohan Seam & Trung Do
// button sync

module ButtonSync( Clk, Bi, Bo);
  input Clk;        // system clock
  input Bi;        
  output logic Bo;  // system output 
  
  // State names
  localparam A  = 2'd0, 
             B  = 2'd1, 
             C    = 2'd2, 
             Unused  = 2'd3;
             
  logic [1:0] State = A, NextState;  // state variables
  
  // Combinational logic
  always_comb begin
    Bo = 1'b0;	                // system output (by default)
    NextState = State;  		 // by default don't change state
    
    case (State)
      
      A: begin
          // specify the output
        if (Bi)  begin
          NextState = B;  
        end
		  else NextState = A;
      end  
      
      B: begin
         Bo = 1'b1; // specify the output
        if (Bi) begin
          NextState = C;
        end
		  else NextState = A;
      end  
      
      C: begin
         //specify the output
	     if (Bi) begin
          NextState = C;
        end
		  else NextState = A;
       end
      
      default: begin
                              // specify the output
        NextState = A;        // safe state
      end
    endcase
  end 
    
  // StateReg 
  always_ff @( posedge Clk ) begin
      State <= NextState;   // go to the state we set
  end  
  
endmodule

// Testbench
module ButtonSync_tb(); 
   logic Clk, Bi, Bo;
  	
	always begin  // 50 MHz Clock
	  Clk = 0;
		#10;
		Clk = 1'b1;
		#10;
	end
  
  ButtonSync DUT(Clk, Bi, Bo);
  
  initial begin
    Bi = 1'b0; #70; 			// generate input sequence
    Bi = 1'b1; #70;
	 Bi = 1'b0; #70;
	 $stop;
  end
  
  initial
    $monitor($time,,,Bo);
  
endmodule

