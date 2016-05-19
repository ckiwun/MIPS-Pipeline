`timescale 1 ns/10 ps
module InstructionFetch(//global signal
						clk,
						rst,
						stall,
						//ID interface
						PCWrite,
						PCJumpJRorBranch,
						IF_ID_Write,
						IF_Flush,
						PCadd4,
						Instruction,
						//I Cache interface
						PC,
						read_Instruction,
						//Branch Prediction
						PredictMiss,
						BranchTaken,
						PCBuffer_valid
						);
	input			clk;
	input			rst;
	input			stall;
	input			PCWrite;
	input	[31:0]	PCJumpJRorBranch;
	input			IF_ID_Write;
	input			IF_Flush;
	output	[31:0]	PCadd4;
	output	[31:0]	Instruction;
	output	[31:0]	PC;
	input	[31:0]	read_Instruction;
	input			PredictMiss;
	output			BranchTaken;
	input			PCBuffer_valid;
//====reg/wire declaration========//
	reg		[31:0]	PCin;
	reg		[31:0]	PCadd4;
	reg		[31:0]	next_PCadd4;
	reg		[31:0]	PC;
	reg		[31:0]	next_PC;
	reg		[31:0]	Instruction;
	reg		[31:0]	next_Instruction;
	reg				BranchTaken;
	reg				next_BranchTaken;
	//branch prediction unit
	reg		[31:0]	PCBrPredict;
	reg		[31:0]	PCRevised;
	reg		[31:0]	PCJumpEarly;
	reg		[1:0]	state;
	reg		[1:0]	next_state;

	parameter		Taken = 2'b00;
	parameter		Taken_NotTaken = 2'b01;
	parameter		NotTaken_Taken = 2'b10;
	parameter		NotTaken = 2'b11;
always @(next_Instruction[31:26] or next_BranchTaken or next_PCadd4 or read_Instruction[15:0] or PCBrPredict or PCJumpJRorBranch or PredictMiss or IF_Flush or PCJumpEarly or PCRevised) begin
	PCBrPredict = (next_Instruction[31:26]==6'b000100)&next_BranchTaken ? next_PCadd4 + ({{16{read_Instruction[15]}},read_Instruction[15:0]}<<2) : next_PCadd4;
	PCRevised = PredictMiss ? PCJumpJRorBranch : PCBrPredict;
	PCJumpEarly = {next_PCadd4[31:28],(read_Instruction[25:0]<<2)};
	PCin = (IF_Flush) ? PCJumpJRorBranch : ((next_Instruction[31:27]==5'b00001)?PCJumpEarly:PCRevised);
end
	
always @(*) begin
	if(stall|PCBuffer_valid&{read_Instruction[31:26],read_Instruction[5:0]}==12'b000000001000) begin
		next_PCadd4 = PCadd4;
		next_PC = PC;
		next_Instruction = Instruction;
		next_BranchTaken = BranchTaken;
	end
	else begin
		next_PCadd4 = PC + 4;
		if(~PCWrite)
			next_PC = PCin;
		else
			next_PC = PC;
		/*if(stall)
			next_Instruction = Instruction;
		else */if(~IF_ID_Write)
			next_Instruction = read_Instruction;
		else
			next_Instruction = Instruction;
		if((Instruction[31:26]==6'b000100)) begin//if Branch
			//always guess taken
			//next_BranchTaken = 1;
			//always guess nottaken
			//next_BranchTaken = 0;
			//1-bit prediction 
			/*case(state)
				Taken:
					begin
						next_BranchTaken = 1;
						if(PredictMiss)
							next_state = NotTaken;
						else
							next_state = Taken;
					end
				NotTaken:
					begin
						next_BranchTaken = 0;
						if(PredictMiss)
							next_state = Taken;
						else
							next_state = NotTaken;
					end
				default:
					begin
						next_BranchTaken = BranchTaken;
						next_state = state;
					end
			endcase*/
			//2-bit prediction Scheme 1
			/*case(state)
				Taken:
					begin
						next_BranchTaken = 1;
						if(PredictMiss)
							next_state = Taken_NotTaken;
						else
							next_state = Taken;
					end
				Taken_NotTaken:
					begin
						next_BranchTaken = 1;
						if(PredictMiss)
							next_state = NotTaken_Taken;
						else
							next_state = Taken;
					end
				NotTaken_Taken:
					begin
						next_BranchTaken = 0;
						if(PredictMiss)
							next_state = Taken_NotTaken;
						else
							next_state = NotTaken;
					end
				NotTaken:
					begin
						next_BranchTaken = 0;
						if(PredictMiss)
							next_state = NotTaken_Taken;
						else
							next_state = NotTaken;
					end
			endcase*/
			//2-bit prediction Scheme 2
			case(state)
				Taken:
					begin
						next_BranchTaken = 1;
						if(PredictMiss)
							next_state = Taken_NotTaken;
						else
							next_state = Taken;
					end
				Taken_NotTaken:
					begin
						next_BranchTaken = 1;
						if(PredictMiss)
							next_state = NotTaken;
						else
							next_state = Taken;
					end
				NotTaken_Taken:
					begin
						next_BranchTaken = 0;
						if(PredictMiss)
							next_state = Taken;
						else
							next_state = NotTaken;
					end
				NotTaken:
					begin
						next_BranchTaken = 0;
						if(PredictMiss)
							next_state = NotTaken_Taken;
						else
							next_state = NotTaken;
					end
			endcase
		end
		else begin
			next_BranchTaken = BranchTaken;
			next_state = state;
		end
	end
end
	
always @(posedge clk or negedge rst) begin
	if(!rst) begin
		PCadd4	<=	0;
		Instruction	<=	0;
		PC	<=	0;
		BranchTaken	<=	0;
		state	<=	NotTaken;
	end
	else if(IF_Flush&&(!stall)) begin
		PCadd4	<=	next_PCadd4;
		Instruction	<=	0;
		PC	<=	next_PC;
		BranchTaken	<= next_BranchTaken;
		state	<=	next_state;
	end
	else if(PredictMiss&&(!stall)) begin
		PCadd4	<=	next_PCadd4;
		Instruction	<=	0;
		PC	<=	next_PC;
		BranchTaken	<= next_BranchTaken;
		state	<=	next_state;
	end
	else begin
		PCadd4	<=	next_PCadd4;
		Instruction	<=	next_Instruction;
		PC	<= next_PC;
		BranchTaken	<= next_BranchTaken;
		state	<=	next_state;
	end
end

endmodule
