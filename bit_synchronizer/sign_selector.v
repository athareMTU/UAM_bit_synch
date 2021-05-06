/***********************************************************************\
| Module:              sign_selector
| Author:              Alex Hare
| Last Updated:        02/05/2021
| Function:            Instead of using multipliers for correlation this
|                      function uses addition and subtraction with a 
|                      maintained storage variable. 
|                      If the reference signal is a 1, then add the 
|                      incomming signal value to the stored variable,
|                      else, subtract the incomming signal from the stored
|                      variable
| Inputs:              in     : incomming signal
|                      ref    : reference signal
|                      clk    : clock for calculating
| Output:              stored : maintained stored variable
| Additional comments: Largely based on Benson, B. "Design of a Low-Cost 
|                      Underwater Acoustic Modem for Short-Range Sensor 
|                      Networks", UC San Diego, 2010
\***********************************************************************/
module sign_selector(
	input wire signed [1:0] in,
	input wire        [7:0] ref,
	input wire              clk,
	input wire              rst,
	output reg signed [7:0] stored
);

//reg [7:0] stored;
initial stored = 8'b0;

always @ (posedge clk) begin
	if(rst == 1'b1) begin
		if ( ref == 8'b1 ) begin
			stored <= 8'b0 + in;
		end
		else if(ref == -8'd1) begin
			stored <= 8'b0 - in;
		end
	end
	else begin
		if ( ref == 8'b1 ) begin
			stored <= stored + in;
		end
		else if(ref == -8'd1) begin
			stored <= stored - in;
		end
	end
end

always @ (negedge clk) begin
	
end

endmodule
