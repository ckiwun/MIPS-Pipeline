// L2 cache included
// this is a testbench feeds initial instruction and data
// the processor output is not verified
`include "MIPS_Pipeline_syn_dft.v"
`include "cache.v"
`include "L2_cache.v"
`include "slow_memory.v"

`timescale 1 ns/10 ps
//`define	H_CYCLE 2.5
`define CYCLE 10
//`define LCYCLE 20
//`define	H_LCYCLE 10

// Choose your test program
//`define IMEM_INIT "finaltest_L2Cache"
//`define IMEM_INIT "finaltest"
`define IMEM_INIT "finaltest2"
//`define IMEM_INIT "finaltest_BrPred"
`define	MACHINE_CODE_SIZE	1024

module L2_cache_tb;

	reg clk;
	reg slow_clk;
	reg rst_n;
	reg cen;
	reg stall;
	
	wire SB,SH;
	reg [7:0]mem[0:`MACHINE_CODE_SIZE-1];			// store machine code
	reg		[31:0]	w3, w2, w1, w0;
	
	wire [31:0] RF_writedata;
	wire wen_tb;
	wire [31:0] waddr_tb;
	wire [31:0] addr_tb;

	wire [29:0] ICACHE_addr;
	wire [31:0] ICACHE_addr_o;
	wire [31:0] ICACHE_rdata;
	wire ICACHE_ren;
	wire ICACHE_wen;
	wire [31:0] ICACHE_wdata;
	wire ICACHE_stall;
	
	wire [29:0] DCACHE_addr;
	wire [31:0] DCACHE_addr_o;
	wire [31:0] DCACHE_rdata;
	wire DCACHE_ren;
	wire DCACHE_wen;
	wire [31:0] DCACHE_wdata;
	wire DCACHE_stall;
	
	//D L1 to L2
	wire mem_read_D;
	wire mem_write_D;
	wire [31:4] mem_addr_D;
	wire [127:0] mem_wdata_D;
	wire [127:0] mem_rdata_D;
    wire mem_ready_D;
	
	//D L2 to mem
	wire mem_read_D2;
	wire mem_write_D2;
	wire [31:4] mem_addr_D2;
	wire [127:0] mem_wdata_D2;
	wire [127:0] mem_rdata_D2;
    wire mem_ready_D2;
	
	//I L1 to L2
	wire mem_read_I;
	wire mem_write_I;
	wire [31:4] mem_addr_I;
	wire [127:0] mem_wdata_I;
	wire [127:0] mem_rdata_I;
	wire mem_ready_I;
	
	//I L2 to mem
	wire mem_read_I2;
	wire mem_write_I2;
	wire [31:4] mem_addr_I2;
	wire [127:0] mem_wdata_I2;
	wire [127:0] mem_rdata_I2;
	wire mem_ready_I2;
	
	integer error_cnt;
	integer i;

	// Note the design is connected at testbench, include:
	// 1. pipelined MIPS processor
	// 2. data cache
	// 3. instruction cache
	// 4. slow memory for data
	// 5. slow memory for instruction
	// 6. L2 data cache
	// 7. L2 instruction cache

    assign ICACHE_addr=ICACHE_addr_o[31:2];
	assign DCACHE_addr=DCACHE_addr_o[31:2];
	
	
	//Reference instantiation for MIPS CPU, replace it with your own design
	MIPS_Pipeline i_MIPS(
		  clk, 
		  rst_n,
		//cen,
		//stall,
		
		/*I cache interface*/
		  ICACHE_addr_o,
		  ICACHE_rdata,
		  ICACHE_ren,
		  ICACHE_wen,
		  ICACHE_wdata,
		  ICACHE_stall,
	
		/*D cache interface*/
		  DCACHE_addr_o,
		  DCACHE_rdata,
		  DCACHE_ren,
		  DCACHE_wen,
		  DCACHE_wdata,
		  DCACHE_stall,
		  test_si,
		  test_so, 
		  1'b0
	);

	//Reference instantiation for data cache
	cache D_cache(
		.clk(clk),
		.proc_reset(~rst_n),
		
		.proc_read(DCACHE_ren),
		.proc_write(DCACHE_wen),
		.proc_addr(DCACHE_addr),
		.proc_rdata(DCACHE_rdata),
		.proc_wdata(DCACHE_wdata),
		.proc_stall(DCACHE_stall),
		
		.mem_read(mem_read_D),
		.mem_write(mem_write_D),
		.mem_addr(mem_addr_D),
		.mem_rdata(mem_rdata_D),
		.mem_wdata(mem_wdata_D),
		.mem_ready(mem_ready_D)
		//.byte_addr(DCACHE_addr_o[1:0]),
	    //.byte_en({SH,SB})
	);
    
	//Reference template for L2 data cache  , replace it with your own design
	cache_L2 D_cl2(
        .clk(clk),
        .proc_reset(~rst_n),
        .proc_read(mem_read_D),
        .proc_write(mem_write_D),
        .proc_addr(mem_addr_D),
        .proc_rdata(mem_rdata_D),
        .proc_wdata(mem_wdata_D),
        .proc_ready(mem_ready_D),
	
    .mem_read(mem_read_D2),
    .mem_write(mem_write_D2),
    .mem_addr(mem_addr_D2),
    .mem_rdata(mem_rdata_D2),
    .mem_wdata(mem_wdata_D2),
    .mem_ready(mem_ready_D2)
    );

	//Reference instantiation for instruction cache  
	cache I_cache(
		.clk(clk),
		.proc_reset(~rst_n),
		
		.proc_read(ICACHE_ren),
		.proc_write(ICACHE_wen),
		.proc_addr(ICACHE_addr),
		.proc_rdata(ICACHE_rdata),
		.proc_wdata(ICACHE_wdata),
		.proc_stall(ICACHE_stall),
		
		.mem_read(mem_read_I),
		.mem_write(mem_write_I),
		.mem_addr(mem_addr_I),
		.mem_rdata(mem_rdata_I),
		.mem_wdata(mem_wdata_I),
		.mem_ready(mem_ready_I)
		//2'd0,
		//2'd0
	);
	
	//Reference instantiation for L2 instruction cache  
	//Replace it with your own design
	
	cache_L2 I_cl2(
	   /* interface to L1 cache*/
	  .clk(~clk),
      .proc_reset(~rst_n),
      .proc_read(mem_read_I),
      .proc_write(mem_write_I),
      .proc_addr(mem_addr_I),
      .proc_rdata(mem_rdata_I),
      .proc_wdata(mem_wdata_I),
      .proc_ready(mem_ready_I),
	
	  /*Interface to slow memory*/
      .mem_read(mem_read_I2),
      .mem_write(mem_write_I2),
      .mem_addr(mem_addr_I2),
      .mem_rdata(mem_rdata_I2),
      .mem_wdata(mem_wdata_I2),
      .mem_ready(mem_ready_I2)
	);
	
	//Slow memory for instruction
	slow_memory slow_memI(
		//slow_clk,
		~clk,
		mem_read_I2,
		mem_write_I2,
		mem_addr_I2,
		mem_wdata_I2,
		mem_rdata_I2,
		mem_ready_I2
	);
	
	
	//Slow memory for data
	slow_memory slow_memD(
		//slow_clk,
		clk,
		mem_read_D2,
		mem_write_D2,
		mem_addr_D2,
		mem_wdata_D2,
		mem_rdata_D2,
		mem_ready_D2
	);

	/*slow_memory slow_memI(
		//slow_clk,
		~clk,
		mem_read_I,
		mem_write_I,
		mem_addr_I,
		mem_wdata_I,
		mem_rdata_I,
		mem_ready_I
	);*/
	integer m;

