`timescale 1 ns/10 ps
module Execution(	//global signal
					clk,
					rst,
					stall,
					//ID interface
					ID_WB,
					ID_MEM,
					ID_EX,
					RData1,
					RData2,
					Immediate_SE,
					ID_RegisterRt,
					ID_RegisterRd,
					//MEM interface
					WB,
					MEM,
					next_ALUresult,
					ALUresult,
					MEMWriteData,
					RegisterRd,
					//WB interface
					WBData,
					//Forwarding unit Interface
					ForwardA,
					ForwardB
					);
	input			clk;
	input			rst;
	input			stall;
	input	[1:0]	ID_WB;
	input	[2:0]	ID_MEM;
	input	[6:0]	ID_EX;//{Shift,Branch,RegDst,ALUOp[2:0],ALUSrc}
	input	[31:0]	RData1;
	input	[31:0]	RData2;
	input	[31:0]	Immediate_SE;
	input	[4:0]	ID_RegisterRt;
	input	[4:0]	ID_RegisterRd;
	output	[1:0]	WB;
	output	[2:0]	MEM;
	output	[31:0]	next_ALUresult;
	output	[31:0]	ALUresult;
	output	[31:0]	MEMWriteData;
	output	[4:0]	RegisterRd;
	input	[31:0]	WBData;
	input	[1:0]	ForwardA;
	input	[1:0]	ForwardB;
//======reg/wire declaration=========//
	reg	[1:0]	SelectD1;
	reg	[1:0]	SelectD2;
	reg	[31:0]	ALUData1;
	reg	[31:0]	ALUData2;
	reg	[3:0]	ALUctrl;
	//register
	reg	[1:0]	WB;
	reg	[1:0]	next_WB;
	reg	[2:0]	MEM;
	reg	[2:0]	next_MEM;
	reg	[31:0]	ALUresult;
	reg	[31:0]	next_ALUresult;
	reg	[31:0]	MEMWriteData;
	reg	[31:0]	next_MEMWriteData;
	reg	[4:0]	RegisterRd;
	reg	[4:0]	next_RegisterRd;

//ALU	
always @(ALUctrl or ALUData1 or ALUData2 or Immediate_SE[10:6] or stall or ALUresult) begin
	if(stall) begin
		next_ALUresult = ALUresult;
	end
	else begin
		case(ALUctrl)
			4'b0010 : next_ALUresult = ALUData1+ALUData2;
			4'b0110 : next_ALUresult = ALUData1-ALUData2;
			4'b0000 : next_ALUresult = ALUData1&ALUData2; 
			4'b0001 : next_ALUresult = ALUData1|ALUData2;
			4'b1001 : next_ALUresult = ~(ALUData1|ALUData2);
			4'b0011 : next_ALUresult = ALUData1^ALUData2;
			4'b0100 : next_ALUresult = ALUData2<<(Immediate_SE[10:6]);
			4'b1100 : next_ALUresult = ALUData2>>(Immediate_SE[10:6]);
			4'b0101 : begin
						case(Immediate_SE[10:6])
							0:	next_ALUresult = ALUData2;
							1:	next_ALUresult = {ALUData2[31],ALUData2[31:1]};
							2:	next_ALUresult = {{2{ALUData2[31]}},ALUData2[31:2]};
							3:	next_ALUresult = {{3{ALUData2[31]}},ALUData2[31:3]};
							4:	next_ALUresult = {{4{ALUData2[31]}},ALUData2[31:4]};
							5:	next_ALUresult = {{5{ALUData2[31]}},ALUData2[31:5]};
							6:	next_ALUresult = {{6{ALUData2[31]}},ALUData2[31:6]};
							7:	next_ALUresult = {{7{ALUData2[31]}},ALUData2[31:7]};
							8:	next_ALUresult = {{8{ALUData2[31]}},ALUData2[31:8]};
							9:	next_ALUresult = {{9{ALUData2[31]}},ALUData2[31:9]};
							10:	next_ALUresult = {{10{ALUData2[31]}},ALUData2[31:10]};
							11:	next_ALUresult = {{11{ALUData2[31]}},ALUData2[31:11]};
							12:	next_ALUresult = {{12{ALUData2[31]}},ALUData2[31:12]};
							13:	next_ALUresult = {{13{ALUData2[31]}},ALUData2[31:13]};
							14:	next_ALUresult = {{14{ALUData2[31]}},ALUData2[31:14]};
							15:	next_ALUresult = {{15{ALUData2[31]}},ALUData2[31:15]};
							16:	next_ALUresult = {{16{ALUData2[31]}},ALUData2[31:16]};
							17:	next_ALUresult = {{17{ALUData2[31]}},ALUData2[31:17]};
							18:	next_ALUresult = {{18{ALUData2[31]}},ALUData2[31:18]};
							19:	next_ALUresult = {{19{ALUData2[31]}},ALUData2[31:19]};
							20:	next_ALUresult = {{20{ALUData2[31]}},ALUData2[31:20]};
							21:	next_ALUresult = {{21{ALUData2[31]}},ALUData2[31:21]};
							22:	next_ALUresult = {{22{ALUData2[31]}},ALUData2[31:22]};
							23:	next_ALUresult = {{23{ALUData2[31]}},ALUData2[31:23]};
							24:	next_ALUresult = {{24{ALUData2[31]}},ALUData2[31:24]};
							25:	next_ALUresult = {{25{ALUData2[31]}},ALUData2[31:25]};
							26:	next_ALUresult = {{26{ALUData2[31]}},ALUData2[31:26]};
							27:	next_ALUresult = {{27{ALUData2[31]}},ALUData2[31:27]};
							28:	next_ALUresult = {{28{ALUData2[31]}},ALUData2[31:28]};
							29:	next_ALUresult = {{29{ALUData2[31]}},ALUData2[31:29]};
							30:	next_ALUresult = {{30{ALUData2[31]}},ALUData2[31:30]};
							31:	next_ALUresult = {32{ALUData2[31]}};
						endcase
					end
			4'b0111 : next_ALUresult = (ALUData1<=ALUData2) ? 1 : 0;
			default : next_ALUresult = 32'b0;
		endcase
	end
end
	
always @(*) begin
	if(stall) begin
		next_MEMWriteData = MEMWriteData;
		next_RegisterRd = RegisterRd;
		next_WB = WB;
		next_MEM = MEM;
	end
	else begin
		case(ForwardB)
			2'b01: next_MEMWriteData = WBData;
			2'b10: next_MEMWriteData = ALUresult;
			default: next_MEMWriteData = RData2;
		endcase
		next_RegisterRd = ID_EX[4]?ID_RegisterRd:ID_RegisterRt;
		next_WB = ID_WB;
		next_MEM = ID_MEM;
	end
	//ALUControl
	casex({ID_EX[3:1] , Immediate_SE[5:0]})
		9'b010100000: ALUctrl = 4'b0010; //add
		9'b010100010: ALUctrl = 4'b0110; //sub
		9'b010100100: ALUctrl = 4'b0000; //and
		9'b010100101: ALUctrl = 4'b0001; //or
		9'b010100111: ALUctrl = 4'b1001; //nor
		9'b010100110: ALUctrl = 4'b0011; //xor
		9'b010000000: ALUctrl = 4'b0100; //sll
		9'b010000010: ALUctrl = 4'b1100; //srl
		9'b010000011: ALUctrl = 4'b0101; //sra
		9'b010101010: ALUctrl = 4'b0111; //slt
		9'b000xxxxxx: ALUctrl = 4'b0010; //lw sw
		9'b100xxxxxx: ALUctrl = 4'b0010; //addi
		9'b101xxxxxx: ALUctrl = 4'b0000; //andi
		9'b110xxxxxx: ALUctrl = 4'b0001; //ori
		9'b111xxxxxx: ALUctrl = 4'b0011; //xori
		9'b011xxxxxx: ALUctrl = 4'b0111; //slti
		9'b001xxxxxx: ALUctrl = 4'b0010; //j jal beq
		default		: ALUctrl = 4'b1111; //jr
	endcase
	//ALUSource
	SelectD1 = ForwardA;
	SelectD2 = ID_EX[0]?2'b11:ForwardB;
	case(SelectD1)
		2'b00:	ALUData1 = RData1;
		2'b01:	ALUData1 = WBData;
		2'b10:	ALUData1 = ALUresult;
		2'b11:	ALUData1 = 0;
	endcase
	case(SelectD2)
		2'b00:	ALUData2 = RData2;				
		2'b01:	ALUData2 = WBData;
		2'b10:	ALUData2 = ALUresult;
		2'b11:	ALUData2 = Immediate_SE;
	endcase
end

always @(posedge clk or negedge rst) begin
	if(!rst) begin
		WB	<=	0;
		MEM	<=	0;
		ALUresult	<=	0;
		MEMWriteData	<=	0;
		RegisterRd	<=	0;
	end
	else begin
		WB	<=	next_WB;
		MEM	<=	next_MEM;
		ALUresult	<=	next_ALUresult;
		MEMWriteData	<=	next_MEMWriteData;
		RegisterRd	<=	next_RegisterRd;
	end
end
endmodule
