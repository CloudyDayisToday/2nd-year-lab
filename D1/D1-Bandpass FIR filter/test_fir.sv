module test_fir;

parameter SIZE = 16;

timeunit 1ns;
timeprecision 100ps;

logic signed [SIZE-1:0] in;
logic input_ready, ck, rst;
logic signed [SIZE-1:0] out;
logic output_ready;

//change the input frequency 
const int input_frequency = 5000;

fir CUT (.*);

 // clock generator
//  generates a 1 MHz clock

  
initial
  begin
  ck = '0;
  forever #50ns ck = ~ck;
  end
 
// test waveform generator creates a square wave
initial
  begin
  in = 0;
  forever
    begin
      #(500000000/input_frequency) in = -10000;
      #(500000000/input_frequency) in = 10000;
    end
  end
  
// generate sample strobe at sample rate of 40kHz

always
  begin
      #24us input_ready = '1; //after 24us input goes HIGH and after 1us input drops back down to 0
      #1us  input_ready = '0;
    end
    
initial
  begin
  rst = '0;
  #10ns rst = '1;
  #10ns rst = '0;
  end
  
  
endmodule
 