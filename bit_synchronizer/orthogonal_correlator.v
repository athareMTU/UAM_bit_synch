/***********************************************************************\
| Module:              orthogonal_correlator
| Author:              Alex Hare
| Last Updated:        03/20/2021
| Function:            Preforms a correlation calculation between the 
|                      incoming signal and the orthogonal signal
|
|                      The Codes here and in the reference correlation
|                      are Gold Codes. Codes that contain 1s and -1s, and
|                      are 2^(n)-1 length, i.e. 31, or 15
|                      
|                      The signal be sampled four times and will be sent 
|                      to a shift register, then the shift register will 
|                      be sent to the Sign Selector module which will preform
|                      the correlation calculation.
|                      
|                      This was initially designed with a Gold Code length
|                      of 31. This didn't work with our clocks, so it was reduced
|                      to 15. 
|                      
| Inputs:              sig_in      : The incoming signal
|                   clk_correlator : Clk to control the correlation
|                 clk_signSelector : clk to run the correlation calculation
|                      
| Output:               signal_out : The result of the correlation
|                            reset : Used to reset the threshold calculation
|
| Additional comments: Largely based on Benson, B. "Design of a Low-Cost 
|                      Underwater Acoustic Modem for Short-Range Sensor 
|                      Networks", UC San Diego, 2010
\***********************************************************************/
module orthogonal_correlator(
	input wire signed [1:0] sig_in,
	input wire clk_correlator,
	input wire clk_signSelector,
	output reg signed [7:0] signal_out,
	output reg reset
);
reg [7:0] cnt; // Used for going through the samples
reg [1:0] rndRobinCnt;
reg [7:0] orthogonalCode [0:14];
reg signed [1:0] shiftReg [0:59];
reg start;
//reg reset;

initial begin
	cnt               = 4'b0;
	start             = 1'b0;
	// Because the shift register takes the numbers in
	// the front, so in order match the reference code
	// is also reversed
	
	// 31 length reverse order: 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 -1 -1 1 1 -1 1 1 -1 1 1 1 1 1 -1 1
	// 51 length -1 1 1 -1 -1 -1 -1 1 -1 1 -1 1 1 1 -1
	orthogonalCode[0]  = -8'd1;
	orthogonalCode[1]  = 8'd1;
	orthogonalCode[2]  = 8'd1;
	orthogonalCode[3]  = 8'd1;
	orthogonalCode[4]  = -8'd1;
	orthogonalCode[5]  = 8'd1;
	orthogonalCode[6]  = -8'd1;
	orthogonalCode[7]  = 8'd1;
	orthogonalCode[8]  = -8'd1;
	orthogonalCode[9]  = -8'd1;
	orthogonalCode[10] = -8'd1;
	orthogonalCode[11] = -8'd1;
	orthogonalCode[12] = 8'd1;
	orthogonalCode[13] = 8'd1;
	orthogonalCode[14] = -8'd1;
