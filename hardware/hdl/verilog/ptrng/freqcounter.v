//Counter to estimate 'osc' signal frequency. Returns the number of periods of 'osc' during 'N' periods of 'clk'.
module freqcounter #(
  parameter REG_WIDTH = 24,             //Width of the result (and internal counters) in bits
  parameter N = 1000                    //Number of periods of 'clk' to count   
)(
  input clk,                            //Reference clock
  input reset,                          //Asynchronous reset
  input clear,                          //Synchronous clear active to '1'
  input source,                         //Signal to estimate its frequency
  input enable,                         //Global enable for the entity
  input start,                          //Pulse '1' to start the frequency measure
   
  output reg done,                      //Flag set to '1' when the result is ready
  output reg overflow,                  //Flag set to '1' an overflow occured (in the counter and for duration signal)
  output reg [REG_WIDTH - 1:0] result   //Frequency estimation output
);

//RTL architecture for the frequency counter

parameter [REG_WIDTH - 1:0] MAX = {REG_WIDTH{1'b1}}; 

reg counting;
reg [REG_WIDTH - 1:0] counter;
reg busy;
reg finished;
reg [REG_WIDTH - 1:0] duration;


//Count the number of periods 'source'
wire rst_count;
assign rst_count = (reset == 1'b1) || (clear == 1'b1) || (start == 1'b1);

always @(posedge source or posedge rst_count) begin
  if(rst_count) begin
    counter <= {REG_WIDTH{1'b0}};
  end else begin
    if (enable == 1'b1 && counting == 1'b1) begin
      if (counter < MAX) begin
        counter <= counter + 1'b1;
      end
    end
  end
end

//State machine to manage the measurement operation
always @(posedge clk or posedge reset) begin
  if (reset) begin
    duration <= {REG_WIDTH{1'b0}};
    busy <= 1'b0;
    counting <= 1'b0;
    finished <= 1'b0;
    done <= 1'b0;
    overflow <= 1'b0;
  end else begin
    if(clear == 1'b0 && enable == 1'b1) begin
      if (!busy) begin
        if (start) begin
          duration <= {REG_WIDTH{1'b0}};
          busy <= 1'b1;
          counting <= 1'b1;
          finished <= 1'b0;
          done <= 1'b0;
          overflow <= 1'b0;
        end 
      end else begin
        if (!finished) begin
          if (duration >= N || N >= MAX) begin
            counting <= 1'b0;
            finished <= 1'b1;
          end else begin
            duration <= duration + 1'b1;
          end          
        end else begin
          busy <= 1'b0;
          finished <= 1'b0;
          done <= 1'b1;
          result <= counter;
          if (counter >= MAX || duration > N || N >= MAX) begin
            overflow <= 1'b1;
          end
        end
      end
    end else begin
      result <= {REG_WIDTH{1'b0}};
      duration <= {REG_WIDTH{1'b0}};
      busy <= 1'b0;
      counting <= 1'b0;
      finished <= 1'b0;
      done <= 1'b0;
      overflow <= 1'b0;
    end
  end
end
  
endmodule 
