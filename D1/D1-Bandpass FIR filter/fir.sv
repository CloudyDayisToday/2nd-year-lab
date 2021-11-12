// FIR 16 stages; 16 bit samples. Could be parameterised.

module fir #(parameter SIZE = 16, parameter STAGE = 16)(input logic signed [SIZE-1:0] in,
       input logic input_ready, ck, rst ,
       output logic signed [SIZE-1:0] out,
       output logic output_ready);

typedef logic signed [SIZE-1:0] sample_array;
sample_array samples [0:STAGE-1];

// generate coefficients from Octave/Matlab
// disp(sprintf('%d,',round(fir1(15,0.5)*32768)))

const sample_array coefficients [0:STAGE-1] =
     '{-79,-136,312,654,-1244,-2280,4501,14655,14655,4501,-2280,-1244,654,312,-136,-79};


/*
const sample_array coefficients [0:STAGE-1] =
     '{50,62,81,102,110,83,0,-161,-413,-758,-1182,-1657,-2143,-2591,-2954,-3190,29450,-3190,-2954,-2591,-2143,-1657,-1182,-758,-413,-161,0,83,110,102,81,62,50};*/

logic unsigned [$clog2(STAGE)-1:0] address = '0; //clog2 of 16 is 4

logic signed [(2*SIZE)-1:0] sum;

typedef enum logic [1:0] {waiting, loading, processing, saving} state_type;
state_type present_state, next_state;

logic load, count, reset_accumulator;


always_ff @(posedge ck)
begin
  if (load)
    begin
    for (int i=STAGE-1; i >= 1; i--)
      samples[i] <= samples[i-1];
    samples[0] <= in;
    end
end
  

// accumulator register
always_ff @(posedge ck)
begin
  if (reset_accumulator)
    sum <= '0;
  else
    sum <= sum + samples[address] * coefficients[address];
end
    
always_ff @(posedge ck)
begin
  if (output_ready)
    out <= sum[2*SIZE-2:SIZE-1];
end
    
// address counter

// implement a synchronous counter that counts up through all 16 values of address
// when a count signal is true

always_ff @(posedge ck)
begin:SEQ_ADDRESS
	if(count)
		address <= address + 1;
	else
		address <= '0;
end
		

// controller state machine 

// implement a state machine to control the FIR
always_ff @(posedge ck, posedge rst)
begin:SEQ_SM
	if(rst)
		present_state <= waiting;
	else
		present_state <= next_state;
end

always_comb
begin:COM
	reset_accumulator = 1'b0;
	load = 1'b0;
	count = 1'b0;
	output_ready = 1'b0;
	next_state = present_state;
	unique case(present_state)
	waiting:
		begin
		reset_accumulator = 1'b1;
		if(input_ready)
			next_state = loading;
		end
	loading:
		begin
		load = 1'b1;
		reset_accumulator = 1'b1;
		next_state = processing;
		end
	processing:
		begin
		count = 1'b1;
		if(address == STAGE-1)
			next_state = saving;
		end
	saving:
		begin
		output_ready = 1'b1;
		next_state = waiting;
		end
	default:
		next_state = waiting;
	endcase
end
endmodule


