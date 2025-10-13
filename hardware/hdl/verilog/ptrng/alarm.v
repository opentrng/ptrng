//Total failure alarm on RRN. The total failure detection method depends on the digitizer type, the detection it triggered when the internal counter is greater or equal than the input threshold parameter.`


module alarm #(
  parameter REG_WIDTH  = 32,     
  parameter RAND_WIDTH = 32  
)(
  input clk,                                     //Base clock
  input reset,                                   //Asynchronous reset active to '1'
  input clear,                                   //Synchronous clear active to '1'
  input [30:0] digitizer,                        //Digitizer type (see in constants package)
  input [RAND_WIDTH -1:0] raw_random_number,     //Raw Random Number input data (RRN)
  input raw_random_valid,                        //RRN data input validation
  input [REG_WIDTH - 1:0] threshold,             //Threshold value to trigger the failure

  output reg detected                            //Set to '1' when the total failure event is detected
); 

//RTL implementation of the total failure alarm
`include "~/design/opentrng/trunk/ptrng/hardware/config/digitalnoise/constants.v"

reg [REG_WIDTH - 1: 0]  counter;
reg [RAND_WIDTH - 1: 0] value;

always @(posedge clk or posedge reset) begin
  if(reset) begin
    counter <= {REG_WIDTH{1'b0}};
    value <= {RAND_WIDTH{1'b0}};
  end else begin
    if(clear) begin
      counter <= {REG_WIDTH{1'b0}};
      value <= {RAND_WIDTH{1'b0}};
    end else begin
      //In test mode increase the counter each RRN
      if(digitizer == TEST) begin
        if(raw_random_valid) begin
          counter <= counter + 1'b1;
        end 
      end else if(digitizer == ERO || digitizer == MURO) begin //For ERO/MURO count for long runs of same value
        if(raw_random_valid) begin
          if (raw_random_number == value) begin
            counter <= counter + 1'b1;
          end else begin
            counter <= {REG_WIDTH{1'b0}};
            value <= raw_random_number;
          end
        end
      end else if(digitizer == COSO) begin                    //For COSO reset the counter each time there os a valid RRN
        if(raw_random_valid) begin
          counter <= {REG_WIDTH{1'b0}};
        end else begin
          counter <= counter + 1'b1;
        end
      end else begin                                         //If no valid digitizer is set the counter highest value to trig the event
        counter <= {REG_WIDTH{1'b1}};
      end
    end
  end
end

//Trig the failure detected event when counter GT threshold

always @(posedge clk or posedge reset) begin
  if(reset) begin
    detected <= 1'b0;
  end else begin
    if(clear) begin
      detected <= 1'b0;
    end else if(counter >= threshold) begin
      detected <= 1'b1;
    end
  end
end

endmodule
