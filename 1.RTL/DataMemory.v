`timescale 1 ns/10 ps
module DataMemory(	//global signal
					clk,
					rst,
					stall,
					//EX interface
					EX_WB,
					EX_MEM,
					EX_ALUresult,
					EX_RegisterRd,
					MEMWriteData,
					//WB interface
					WB,
					MemoryData,
					ALUresult,
					RegisterRd,
					//D cache interface
					read_MemoryData
					);
	input			clk;
	input			rst;
	input			stall;
	input	[1:0]	EX_WB;
	input	[2:0]	EX_MEM;
	input	[31:0]	EX_ALUresult;
	input	[4:0]	EX_RegisterRd;
	input	[31:0]	MEMWriteData;
	output	[1:0]	WB;
	output	[31:0]	MemoryData;
	output	[31:0]	ALUresult;
	output	[4:0]	RegisterRd;
	input	[31:0]	read_MemoryData;
	
//========reg/wire declaration==========//
	reg	[1:0]	WB;
	reg	[1:0]	next_WB;
	reg	[31:0]	MemoryData;
	reg	[31:0]	next_MemoryData;
	reg	[31:0]	ALUresult;
	reg	[31:0]	next_ALUresult;
	reg	[4:0]	RegisterRd;
	reg	[4:0]	next_RegisterRd;
	
always @(*) begin
	if(stall) begin
		next_MemoryData = 	MemoryData;
		next_WB = WB;
		next_ALUresult = ALUresult;
		next_RegisterRd = RegisterRd;
	end
	else begin
		next_MemoryData = 	read_MemoryData;
		next_WB = EX_WB;
		next_ALUresult = EX_ALUresult;
		next_RegisterRd = EX_RegisterRd;
	end
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		WB	<=	0;
		MemoryData	<=	0;
		ALUresult	<=	0;
		RegisterRd	<=	0;
	end
	else begin
		WB	<=	next_WB;
		MemoryData	<=	next_MemoryData;
		ALUresult	<=	next_ALUresult;
		RegisterRd	<=	next_RegisterRd;
	end
end
endmodule