// Initialize the data memory
	initial begin
		//$readmemb (`DMEM_INIT, slow_memD.mem ); // initialize data in DMEM
		$readmemb (`IMEM_INIT, mem,0 ); // initialize data in IMEM
		// For w/ cache, 128bit imem
    for( i=0; i < `MACHINE_CODE_SIZE; i=i+16 )
    begin
    	w0 = { mem[i+0 ], mem[i+1 ], mem[i+2 ], mem[i+3 ] };		// big endian
    	w1 = { mem[i+4 ], mem[i+5 ], mem[i+6 ], mem[i+7 ] };		// big endian
    	w2 = { mem[i+8 ], mem[i+9 ], mem[i+10], mem[i+11] };		// big endian
    	w3 = { mem[i+12], mem[i+13], mem[i+14], mem[i+15] };		// big endian    	
      slow_memI.mem[ i/16 ] = { w3, w2, w1, w0 };
    end  
	    $display("\nReading instruction memory......");
		for ( m=0; m<50; m=m+1 )
		begin
			//$display("slow_memI[%d] = %b", m, slow_memI.mem[m]);//
		end
		
		$dumpfile("Final2_L2_dft.fsdb");			
		$dumpvars(0,L2_cache_tb);								

		clk = 0;
		slow_clk = 0;
		error_cnt = 0;

		rst_n = 1'b1;
		#2 rst_n = 1'b0;
		#(`CYCLE*1.5) rst_n = 1'b1;
		wait(DCACHE_wen && DCACHE_wdata==32'hd5d && DCACHE_addr_o == 30'h100) $finish;

	end
	
	initial
	#(`CYCLE*5000)	 $finish; // you have to calculate clock cycles for all operation
	
	always #(`CYCLE*0.5) clk = ~clk;
	initial begin
		$sdf_annotate("MIPS_Pipeline_syn_dft.sdf", i_MIPS);
	end
//	always begin
//		#`H_LCYCLE slow_clk = ~slow_clk;
//	end



endmodule