//	orthogonalCode[15] = -8'd1;
//	orthogonalCode[16] = -8'd1;
//	orthogonalCode[17] = -8'd1;
//	orthogonalCode[18] = 8'd1;
//	orthogonalCode[19] = 8'd1;
//	orthogonalCode[20] = -8'd1;
//	orthogonalCode[21] = 8'd1;
//	orthogonalCode[22] = 8'd1;
//	orthogonalCode[23] = -8'd1;
//	orthogonalCode[24] = 8'd1;
//	orthogonalCode[25] = 8'd1;
//	orthogonalCode[26] = 8'd1;
//	orthogonalCode[27] = 8'd1;
//	orthogonalCode[28] = 8'd1;
//	orthogonalCode[29] = -8'd1;
//	orthogonalCode[30] = 8'd1;
	
	shiftReg[0] = 8'd0;
	shiftReg[1] = 8'd0;
	shiftReg[2] = 8'd0;
	shiftReg[3] = 8'd0;
	shiftReg[4] = 8'd0;
	shiftReg[5] = 8'd0;
	shiftReg[6] = 8'd0;
	shiftReg[7] = 8'd0;
	shiftReg[8] = 8'd0;
	shiftReg[9] = 8'd0;
	shiftReg[10] = 8'd0;
	shiftReg[11] = 8'd0;
	shiftReg[12] = 8'd0;
	shiftReg[13] = 8'd0;
	shiftReg[14] = 8'd0;
	shiftReg[15] = 8'd0;
	shiftReg[16] = 8'd0;
	shiftReg[17] = 8'd0;
	shiftReg[18] = 8'd0;
	shiftReg[19] = 8'd0;
	shiftReg[20] = 8'd0;
	shiftReg[21] = 8'd0;
	shiftReg[22] = 8'd0;
	shiftReg[23] = 8'd0;
	shiftReg[24] = 8'd0;
	shiftReg[25] = 8'd0;
	shiftReg[26] = 8'd0;
	shiftReg[27] = 8'd0;
	shiftReg[28] = 8'd0;
	shiftReg[29] = 8'd0;
	shiftReg[30] = 8'd0;
	shiftReg[31] = 8'd0;
	shiftReg[32] = 8'd0;
	shiftReg[33] = 8'd0;
	shiftReg[34] = 8'd0;
	shiftReg[35] = 8'd0;
	shiftReg[36] = 8'd0;
	shiftReg[37] = 8'd0;
	shiftReg[38] = 8'd0;
	shiftReg[39] = 8'd0;
	shiftReg[40] = 8'd0;
	shiftReg[41] = 8'd0;
	shiftReg[42] = 8'd0;
	shiftReg[43] = 8'd0;
	shiftReg[44] = 8'd0;
	shiftReg[45] = 8'd0;
	shiftReg[46] = 8'd0;
	shiftReg[47] = 8'd0;
	shiftReg[48] = 8'd0;
	shiftReg[49] = 8'd0;
	shiftReg[50] = 8'd0;
	shiftReg[51] = 8'd0;
	shiftReg[52] = 8'd0;
	shiftReg[53] = 8'd0;
	shiftReg[54] = 8'd0;
	shiftReg[55] = 8'd0;
	shiftReg[56] = 8'd0;
	shiftReg[57] = 8'd0;
	shiftReg[58] = 8'd0;
	shiftReg[59] = 8'd0;
end

wire signed [7:0] result[0:3];
reg sigSelResult [0:3];

// Parallel Computation of the four sample sections
// Section 1: 0-14
// Section 2: 15-29
// Section 3: 30-44
// Section 4: 45-59
sign_selector signSel(
	.in  (shiftReg[cnt]),
	.ref (orthogonalCode[cnt]),
	.clk (clk_signSelector),
	.rst (reset),
	.stored (result[0])
);

