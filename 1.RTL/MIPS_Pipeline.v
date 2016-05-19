`include "InstructionFetch.v"
`include "InstructionDecode.v"
`include "Execution.v"
`include "DataMemory.v"
`timescale 1 ns/10 ps
module MIPS_Pipeline(clk,
					rst,
					//cen,
					//stall,
					
					//I cache interface
					ICACHE_addr,
					ICACHE_rdata,
					ICACHE_ren,
					ICACHE_wen,
					ICACHE_wdata,
					ICACHE_stall,
				
					//D cache interface
					DCACHE_addr,
					DCACHE_rdata,
					DCACHE_ren,
					DCACHE_wen,
					DCACHE_wdata,
					DCACHE_stall
					
					);

	input 			clk;
	input 			rst;
	//input			cen;
	//input			stall;
	
	//I cache interface
	output	[31:0]	ICACHE_addr;
	input	[31:0]	ICACHE_rdata;
	output			ICACHE_ren;
	output			ICACHE_wen;
	output	[31:0]	ICACHE_wdata;
	input			ICACHE_stall;
	
	//D cache interface
	output	[31:0]	DCACHE_addr;
	input	[31:0]	DCACHE_rdata;
	output			DCACHE_ren;
	output			DCACHE_wen;
	output	[31:0]	DCACHE_wdata;
	input			DCACHE_stall;
	
//====reg/wire declaration=====//
	wire	[31:0]	PCadd4;
	wire	[31:0]	Instruction;
	wire	[31:0]	PCbranched;
	reg		[31:0]	PCJump_JRChecked;
	wire	[31:0]	ReadData1;
	wire	[31:0]	ReadData2;
	wire	[31:0]	next_ReadData1;
	wire	[31:0]	Immediate_SE;
	wire	[31:0]	next_ALUresult;
	wire 	[31:0]	ALUresult;
	wire	[31:0]	MEMWriteData;
	wire	[31:0]	Buf_ALUresult;
	wire	[31:0]	MemoryData;
	reg		[31:0]	WriteData;
	reg		[31:0]	WBData;
	reg				needStall;
	//Cache
	wire	[31:0]	IF_PC;
	//Addr Register
	wire	[4:0]	ID_EX_RegisterRd;
	wire	[4:0]	ID_EX_RegisterRs;
	wire	[4:0]	ID_EX_RegisterRt;
	wire	[4:0]	EX_MEM_RegisterRd;
	wire	[4:0]	MEM_WB_RegisterRd;
	//Stationary Control Signal
	wire	[1:0]	ID_EX_WBControl;
	wire	[2:0]	ID_EX_MEMControl;
	wire	[6:0]	ID_EX_EXControl;
	wire	[1:0]	EX_MEM_WBControl;
	wire	[2:0]	EX_MEM_MEMControl;
	wire	[1:0]	MEM_WB_WBControl;
	//control unit
	reg				RegDst;
	reg				Jump;
	reg				Branch;
	reg				MemRead;//MEM
	reg 			MemtoReg;//WB
	reg				MemWrite;//MEM
	reg		[2:0]	ALUOp;//EXE
	reg 			ALUSrc;//EXE
	reg 			RegWrite;
	reg				IF_Flush;
	//forwarding unit
	reg		[1:0]	ForwardA;
	reg		[1:0]	ForwardB;
	reg		[1:0]	BrForwardA;
	reg		[1:0]	BrForwardB;
	//hazard detection unit
	reg				PCWrite;
	reg				IF_ID_Write;
	reg				Bubble;
	wire			PCBuffer_valid;
	//earlier branch prediction
	wire			equal;
	//Branch prediction unit
	wire			PredictMiss;
	wire			BranchTaken;
	//I Cache Interface
	assign ICACHE_wdata = 0;
	assign ICACHE_wen = 0;
	assign ICACHE_ren = 1;
	assign ICACHE_addr = IF_PC;
	//D Caceh Interface
	assign DCACHE_addr = ALUresult;
	assign DCACHE_wdata = MEMWriteData;
	assign DCACHE_wen = (EX_MEM_MEMControl[1:0]==2'b01);
	assign DCACHE_ren = (EX_MEM_MEMControl[1:0]==2'b10);
	
	
//====submodule=====//
InstructionFetch 	IF(	//global signal
						.clk(clk),
						.rst(rst),
						.stall(needStall),
						//ID interface
						.PCWrite(PCWrite),
						.PCJumpJRorBranch(PCJump_JRChecked),
						.IF_ID_Write(IF_ID_Write),
						.IF_Flush(IF_Flush),
						.PCadd4(PCadd4),
						.Instruction(Instruction),
						//I Cache Interface
						.PC(IF_PC),
						.read_Instruction(ICACHE_rdata),
						//Branch Prediction
						.PredictMiss(PredictMiss),
						.BranchTaken(BranchTaken),
						//JR Hazard
						.PCBuffer_valid(PCBuffer_valid)
						);
InstructionDecode 	ID(	//global signal
						.clk(clk),
						.rst(rst),
						.stall(needStall),
						//IF interface
						.PCadd4(PCadd4),
						.Instruction(Instruction),
						.PCbranched(PCbranched),
						//WB interface
						.Reg_W(MEM_WB_RegisterRd),
						.WriteData(WBData),
						//EX interface
						.WB(ID_EX_WBControl),
						.MEM(ID_EX_MEMControl),
						.EX(ID_EX_EXControl),
						.RData1(ReadData1),
						.RData2(ReadData2),
						.next_RData1(next_ReadData1),
						.Immediate_SE(Immediate_SE),
						.RegisterRd(ID_EX_RegisterRd),
						.RegisterRs(ID_EX_RegisterRs),
						.RegisterRt(ID_EX_RegisterRt),
						//MEM interface
						.MEM_RegWrite(MEM_WB_WBControl[1]),
						//control unit
						.RegDst(RegDst),
						.Jump(Jump),
						.Branch(Branch),
						.MemRead(MemRead),//MEM
						.MemtoReg(MemtoReg),//WB
						.MemWrite(MemWrite),//MEM
						.ALUOp(ALUOp),//EXE
						.ALUSrc(ALUSrc),//EXE
						.RegWrite(RegWrite),
						//hazard detection unit
						.Bubble(Bubble),
						.PCBuffer_valid(PCBuffer_valid),
						//earlier branch prediction
						.equal(equal),
						.EX_RegWriteData(next_ALUresult),
						.MEM_RegWriteData(ALUresult),
						.BrForwardA(BrForwardA),
						.BrForwardB(BrForwardB),
						//Branch Prediction
						.PredictMiss(PredictMiss),
						.BranchTaken(BranchTaken)
						);
Execution			EX(//global signal
						.clk(clk),
						.rst(rst),
						.stall(needStall),
						//ID interface
						.ID_WB(ID_EX_WBControl),
						.ID_MEM(ID_EX_MEMControl),
						.ID_EX(ID_EX_EXControl),
						.RData1(ReadData1),
						.RData2(ReadData2),
						.Immediate_SE(Immediate_SE),
						.ID_RegisterRt(ID_EX_RegisterRt),
						.ID_RegisterRd(ID_EX_RegisterRd),
						//MEM interface
						.WB(EX_MEM_WBControl),
						.MEM(EX_MEM_MEMControl),
						.ALUresult(ALUresult),
						.MEMWriteData(MEMWriteData),
						.RegisterRd(EX_MEM_RegisterRd),
						.next_ALUresult(next_ALUresult),
						//WB interface
						.WBData(WBData),
						//Forwarding unit Interface
						.ForwardA(ForwardA),
						.ForwardB(ForwardB)
						);
DataMemory			DMEM(//global signal
						.clk(clk),
						.rst(rst),
						.stall(needStall),
						//EX interface
						.EX_WB(EX_MEM_WBControl),
						.EX_MEM(EX_MEM_MEMControl),
						.EX_ALUresult(ALUresult),
						.EX_RegisterRd(EX_MEM_RegisterRd),
						.MEMWriteData(MEMWriteData),
						//WB interface
						.WB(MEM_WB_WBControl),
						.MemoryData(MemoryData),
						.ALUresult(Buf_ALUresult),
						.RegisterRd(MEM_WB_RegisterRd),
						//D Cache Interface
						.read_MemoryData(DCACHE_rdata)
						);

always @(*) begin
	needStall = /*stall |*/ ICACHE_stall | DCACHE_stall;
	PCJump_JRChecked = ({ALUOp,Instruction[5:0]}==9'b010001000) ? next_ReadData1 : PCbranched;//PC address JRChecked
	//Write Back Mux
	WBData = MEM_WB_WBControl[0] ? MemoryData : Buf_ALUresult;
//=========Control unit===============//
	if(Instruction==0)
		{RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b10000_001_000;//NOP
	else begin
		case(Instruction[31:26])
			6'b000000 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b10000_010_001;//R-format
			6'b000010 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b01000_001_000;//j
			6'b000011 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b01000_001_000;//jal 
			6'b000100 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00100_001_000;//beq
			6'b001000 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_100_011;//addi
			6'b001010 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_011_011;//slti
			6'b001100 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_101_011;//andi
			6'b001101 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_110_011;//ori
			6'b001110 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_111_011;//xori
			6'b100011 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00011_000_011;//lw
			6'b101011 : {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_000_110;//sw
			default: {RegDst,Jump,Branch,MemRead,MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite} = 11'b00000_001_000;
		endcase
	end
//=========ALU Forwarding unit============//
	if(EX_MEM_WBControl[1]&&(EX_MEM_RegisterRd!=0)) begin
		if((EX_MEM_RegisterRd==ID_EX_RegisterRs))
			ForwardA = 2'b10;
		else if(MEM_WB_WBControl[1]&&(MEM_WB_RegisterRd!=0)&&(MEM_WB_RegisterRd==ID_EX_RegisterRs))
			ForwardA = 2'b01;
		else
			ForwardA = 2'b00;
		if((EX_MEM_RegisterRd==ID_EX_RegisterRt))
			ForwardB = 2'b10;
		else if(MEM_WB_WBControl[1]&&(MEM_WB_RegisterRd!=0)&&(MEM_WB_RegisterRd==ID_EX_RegisterRt))
			ForwardB = 2'b01;
		else
			ForwardB = 2'b00;
	end
	else if(MEM_WB_WBControl[1]&&(MEM_WB_RegisterRd!=0)) begin
		if((MEM_WB_RegisterRd==ID_EX_RegisterRs))
			ForwardA = 2'b01;
		else
			ForwardA = 2'b00;
		if((MEM_WB_RegisterRd==ID_EX_RegisterRt))
			ForwardB = 2'b01;
		else
			ForwardB = 2'b00;
	end
	else begin
		ForwardA = 2'b00;
		ForwardB = 2'b00;
	end
//=========Branch Forwarding unit===========//
	if(Branch) begin
		if((ID_EX_EXControl[4]?ID_EX_RegisterRd:ID_EX_RegisterRt)==Instruction[25:21]&&ID_EX_WBControl[1])
			BrForwardA = 2'b01;
		else if(EX_MEM_RegisterRd==Instruction[25:21]&&EX_MEM_WBControl[1])
			BrForwardA = 2'b10;
		else if(MEM_WB_RegisterRd==Instruction[25:21]&&MEM_WB_WBControl[1])
			BrForwardA = 2'b11;
		else
			BrForwardA = 2'b00;
		if((ID_EX_EXControl[4]?ID_EX_RegisterRd:ID_EX_RegisterRt)==Instruction[20:16]&&ID_EX_WBControl[1])
			BrForwardB = 2'b01;
		else if(EX_MEM_RegisterRd==Instruction[20:16]&&EX_MEM_WBControl[1])
			BrForwardB = 2'b10;
		else if(MEM_WB_RegisterRd==Instruction[20:16]&&MEM_WB_WBControl[1])
			BrForwardB = 2'b11;
		else
			BrForwardB = 2'b00;
	end
	else begin
		BrForwardA = 2'b00;
		BrForwardB = 2'b00;
	end
//=========Hazard Detection unit============//
	if(ID_EX_MEMControl[1]&&((ID_EX_RegisterRt==Instruction[25:21])||(ID_EX_RegisterRt==Instruction[20:16]))) begin//insert bubble
		Bubble = 1;
		PCWrite	= 1;
		IF_ID_Write = 1;
	end
	/*else if(({ALUOp,Instruction[5:0]}==9'b010001000)&&PCBuffer_valid) begin
		Bubble = 1;
		PCWrite	= 0;
		IF_ID_Write = 0;
	end*/
	else begin
		Bubble = 0;
		PCWrite	= 0;
		IF_ID_Write = 0;
	end	
//Branch wrong guess flush
	IF_Flush = /*(equal&Branch)*/ PredictMiss  /*| Jump |(Instruction[31:26]==6'd3)*/ |({ALUOp,Instruction[5:0]}==9'b010001000);//branch j jal jr
end

endmodule
