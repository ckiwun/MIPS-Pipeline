`timescale 1 ns/10 ps
module cache_L2(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_rdata,
    proc_wdata,
    //proc_stall,
	proc_ready,
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
    input   [27:0] proc_addr;
    input   [127:0]proc_wdata;
    //output         proc_stall;
    output  [127:0]proc_rdata;
	output		   proc_ready;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
     
//==== wire/reg definition ================================
    
	reg [151:0] block[63:0];    //64 blocks; 1 valid, 1 dirty, 22 tag, 4x32=128 words; 1+1+22+28=151;
	reg [151:0] next_block;
	reg [1:0] state;
	reg [1:0] next_state;
	reg			pre_access;
		
	//reg proc_stall;
	reg  [127:0]  proc_rdata;
	reg	proc_ready;
	reg	next_proc_ready;

	reg mem_read;
	reg mem_write;
	reg  [27:0]  mem_addr;
	reg  [127:0] mem_wdata;

	//wire [1:0] offset;
	wire [5:0] index;
	wire valid;
	wire dirty;
	wire [21:0] tag;
	wire tag_match;
	wire hit;
	
//	wire [31:0] word[3:0];
	
	parameter IDLE = 2'b00;
	parameter READ_MISS = 2'b01;
	parameter WRITE_MISS = 2'b10;
	parameter WRITE_BACK = 2'b11;
	
//==== combinational circuit ==============================
	
	//assign offset = proc_addr[1:0];
	assign index = proc_addr[5:0];
	assign tag = proc_addr[27:6];  
	assign valid = block[{index}][151];
	assign dirty = block[{index}][150];//proc_addr 
	assign tag_match = (tag == block[{index}][149:128]) ? 1'b1 : 1'b0;
	assign hit = tag_match & valid;
	
/*	assign word[0] = block[{index}][31:0];
	assign word[1] = block[{index}][63:32];
	assign word[2] = block[{index}][95:64];
	assign word[3] = block[{index}][127:96];*/
	
always @(*) begin
case(state)
IDLE: begin
		case({proc_write, proc_read})
		2'b01: begin // reading operation
				if(hit) begin
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = 28'b0;
				mem_wdata = 128'b0;
				proc_rdata = block[{index}][127:0];
				//proc_stall = 1'b0;
				next_block = block[{index}];
				next_state = IDLE;
				if(proc_ready)
				next_proc_ready = 0;
				else if({pre_access,proc_ready}==2'b10)
				next_proc_ready = 1;
				else
				next_proc_ready = 0;
						end
				else if( (~hit) & dirty ) begin // need to write_back
				mem_read = 1'b0;
				mem_write = 1'b1;
				mem_addr = {block[{index}][149:128],index};
				mem_wdata = block[{index}][127:0];
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = WRITE_BACK;
				next_proc_ready = 0;
						end
				else begin // READ_MISS
				mem_read = 1'b1;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = READ_MISS;
				next_proc_ready = 0;
					end
				end
		2'b10: begin //writing operation
				if(hit) begin
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = 28'b0;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b0;
				next_block = {1'b1,1'b1,tag,proc_wdata}; 
				next_state = IDLE;
				if(proc_ready)
				next_proc_ready = 0;
				else if({pre_access,proc_ready}==2'b10)
				next_proc_ready = 1;
				else
				next_proc_ready = 0;
						end
				else if( (~hit) & dirty ) begin // need to write_back
				mem_read = 1'b0;
				mem_write = 1'b1;
				mem_addr = {block[{index}][149:128],index};
				mem_wdata = block[{index}][127:0];
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = WRITE_BACK;
				next_proc_ready = 0;
						end
				else begin // WRITE_MISS
				mem_read = 1'b1;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = WRITE_MISS;
				next_proc_ready = 0;
					end
				end
		default: begin  // no operation next_state = IDLE;
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = 28'b0;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b0;
				next_block = block[{index}];
				next_state = IDLE;
				next_proc_ready = 0;
				end
		endcase
		end
READ_MISS: begin
			if(~mem_ready) begin    
				mem_read = 1'b1;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = READ_MISS;
				next_proc_ready = 0;
			end
			else begin
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = mem_rdata;
				//proc_stall = 1'b0;
				next_block = {1'b1, 1'b0, tag, mem_rdata};
				next_state = IDLE;
				next_proc_ready = 1;
			end
			
			end
WRITE_MISS: begin
			if(~mem_ready) begin    
				mem_read = 1'b1;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = WRITE_MISS;
				next_proc_ready = 0;
			end
			else begin
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = proc_addr;
				mem_wdata = 128'b0;
				proc_rdata = 128'b0;
				//proc_stall = 1'b0;
				next_block = {1'b1,1'b1,tag,proc_wdata}; 
				next_state = IDLE;
				next_proc_ready = 1;
			end
			end
WRITE_BACK: begin
			if(~mem_ready) begin    
				mem_read = 1'b0;
				mem_write = 1'b1;
				mem_addr = {block[{index}][149:128],index};
				mem_wdata = block[{index}][127:0];
				proc_rdata = 128'b0;
				//proc_stall = 1'b1;
				next_block = block[{index}];
				next_state = WRITE_BACK;
				next_proc_ready = 0;
			end
			else begin
				mem_read = 1'b0;
				mem_write = 1'b0;
				mem_addr = {block[{index}][149:128],index};
				mem_wdata = block[{index}][127:0];
				proc_rdata = 128'b0;				
				//proc_stall = 1'b1;
				next_block = block[{index}];
				if(proc_read & ~proc_write)
				next_state = READ_MISS;
				else if(~proc_read & proc_write)
				next_state = WRITE_MISS;
				else
				next_state = IDLE;
				next_proc_ready = 1;
			end
			end
endcase
end	
	
//==== sequential circuit =================================
always@( posedge clk or posedge proc_reset ) begin
    if( proc_reset ) begin
	state	 <= 2'b0;
    block[0] <= 151'b0;
	block[1] <= 151'b0;
	block[2] <= 151'b0;
	block[3] <= 151'b0;
	block[4] <= 151'b0;
	block[5] <= 151'b0;
	block[6] <= 151'b0;
	block[7] <= 151'b0;
	pre_access <= 0;
	
    end
    else begin
	state <= next_state;
	block[{index}] <= next_block;
	pre_access <= proc_read|proc_write;
	
    end
end
always @( posedge clk or posedge proc_reset) begin
	if(proc_reset)
	proc_ready <= 0;
	else
	proc_ready <= next_proc_ready;
end

endmodule