sign_selector signSel2(
	.in  (shiftReg[(cnt+8'd15)]),
	.ref (orthogonalCode[cnt]),
	.clk (clk_signSelector),
	.rst (reset),
	.stored (result[1])
);

sign_selector signSel3(
	.in  (shiftReg[(cnt+8'd30)]),
	.ref (orthogonalCode[cnt]),
	.clk (clk_signSelector),
	.rst (reset),
	.stored (result[2])
);

sign_selector signSel4(
	.in  (shiftReg[(cnt+8'd45)]),
	.ref (orthogonalCode[cnt]),
	.clk (clk_signSelector),
	.rst (reset),
	.stored (result[3])
);

always @ (posedge clk_correlator) begin
	start        <= 1'b1;

	// Round robin inserting the different samples to
	// Shift register
	if( rndRobinCnt == 2'd0 ) begin
		// Sample 1
		shiftReg[0]   <= sig_in;
		shiftReg[1]  <= shiftReg[0];
		shiftReg[2]  <= shiftReg[1];
		shiftReg[3]  <= shiftReg[2];
		shiftReg[4]  <= shiftReg[3];
		shiftReg[5]  <= shiftReg[4];
		shiftReg[6]  <= shiftReg[5];
		shiftReg[7]  <= shiftReg[6];
		shiftReg[8]  <= shiftReg[7];
		shiftReg[9]  <= shiftReg[8];
		shiftReg[10] <= shiftReg[9];
		shiftReg[11] <= shiftReg[10];
		shiftReg[12] <= shiftReg[11];
		shiftReg[13] <= shiftReg[12];
		shiftReg[14] <= shiftReg[13];
	end
	else if( rndRobinCnt == 2'd1 ) begin
		// Sample 2
		shiftReg[15]  <= sig_in;
		shiftReg[16] <= shiftReg[15];
		shiftReg[17] <= shiftReg[16];
		shiftReg[18] <= shiftReg[17];
		shiftReg[19] <= shiftReg[18];
		shiftReg[20] <= shiftReg[19];
		shiftReg[21] <= shiftReg[20];
		shiftReg[22] <= shiftReg[21];
		shiftReg[23] <= shiftReg[22];
		shiftReg[24] <= shiftReg[23];
		shiftReg[25] <= shiftReg[24];
		shiftReg[26] <= shiftReg[25];
		shiftReg[27] <= shiftReg[26];
		shiftReg[28] <= shiftReg[27];
		shiftReg[29] <= shiftReg[28];
	end
	else if( rndRobinCnt == 2'd2 ) begin
		// Sample 3
		shiftReg[30]  <= sig_in;
		shiftReg[31] <= shiftReg[30];
		shiftReg[32] <= shiftReg[31];
		shiftReg[33] <= shiftReg[32];
		shiftReg[34] <= shiftReg[33];
		shiftReg[35] <= shiftReg[34];
		shiftReg[36] <= shiftReg[35];
		shiftReg[37] <= shiftReg[36];
		shiftReg[38] <= shiftReg[37];
		shiftReg[39] <= shiftReg[38];
		shiftReg[40] <= shiftReg[39];
		shiftReg[41] <= shiftReg[40];
		shiftReg[42] <= shiftReg[41];
		shiftReg[43] <= shiftReg[42];
		shiftReg[44] <= shiftReg[43];
	end
	else if( rndRobinCnt == 2'd3 ) begin
		// Sample 4
		shiftReg[45]  <= sig_in;
		shiftReg[46] <= shiftReg[45];
		shiftReg[47] <= shiftReg[46];
		shiftReg[48] <= shiftReg[47];
		shiftReg[49] <= shiftReg[48];
		shiftReg[50] <= shiftReg[49];
		shiftReg[51] <= shiftReg[50];
		shiftReg[52] <= shiftReg[51];
		shiftReg[53] <= shiftReg[52];
		shiftReg[54] <= shiftReg[53];
		shiftReg[55] <= shiftReg[54];
		shiftReg[56] <= shiftReg[55];
		shiftReg[57] <= shiftReg[56];
		shiftReg[58] <= shiftReg[57];
		shiftReg[59] <= shiftReg[58];
	end	
	signal_out <= result[0] + result[1] + result[2] + result[3];
end

always @ (negedge clk_correlator) begin
	if(start == 1'b1) begin
		if(rndRobinCnt < 2'd3) begin
			rndRobinCnt <= rndRobinCnt + 2'b1;
		end else begin
			rndRobinCnt <= 2'b0;
		end
	end
end

always @ (posedge clk_signSelector) begin
	// This will have to send the 31 bits to the signal selector in the
	// amount of time that it will take one bit to enter the shift register.
	// This way all 31 bits must be calculated before a new set of 31 bits
	// arrive
	//signal_out <= result[0] + result[1] + result[2] + result[3];
end

always @ (negedge clk_signSelector) begin
	// This will have to send the 31 bits to the signal selector in the
	// amount of time that it will take one bit to enter the shift register.
	// This way all 31 bits must be calculated before a new set of 31 bits
	// arrive
	if( start == 1'b1) begin
		if(cnt < 8'd14) begin
			reset <= 1'b0;
			cnt   <= cnt + 4'b1; 
		end else begin
			cnt   <= 4'b0;
			reset <= 1'b1;
			
		end
	end
end


endmodule
