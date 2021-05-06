module square_sum(
	input wire signed [7:0] sig_in,
	input wire sample_clk,
	input wire reset,
	output reg signed [15:0] square
);

initial begin
	square <= 16'b0;
end

always @ (posedge sample_clk) begin
	
end

always @ (negedge sample_clk) begin
	// Negedge that way it happens right after
	// the posedge clk of the orthogonal when
	// the result is updated
	//if (reset == 1'b1) begin
		square <= 0 + sig_in*sig_in;
	//end
	//else begin
		//square <= square + sig_in*sig_in;
	//end
end

endmodule
