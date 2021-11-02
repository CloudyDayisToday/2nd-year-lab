/////////////////////////////////////////////////////////////////////
// Design unit: sequencer
//            :
// File name  : sequencer.sv
//            :
// Description: Code for M4 Lab exercise
//            : Outline code for sequencer
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Author     : 
//            : School of Electronics and Computer Science
//            : University of Southampton
//            : Southampton SO17 1BJ, UK
//            : 
//
// Revision   : Version 1.0 
/////////////////////////////////////////////////////////////////////

module sequencer (input logic start, clock, Q0, n_rst,
 output logic add, shift, ready, reset);

logic [2:0] count = 4;

enum {idle, adding, shifting, stopped} present_state, next_state;

always_ff @(posedge clock, negedge n_rst)
begin
	if (!n_rst)
	begin
		present_state <= idle;
		count <= 4;
	end
	else
	begin
		if(next_state == adding)
			count <= count - 1;
		if(next_state == stopped)
			count <= 4;
		present_state <= next_state;
	end
end

always_comb
begin
	reset = 1'b0;
	shift = 1'b0;
	ready = 1'b0;
	add = 1'b0;
	next_state = present_state;
	unique case (present_state)
	idle:
	begin
		reset = 1'b1;
		if (start)
			next_state = adding;
		else
			next_state = idle;
	end
	adding:
	begin
		if (Q0)
			add = 1'b1;
		next_state = shifting;
	end
	shifting:
	begin
		shift = 1'b1;
		if (count > 0)
			next_state = adding;
		else
			next_state = stopped;
	end
	stopped:
	begin
		ready = 1'b1;
		if (start)
			next_state = idle;
	end
	endcase
end
  
endmodule

      
              
             