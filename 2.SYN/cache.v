`timescale 1 ns/10 ps
module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    proc_stall,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    // parameter
	parameter Compare_Tag	= 2'b00;
	parameter Write_Back 	= 2'b01;
	parameter Allocate 		= 2'b10;
	parameter Idle 			= 2'b11;
//==== wire/reg definition ================================
    reg [1:0]state,next_state,pre_state;
	reg [31:0] proc_rdata;
	reg mem_read, mem_write;
	reg [27:0] mem_addr;
	reg [127:0] mem_wdata;
	reg [31:0]cachefile[31:0];
	reg [31:0]next_cachefile[31:0];
	reg [24:0]Cache_Tag[7:0];
	reg [24:0]next_Cache_Tag[7:0];
	reg [7:0]Cache_Valid,next_Cache_Valid;
	reg proc_stall;
	reg Cache_Hit,Old_Block_Dirty;
	reg [7:0]Dirty,next_Dirty;
	reg Valid_CPU_request,Mark_Cache_Ready,Memory_Ready;
	integer i;
//==== combinational circuit ==============================
always@(*) begin
	//Finite State Machine Input
	Cache_Hit = Cache_Valid[(proc_addr[4:2])] & (proc_addr[29:5]==Cache_Tag[(proc_addr[4:2])]);
	Old_Block_Dirty = Dirty[(proc_addr[4:2])];
	Valid_CPU_request = proc_read | proc_write;
	Mark_Cache_Ready = (state==Compare_Tag)&(pre_state==Allocate);
	Memory_Ready = mem_ready;
	//Cache Finite State Machine
	case(state)
		Compare_Tag	:	begin
							if((~Cache_Hit)||(pre_state==Allocate))
								proc_stall = 1;
							else
								proc_stall = 0;
							mem_read  = 0;
							mem_write = 0;
							mem_wdata = 128'h0;
							mem_addr = 28'h0;
							next_Cache_Valid = Cache_Valid;
							for(i=0;i<8;i=i+1)
							next_Cache_Tag[i]= Cache_Tag[i];
							if({proc_read,proc_write}==2'b10) begin//proc read
								for(i=0;i<32;i=i+1)
								next_cachefile[i] = cachefile[i];
								proc_rdata = cachefile[(proc_addr[4:0])];
								next_Dirty = Dirty;
							end
							else if(({proc_read,proc_write}==2'b01)&&Cache_Hit) begin //proc write
								proc_rdata = 32'h0;
								for(i=0;i<32;i=i+1)
								if(i!=proc_addr[4:0])
								next_cachefile[i] = cachefile[i];
								else
								next_cachefile[i] = proc_wdata;
								next_Dirty = Dirty;
								next_Dirty[(proc_addr[4:2])] = 1;
							end
							else begin //default
								for(i=0;i<32;i=i+1)
								next_cachefile[i] = cachefile[i];
								proc_rdata = 32'h0;
								next_Dirty = Dirty;
							end
							casex({Cache_Hit,Old_Block_Dirty,Mark_Cache_Ready,Valid_CPU_request,Memory_Ready})
								5'b1xxxx:	next_state = Idle;
								5'b0x1xx:	next_state = Idle;
								5'b01xxx:	next_state = Write_Back;
								5'b00xxx:	next_state = Allocate;
								default	:	next_state = Compare_Tag;
							endcase
						end
		Write_Back	:	begin
							proc_stall = 1;
							proc_rdata = 32'h0;
							mem_read  = 0;
							next_Cache_Valid = Cache_Valid;
							for(i=0;i<8;i=i+1)
							next_Cache_Tag[i]= Cache_Tag[i];
							next_Dirty = Dirty;
							for(i=0;i<32;i=i+1)
								next_cachefile[i] = cachefile[i];
							if(Cache_Valid[(proc_addr[4:2])]) begin
								mem_write = ~Memory_Ready;
								mem_addr ={Cache_Tag[(proc_addr[4:2])],proc_addr[4:2]};
							end
							else begin
								mem_write = 0;
								mem_addr = 28'h0;
							end
							case(proc_addr[4:2])
								3'b000: mem_wdata = {cachefile[3],cachefile[2],cachefile[1],cachefile[0]};
								3'b001: mem_wdata = {cachefile[7],cachefile[6],cachefile[5],cachefile[4]};
								3'b010: mem_wdata = {cachefile[11],cachefile[10],cachefile[9],cachefile[8]};
								3'b011: mem_wdata = {cachefile[15],cachefile[14],cachefile[13],cachefile[12]};//first way
								3'b100: mem_wdata = {cachefile[19],cachefile[18],cachefile[17],cachefile[16]};
								3'b101: mem_wdata = {cachefile[23],cachefile[22],cachefile[21],cachefile[20]};
								3'b110: mem_wdata = {cachefile[27],cachefile[26],cachefile[25],cachefile[24]};
								3'b111: mem_wdata = {cachefile[31],cachefile[30],cachefile[29],cachefile[28]};//second way
							endcase
							casex({Cache_Hit,Old_Block_Dirty,Mark_Cache_Ready,Valid_CPU_request,Memory_Ready})
								5'bxxxx1:	next_state = Allocate;
								default	:	if(Cache_Valid[(proc_addr[4:2])])next_state = Write_Back;
											else next_state = Allocate;
							endcase
						end
		Allocate	:	begin
							proc_stall = 1;
							proc_rdata = 32'h0;
							mem_read  = 1;
							mem_write = 0;
							mem_wdata = 128'h0;
							mem_addr = proc_addr[29:2];
							next_Dirty = Dirty;
							next_Dirty[(proc_addr[4:2])] = 0;
							for(i=0;i<32;i=i+1)
							next_cachefile[i] = cachefile[i];
							for(i=0;i<8;i=i+1)
							if(i!=proc_addr[4:2]) begin
								next_Cache_Valid[i] = Cache_Valid[i];
								next_Cache_Tag[i] = Cache_Tag[i];
							end
							else begin
								next_Cache_Valid[i] = 1;
								next_Cache_Tag[i] = proc_addr[29:5];
							end
							case(proc_addr[4:2])
								3'b000: {next_cachefile[3],next_cachefile[2],next_cachefile[1],next_cachefile[0]}	 = mem_rdata;
								3'b001: {next_cachefile[7],next_cachefile[6],next_cachefile[5],next_cachefile[4]}	 = mem_rdata;
								3'b010: {next_cachefile[11],next_cachefile[10],next_cachefile[9],next_cachefile[8]}  = mem_rdata;
								3'b011: {next_cachefile[15],next_cachefile[14],next_cachefile[13],next_cachefile[12]}= mem_rdata;//first way
								3'b100: {next_cachefile[19],next_cachefile[18],next_cachefile[17],next_cachefile[16]}= mem_rdata;
								3'b101: {next_cachefile[23],next_cachefile[22],next_cachefile[21],next_cachefile[20]}= mem_rdata;
								3'b110: {next_cachefile[27],next_cachefile[26],next_cachefile[25],next_cachefile[24]}= mem_rdata;
								3'b111: {next_cachefile[31],next_cachefile[30],next_cachefile[29],next_cachefile[28]}= mem_rdata;//second way
							endcase
							casex({Cache_Hit,Old_Block_Dirty,Mark_Cache_Ready,Valid_CPU_request,Memory_Ready})
								5'bxxxx1:	next_state = Compare_Tag;
								default	:	next_state = Allocate;
							endcase
						end
		Idle		:	begin
							proc_stall = 0;
							mem_read  = 0;
							mem_write = 0;
							mem_wdata = 128'h0;
							mem_addr = 28'h0;
							next_Cache_Valid = Cache_Valid;
							for(i=0;i<8;i=i+1)
							next_Cache_Tag[i]= Cache_Tag[i];
							if(({proc_read,proc_write}==2'b01)&&Cache_Hit) begin //proc write
								for(i=0;i<32;i=i+1)
								if(i!=proc_addr[4:0])
								next_cachefile[i] = cachefile[i];
								else
								next_cachefile[i] = proc_wdata;
								next_Dirty = Dirty;
								next_Dirty[(proc_addr[4:2])] = 1;
							end
							else begin
								for(i=0;i<32;i=i+1)
								next_cachefile[i] = cachefile[i];
								next_Dirty = Dirty;
							end
							proc_rdata = cachefile[(proc_addr[4:0])];
							casex({Cache_Hit,Old_Block_Dirty,Mark_Cache_Ready,Valid_CPU_request,Memory_Ready})
								5'bxxx1x:	next_state = Compare_Tag;
								default	:	next_state = Idle;
							endcase
						end
	endcase
end
//==== sequential circuit =================================
always@( negedge clk or posedge proc_reset ) begin
    if( proc_reset ) begin
		state <= Idle;
		Cache_Valid <= 0;
		Dirty <= 8'hff;
		pre_state <= 0;
		for(i=0;i<8;i=i+1)
		Cache_Tag[i] <= 25'b0;
		for(i=0;i<32;i=i+1)
		cachefile[i] <= 32'b0;
    end
    else begin
		state <= next_state;
		Cache_Valid <= next_Cache_Valid;
		Dirty <= next_Dirty;
		pre_state <= state;
		for(i=0;i<8;i=i+1)
		Cache_Tag[i] <= next_Cache_Tag[i];
		for(i=0;i<32;i=i+1)
		cachefile[i] <= next_cachefile[i];
    end
end

endmodule
