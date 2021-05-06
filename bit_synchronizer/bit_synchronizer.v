/***********************************************************************\
| Module:              bit_synchronizer
| Author:              Alex Hare
| Last Updated:        03/04/2021
| Function:            Synchronizes to when a packet is recieved. Will
|                      detect incoming packets.
|                      The incomming signal is shaped into 1s and -1s.
|                      This module will take that signal and preform a
|                      correlation calculation against that signal using
|                      itself(reference code) and an orthogonal code.
|                      The orthogonal signal is then squared and becomes
|                      the threshold signal. The result of the reference
|                      correlation is then compared to the threshold in
|                      the Find Index module to calculate when there is a
|                      peak.                      
|                      
| Inputs:              sig_in             - The shaped signal of 1 or -1
|                      clk_correlator     - Clock that runs the correlation 
|                                           Is at the rate of symbol length
|                                           (One sample per symbol)
|                      clk_signSelector   - Needs to run faster than the
|                                           clk_correlator by a factor of
|                                           a refrence length (31x or 15x)
| Output:              enable_demodulator - Enables the demod when peak
|                                           detected
|                      enable_symbol_clk  - Enable the symbol clk
|                      addr               - Address of max peak location 
|                                           in buffer
|                      index_reg          - location of peak descovery
| Additional comments: Largely based on Benson, B. "Design of a Low-Cost 
|                      Underwater Acoustic Modem for Short-Range Sensor 
|                      Networks", UC San Diego, 2010
\***********************************************************************/

module bit_synchronizer (
	input wire signed  [1:0] sig_in,
	input wire               clk_correlator,
	input wire               clk_signSelector,
	output wire              enable_demodulator,
	output wire              symbol_clk,
	output wire        [7:0] addr
);
//reg [1:0] shiftReg [0:30];

initial begin

end

reg [5:0] shiftIndex = 6'b0;
// Shift register for correlation
always @ (posedge clk_correlator) begin

end

always @ (negedge clk_correlator) begin

end


//=======================================================
//  Reference Correlator
//=======================================================
// Correlate the incoming signal with the refrence code
wire [7:0] ref_corr_result;
refrence_correlator ref_corr(
	.sig_in           (sig_in),
	.clk_correlator   (clk_correlator),
	.clk_signSelector (clk_signSelector),
	.signal_out       (ref_corr_result)
);

//=======================================================
//  Orthogonal Correlator
//=======================================================
// Correlate the incoming signal with its orthogonal signal
wire [7:0] org_corr_result;
wire rst;
orthogonal_correlator org_corr(
	.sig_in           (sig_in),
	.clk_correlator   (clk_correlator),
	.clk_signSelector (clk_signSelector),
	.signal_out       (org_corr_result),
	.reset            (rst)
);

//=======================================================
//  Square Sum
//=======================================================
// Square and then sum the SigIn*orthogonal
wire [15:0] threshold;
square_sum sqSum(
	.sig_in     (org_corr_result),
	.sample_clk (clk_correlator),
	.reset      (rst),
	.square     (threshold)
);

//=======================================================
//  Find Index
//=======================================================
wire enable_symbol_clk;
findIndex fInd(
	.clk                 (clk_correlator),
	.ref_corr            (ref_corr_result),
	.threshold           (threshold),
	.enable_demodulator  (enable_demodulator),
	.enable_symbol_clk   (enable_symbol_clk),
	.symbol_clk          (symbol_clk),
	.index               (index_reg),
	.addr                (addr)
);


endmodule
