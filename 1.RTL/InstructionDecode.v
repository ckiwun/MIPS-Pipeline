`timescale 1 ns/10 ps
module InstructionDecode(//global signal
						clk,
						rst,
						stall,
						//IF interface
						PCadd4,
						Instruction,
						PCbranched,
						//WB interface
						Reg_W,
						WriteData,
						//EX interface
						WB,
						MEM,
						EX,
						RData1,
						RData2,
						next_RData1,
						Immediate_SE,
						RegisterRd,
						RegisterRs,
						RegisterRt,
						//MEM interface
						MEM_RegWrite,
						//control unit
						RegDst,
						Jump,
						Branch,
						MemRead,//MEM
						MemtoReg,//WB
						MemWrite,//MEM
						ALUOp,//EXE
						ALUSrc,//EXE
						RegWrite,
						//hazard detection unit
						Bubble,
						PCBuffer_valid,
						//earlier branch prediction
						equal,
						EX_RegWriteData,
						MEM_RegWriteData,
						BrForwardA,
						BrForwardB,
						//branch prediction
						PredictMiss,
						BranchTaken
						);
	input			clk;
	input			rst;
	input			stall;
	input	[31:0]	PCadd4;
	input	[31:0]	Instruction;
	output	[31:0]	PCbranched;
	input	[4:0]	Reg_W;
	input	[31:0]	WriteData;
	output	[1:0]	WB;
	output	[2:0]	MEM;
	output	[6:0]	EX;
	output	[31:0]	RData1;
	output	[31:0]	RData2;
	output	[31:0]	next_RData1;
	output	[31:0]	Immediate_SE;
	output	[4:0]	RegisterRd;
	output	[4:0]	RegisterRs;
	output	[4:0]	RegisterRt;
	input			MEM_RegWrite;
	input			RegDst;
	input			Jump;
	input			Branch;
	input			MemRead;//MEM
	input          	MemtoReg;//WB
	input         	MemWrite;//MEM
	input   [2:0]	ALUOp;//EXE
	input           ALUSrc;//EXE
	input			RegWrite;
	input			Bubble;
	output			PCBuffer_valid;
	output			equal;
	input	[31:0]	EX_RegWriteData;
	input	[31:0]	MEM_RegWriteData;
	input	[1:0]	BrForwardA;
	input	[1:0]	BrForwardB;
	output			PredictMiss;
	input			BranchTaken;
//========reg/wire declaration=============//
	reg	[1:0]	WB;
	reg	[1:0]	next_WB;
	reg	[2:0]	MEM;
	reg	[2:0]	next_MEM;
	reg	[6:0]	EX;
	reg	[6:0]	next_EX;
	reg	[31:0]	RData1;
	reg	[31:0]	next_RData1;
	reg	[31:0]	RData2;
	reg	[31:0]	next_RData2;
	reg	[4:0]	RegisterRd;
	reg	[4:0]	next_RegisterRd;
	reg	[4:0]	RegisterRs;
	reg	[4:0]	next_RegisterRs;
	reg	[4:0]	RegisterRt;
	reg	[4:0]	next_RegisterRt;
	reg	[31:0]	PCBuffer;
	reg	[31:0]	next_PCBuffer;
	reg			PCBuffer_valid;
	reg			next_PCBuffer_valid;
	reg	[31:0]	Immediate_SE;
	reg	[31:0]	next_Immediate_SE;
	
	reg			Shift;
	reg			equal;
	reg	[31:0]	earlyRD1;
	reg	[31:0]	earlyRD2;
	//branch prediction
	reg			BranchCtrl;
	reg			PredictMiss;
	reg	[31:0]	BranchAddr_SE;
	//addr
	reg	[31:0]	JumpAddr;
	reg	[31:0]	PCbranched;
	//register file
	reg	[4:0]	Reg_R1;
	reg	[4:0]	Reg_R2;
	reg	[31:0]	regfile			[31:0];
	reg	[31:0]	next_regfile	[31:0];
	integer	i;
	

always @(BrForwardA or BrForwardB or next_RData1 or next_RData2 or EX_RegWriteData or MEM_RegWriteData or WriteData) begin
	case(BrForwardA)
		2'b00: earlyRD1 = next_RData1;
		2'b01: earlyRD1 = EX_RegWriteData;
		2'b10: earlyRD1 = MEM_RegWriteData;
		2'b11: earlyRD1 = WriteData;
	endcase
	case(BrForwardB)
		2'b00: earlyRD2 = next_RData2;
		2'b01: earlyRD2 = EX_RegWriteData;
		2'b10: earlyRD2 = MEM_RegWriteData;
		2'b11: earlyRD2 = WriteData;
	endcase
end	
always @(BranchCtrl or PCadd4 or next_Immediate_SE) begin
//Immediate address
	PCbranched	=	BranchCtrl	? PCadd4 + (next_Immediate_SE<<2) : PCadd4;
end
always @(*) begin
	Shift = ({ALUOp[2:0],Instruction[5:3]}==5'b010000);
	equal = (earlyRD1 == earlyRD2);
	JumpAddr =	{PCadd4[31:28],(Instruction[25:0]<<2)};
	//Branch prediction
	if(Branch) begin
		case({BranchTaken,(Branch&equal)})
			2'b00:	begin
						BranchCtrl = 0;
						PredictMiss	= 0;
					end
			2'b01:	begin
						BranchCtrl = 1;
						PredictMiss = 1;
					end
			2'b10:	begin
						BranchCtrl = 0;
						PredictMiss = 1;
					end
			2'b11:	begin
						BranchCtrl = 1;
						PredictMiss = 0;
					end
		endcase
	end
	else begin
		BranchCtrl = 0;
		PredictMiss = 0;
	end
	
	
	Reg_R1 = Instruction[25:21];
	Reg_R2 = Instruction[20:16];
	
	//register
	next_regfile[0] = regfile[0];//constant zero
	if(MEM_RegWrite) begin
		for(i=1;i<32;i=i+1)
			if(i!=Reg_W)
				next_regfile[i]	=	regfile[i];
			else
				next_regfile[i]	=	WriteData;
	end
	else if(Jump&(Instruction[31:26]==3)&(!MEM_RegWrite)) begin
		for(i=1;i<32;i=i+1)
			if(i!=5'b11111)
				next_regfile[i]	=	regfile[i];
			else
				next_regfile[i]	=	PCadd4;
	end
	else if(PCBuffer_valid) begin
		for(i=1;i<32;i=i+1)
			if(i!=5'b11111)
				next_regfile[i]	=	regfile[i];
			else
				next_regfile[i]	=	PCBuffer;
	end	
	else begin
		for(i=1;i<32;i=i+1)
			next_regfile[i]	=	regfile[i];
	end
	//bypass control signal
	if(stall) begin
		next_WB	=	WB;
		next_MEM=	MEM;
		next_EX	=	EX;
		next_PCBuffer	= PCBuffer;
		next_PCBuffer_valid =	PCBuffer_valid;
		next_RData1	=	RData1;
		next_RData2	=	RData2;
		next_Immediate_SE	=	Immediate_SE;
		next_RegisterRd	=	RegisterRd;
		next_RegisterRs	=	RegisterRs;
		next_RegisterRt	=	RegisterRt;
	end
	else begin
		
		//control
		if(Bubble||(Instruction==32'b0)) begin
			next_WB = 0;
			next_MEM = 0;
			next_EX = 0;
		end
		else begin
			next_WB	= {RegWrite,MemtoReg};
			next_MEM = {1'b0,MemRead,MemWrite};
			next_EX = {Shift,Branch,RegDst,ALUOp,ALUSrc};
		end
		//Sign Extention
		if(Instruction[29]&Instruction[28])//if andi ori xori
			next_Immediate_SE = {16'b0,Instruction[15:0]};
		else
			next_Immediate_SE = {{16{Instruction[15]}},Instruction[15:0]};
		//JAL PC Buffer
		if((Instruction[31:26]==3)&MEM_RegWrite) begin
			next_PCBuffer_valid = 1;
			next_PCBuffer = PCadd4;
		end
		else if((!MEM_RegWrite)&&(!((Instruction[31:26]==3)&(!MEM_RegWrite)))&&(PCBuffer_valid)) begin
			next_PCBuffer_valid = 0;
			next_PCBuffer = 0;
		end
		else begin
			next_PCBuffer_valid = PCBuffer_valid;
			next_PCBuffer = PCBuffer;
		end
		next_RData1	=	regfile[Reg_R1];
		next_RData2	=	regfile[Reg_R2];
		//bypass address
		next_RegisterRd = Instruction[15:11];
		next_RegisterRs = Instruction[25:21];
		next_RegisterRt = Instruction[20:16];
	end
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		WB	<=	0;
		MEM	<=	0;
		EX	<=	0;
		PCBuffer	<= 0;
		PCBuffer_valid	<=	0;
		RData1	<=	0;
		RData2	<=	0;
		Immediate_SE	<=	0;
		RegisterRd	<=	0;
		RegisterRs	<=	0;
		RegisterRt	<=	0;
	end
	else begin
		WB	<=	next_WB;
		MEM	<=	next_MEM;
		EX	<=	next_EX;
		PCBuffer	<= next_PCBuffer;
		PCBuffer_valid	<=	next_PCBuffer_valid;
		RData1	<=	next_RData1;
		RData2	<=	next_RData2;
		Immediate_SE	<=	next_Immediate_SE;
		RegisterRd	<=	next_RegisterRd;
		RegisterRs	<=	next_RegisterRs;
		RegisterRt	<=	next_RegisterRt;
	end
end

always @(negedge clk or negedge rst) begin
	if(!rst) begin
		for(i=0;i<32;i=i+1)
		regfile[i]	<=	0;
	end
	else begin
		for(i=0;i<32;i=i+1)
		regfile[i]	<=	next_regfile[i];
	end
end
endmodule
