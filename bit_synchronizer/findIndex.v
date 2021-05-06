/***********************************************************************\
| Module:              bit_synchronizer
| Author:              Alex Hare
| Last Updated:        03/25/2021
| Function:            This module will compare the Threshold and the
|                      Reference correlation result to find when the 
|                      reference peaks above the threshold. When this occurs
|                      this is considered a synch point. The biggest peak that
|                      occurs over two reference code lengths is the
|                      actual synch point that will be used.
|                      
|                      Once a peak is detected the demodulator will be enabled,
|                      and a symbol clock will begin
|                      to count the amount of signals being demodulated. This
|                      is used to keep track of how many symbols we peak detect
|                      for two reference lengths and to reset the process once
|                      an entire packet as been detected. When a bigger peak is
|                      encountered that one will then be stored and the symbol clk
|                      will be re-synched.
|                      
|                      Once the packet is completed the addr signal is calculated.
|                      This signal is where the packet begins in the Temp Buffer, 
|                      which recieves the output of the demod.
|                      
| Inputs:           ref_corr - The Result of the Reference Correlation
|                  threshold - Threshold result
|                      
| Output: enable_demodulator - Enables the demod when high
|                 symbol_clk - Synched symbol clk, used for demod and counting
|                      index - Stores when the peak occurs
|                       addr - output address with the highest peak
|                              sent to temp buffer to work out where
|                              the data is
|
|             
| Additional comments: Largely based on Benson, B. "Design of a Low-Cost 
|                      Underwater Acoustic Modem for Short-Range Sensor 
|                      Networks", UC San Diego, 2010
\***********************************************************************/
module findIndex(
	input wire clk,
	input wire signed [7:0] ref_corr,
	input wire signed [15:0] threshold,
	output reg enable_demodulator,
	output reg enable_symbol_clk,
	output reg symbol_clk,
	output reg [7:0] index,
	output reg addr
);

parameter REFERENCE_LENGTH = 15;
parameter NUM_SAMPLES     = 120;  // DOWN_SAMPLE_FACTOR*REFERENCE_LENGTH*2
parameter DOWN_SAMPLE_FACTOR = 4; // Really just Sample Factor

reg [7:0] ref_length_count; // how many bits into the refrence
reg [7:0] symbol_num_count; // number of demodulated bits
reg [1:0] symbol_clk_count; // down sampled clk
reg [7:0] peak_size;        // Keeps track of the largest peak
//reg [7:0] index;
reg rst_symbol_clk;
reg rst_symbol_count;
reg completion;              // Used as a reset signal

reg first_peak;
reg start_ref_count;

initial begin
	ref_length_count   <= 8'b0;
	symbol_num_count   <= 8'b0;
	symbol_clk_count   <= 2'b0;
	peak_size          <= 8'b0;
	index              <= 8'b0;
	rst_symbol_clk     <= 1'b0;
	rst_symbol_count   <= 1'b0;
   completion         <= 1'b0;
	first_peak         <= 1'b0;
	start_ref_count    <= 1'b0;
	enable_demodulator <= 1'b0;
	enable_symbol_clk  <= 1'b0;
	//symbol_clk         <= 1'b0;
end
	
always @ (posedge clk) begin
	// Reset signal after the packet has been demodulated
	if(completion == 1'b1) begin
		start_ref_count    <= 1'b0;
		enable_demodulator <= 1'b0;
		first_peak         <= 1'b0;
		rst_symbol_clk     <= 1'b0;
		symbol_clk_count   <= 2'b0;
		peak_size          <= 8'b0;
		//completion         <= 1'b0;
	end
	
	// If the refrence correlation is greater than the threshold, this is
	// a peak and should set the index to the current symbol_num_count.
	// If this is the first peak then it starts the symbol_num_count
	if((ref_corr > threshold)) begin
		// If peak
		if(first_peak == 1'b0) begin
			index              <= 8'b0;
			start_ref_count    <= 1'b1;
			enable_demodulator <= 1'b1;
			rst_symbol_clk     <= 1'b1;
			symbol_clk         <= 1'b1;
			first_peak         <= 1'b1;
			peak_size          <= ref_corr;
		end
		else if((ref_corr > peak_size) && (ref_length_count < (8'd2*REFERENCE_LENGTH))) begin
			// if a new peak that is bigger than the previous bigger peak
			// AND if the reference count is less than double the reference length 
			peak_size          <= ref_corr;
			index              <= ref_length_count;
			
			// Reset Symbol Clk to synch with new peak
			rst_symbol_clk     <= 1'b1;
			symbol_clk         <= 1'b1;
		end
	end
	
	// Symbol Clock
	if(rst_symbol_clk == 1'b1) begin
		symbol_clk_count <= 2'b1; // Its 1 and not 0 to adjust for synching at peak
		rst_symbol_clk   <= 1'b0;
		symbol_clk       <= 1'b1;
	end 
	else if(symbol_clk_count == (2'd1)) begin // If half the sampling factor
		symbol_clk_count <= 2'b0;
		symbol_clk <= ~symbol_clk;
	end
	else begin
		symbol_clk_count <= symbol_clk_count + 2'b1;
	end
	
end

always @ (posedge symbol_clk) begin
	// Reset Completion
	if(completion == 1'b1) begin
		completion <= 1'b0;
		ref_length_count <= 8'b0;
	end

	// Counter to keep track of where we are in the
	// reference length
	if(start_ref_count == 1'b1) begin
		if(ref_length_count < (8'd239)) begin // Counts up to Packet size + an extra reference length, 224 + 15 = 239
			ref_length_count   <= ref_length_count + 8'b1; 
		end 
		else begin
			addr       <= ref_length_count - ((NUM_SAMPLES - 1 - index)/DOWN_SAMPLE_FACTOR);// Calculate addr at the end of two refernce lengths
			completion <= 1'b1;
		end
	end	
end
	
// Need a counter based on the clock the demod uses that can then count the number of bits
// that have been demodulated. This can then reset the findIndex module

always @ (negedge clk) begin
	
end
	
endmodule
