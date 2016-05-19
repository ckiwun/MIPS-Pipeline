// Verilog STILDPV testbench written by  TetraMAX (TM)  G-2012.06-SP5-i130118_181936 
// Date: Thu Dec 26 17:28:20 2013
// Module tested: MIPS_Pipeline

`timescale 1 ns / 1 ns

module MIPS_Pipeline_test;
   integer verbose;         // message verbosity level
   integer report_interval; // pattern reporting intervals
   integer diagnostic_msg;  // format miscompares for TetraMAX diagnostics
   parameter NINPUTS = 70, NOUTPUTS = 133;
   // The next two variables hold the current value of the TetraMAX pattern number
   // and vector number, while the simulation is progressing. $monitor or $display these
   // variables, or add them to waveform views, to see these values change with time
   integer pattern_number;
   integer vector_number;

   wire clk;  reg clk_REG ;
   wire rst;  reg rst_REG ;
   wire ICACHE_ren;
   wire ICACHE_wen;
   wire ICACHE_stall;  reg ICACHE_stall_REG ;
   wire DCACHE_ren;
   wire DCACHE_wen;
   wire DCACHE_stall;  reg DCACHE_stall_REG ;
   wire test_si;  reg test_si_REG ;
   wire test_so;
   wire test_se;  reg test_se_REG ;
   wire [31:0] ICACHE_addr;
   wire [31:0] ICACHE_rdata;
//   reg [31:0] ICACHE_rdata_REG;
   reg \ICACHE_rdata_REG[0] ;
   reg \ICACHE_rdata_REG[1] ;
   reg \ICACHE_rdata_REG[2] ;
   reg \ICACHE_rdata_REG[3] ;
   reg \ICACHE_rdata_REG[4] ;
   reg \ICACHE_rdata_REG[5] ;
   reg \ICACHE_rdata_REG[6] ;
   reg \ICACHE_rdata_REG[7] ;
   reg \ICACHE_rdata_REG[8] ;
   reg \ICACHE_rdata_REG[9] ;
   reg \ICACHE_rdata_REG[10] ;
   reg \ICACHE_rdata_REG[11] ;
   reg \ICACHE_rdata_REG[12] ;
   reg \ICACHE_rdata_REG[13] ;
   reg \ICACHE_rdata_REG[14] ;
   reg \ICACHE_rdata_REG[15] ;
   reg \ICACHE_rdata_REG[16] ;
   reg \ICACHE_rdata_REG[17] ;
   reg \ICACHE_rdata_REG[18] ;
   reg \ICACHE_rdata_REG[19] ;
   reg \ICACHE_rdata_REG[20] ;
   reg \ICACHE_rdata_REG[21] ;
   reg \ICACHE_rdata_REG[22] ;
   reg \ICACHE_rdata_REG[23] ;
   reg \ICACHE_rdata_REG[24] ;
   reg \ICACHE_rdata_REG[25] ;
   reg \ICACHE_rdata_REG[26] ;
   reg \ICACHE_rdata_REG[27] ;
   reg \ICACHE_rdata_REG[28] ;
   reg \ICACHE_rdata_REG[29] ;
   reg \ICACHE_rdata_REG[30] ;
   reg \ICACHE_rdata_REG[31] ;
   wire [31:0] ICACHE_wdata;
   wire [31:0] DCACHE_addr;
   wire [31:0] DCACHE_rdata;
//   reg [31:0] DCACHE_rdata_REG;
   reg \DCACHE_rdata_REG[0] ;
   reg \DCACHE_rdata_REG[1] ;
   reg \DCACHE_rdata_REG[2] ;
   reg \DCACHE_rdata_REG[3] ;
   reg \DCACHE_rdata_REG[4] ;
   reg \DCACHE_rdata_REG[5] ;
   reg \DCACHE_rdata_REG[6] ;
   reg \DCACHE_rdata_REG[7] ;
   reg \DCACHE_rdata_REG[8] ;
   reg \DCACHE_rdata_REG[9] ;
   reg \DCACHE_rdata_REG[10] ;
   reg \DCACHE_rdata_REG[11] ;
   reg \DCACHE_rdata_REG[12] ;
   reg \DCACHE_rdata_REG[13] ;
   reg \DCACHE_rdata_REG[14] ;
   reg \DCACHE_rdata_REG[15] ;
   reg \DCACHE_rdata_REG[16] ;
   reg \DCACHE_rdata_REG[17] ;
   reg \DCACHE_rdata_REG[18] ;
   reg \DCACHE_rdata_REG[19] ;
   reg \DCACHE_rdata_REG[20] ;
   reg \DCACHE_rdata_REG[21] ;
   reg \DCACHE_rdata_REG[22] ;
   reg \DCACHE_rdata_REG[23] ;
   reg \DCACHE_rdata_REG[24] ;
   reg \DCACHE_rdata_REG[25] ;
   reg \DCACHE_rdata_REG[26] ;
   reg \DCACHE_rdata_REG[27] ;
   reg \DCACHE_rdata_REG[28] ;
   reg \DCACHE_rdata_REG[29] ;
   reg \DCACHE_rdata_REG[30] ;
   reg \DCACHE_rdata_REG[31] ;
   wire [31:0] DCACHE_wdata;

   // map register to wire for DUT inputs and bidis
   assign clk = clk_REG ;
   assign rst = rst_REG ;
   assign ICACHE_rdata = { \ICACHE_rdata_REG[31] , \ICACHE_rdata_REG[30] , \ICACHE_rdata_REG[29]
          , \ICACHE_rdata_REG[28] , \ICACHE_rdata_REG[27] , \ICACHE_rdata_REG[26]
          , \ICACHE_rdata_REG[25] , \ICACHE_rdata_REG[24] , \ICACHE_rdata_REG[23]
          , \ICACHE_rdata_REG[22] , \ICACHE_rdata_REG[21] , \ICACHE_rdata_REG[20]
          , \ICACHE_rdata_REG[19] , \ICACHE_rdata_REG[18] , \ICACHE_rdata_REG[17]
          , \ICACHE_rdata_REG[16] , \ICACHE_rdata_REG[15] , \ICACHE_rdata_REG[14]
          , \ICACHE_rdata_REG[13] , \ICACHE_rdata_REG[12] , \ICACHE_rdata_REG[11]
          , \ICACHE_rdata_REG[10] , \ICACHE_rdata_REG[9] , \ICACHE_rdata_REG[8] ,
          \ICACHE_rdata_REG[7] , \ICACHE_rdata_REG[6] , \ICACHE_rdata_REG[5] , \ICACHE_rdata_REG[4]
          , \ICACHE_rdata_REG[3] , \ICACHE_rdata_REG[2] , \ICACHE_rdata_REG[1] ,
          \ICACHE_rdata_REG[0]  };
   assign ICACHE_stall = ICACHE_stall_REG ;
   assign DCACHE_rdata = { \DCACHE_rdata_REG[31] , \DCACHE_rdata_REG[30] , \DCACHE_rdata_REG[29]
          , \DCACHE_rdata_REG[28] , \DCACHE_rdata_REG[27] , \DCACHE_rdata_REG[26]
          , \DCACHE_rdata_REG[25] , \DCACHE_rdata_REG[24] , \DCACHE_rdata_REG[23]
          , \DCACHE_rdata_REG[22] , \DCACHE_rdata_REG[21] , \DCACHE_rdata_REG[20]
          , \DCACHE_rdata_REG[19] , \DCACHE_rdata_REG[18] , \DCACHE_rdata_REG[17]
          , \DCACHE_rdata_REG[16] , \DCACHE_rdata_REG[15] , \DCACHE_rdata_REG[14]
          , \DCACHE_rdata_REG[13] , \DCACHE_rdata_REG[12] , \DCACHE_rdata_REG[11]
          , \DCACHE_rdata_REG[10] , \DCACHE_rdata_REG[9] , \DCACHE_rdata_REG[8] ,
          \DCACHE_rdata_REG[7] , \DCACHE_rdata_REG[6] , \DCACHE_rdata_REG[5] , \DCACHE_rdata_REG[4]
          , \DCACHE_rdata_REG[3] , \DCACHE_rdata_REG[2] , \DCACHE_rdata_REG[1] ,
          \DCACHE_rdata_REG[0]  };
   assign DCACHE_stall = DCACHE_stall_REG ;
   assign test_si = test_si_REG ;
   assign test_se = test_se_REG ;

   // instantiate the design into the testbench
   MIPS_Pipeline dut (
      .clk(clk),
      .rst(rst),
      .ICACHE_addr({ ICACHE_addr[31], ICACHE_addr[30], ICACHE_addr[29],
          ICACHE_addr[28], ICACHE_addr[27], ICACHE_addr[26], ICACHE_addr[25], ICACHE_addr[24],
          ICACHE_addr[23], ICACHE_addr[22], ICACHE_addr[21], ICACHE_addr[20], ICACHE_addr[19],
          ICACHE_addr[18], ICACHE_addr[17], ICACHE_addr[16], ICACHE_addr[15], ICACHE_addr[14],
          ICACHE_addr[13], ICACHE_addr[12], ICACHE_addr[11], ICACHE_addr[10], ICACHE_addr[9],
          ICACHE_addr[8], ICACHE_addr[7], ICACHE_addr[6], ICACHE_addr[5], ICACHE_addr[4],
          ICACHE_addr[3], ICACHE_addr[2], ICACHE_addr[1], ICACHE_addr[0] }),
      .ICACHE_rdata({ ICACHE_rdata[31],
          ICACHE_rdata[30], ICACHE_rdata[29], ICACHE_rdata[28], ICACHE_rdata[27],
          ICACHE_rdata[26], ICACHE_rdata[25], ICACHE_rdata[24], ICACHE_rdata[23],
          ICACHE_rdata[22], ICACHE_rdata[21], ICACHE_rdata[20], ICACHE_rdata[19],
          ICACHE_rdata[18], ICACHE_rdata[17], ICACHE_rdata[16], ICACHE_rdata[15],
          ICACHE_rdata[14], ICACHE_rdata[13], ICACHE_rdata[12], ICACHE_rdata[11],
          ICACHE_rdata[10], ICACHE_rdata[9], ICACHE_rdata[8], ICACHE_rdata[7], ICACHE_rdata[6],
          ICACHE_rdata[5], ICACHE_rdata[4], ICACHE_rdata[3], ICACHE_rdata[2], ICACHE_rdata[1],
          ICACHE_rdata[0] }),
      .ICACHE_ren(ICACHE_ren),
      .ICACHE_wen(ICACHE_wen),
      .ICACHE_wdata({ ICACHE_wdata[31], ICACHE_wdata[30], ICACHE_wdata[29],
          ICACHE_wdata[28], ICACHE_wdata[27], ICACHE_wdata[26], ICACHE_wdata[25],
          ICACHE_wdata[24], ICACHE_wdata[23], ICACHE_wdata[22], ICACHE_wdata[21],
          ICACHE_wdata[20], ICACHE_wdata[19], ICACHE_wdata[18], ICACHE_wdata[17],
          ICACHE_wdata[16], ICACHE_wdata[15], ICACHE_wdata[14], ICACHE_wdata[13],
          ICACHE_wdata[12], ICACHE_wdata[11], ICACHE_wdata[10], ICACHE_wdata[9],
          ICACHE_wdata[8], ICACHE_wdata[7], ICACHE_wdata[6], ICACHE_wdata[5], ICACHE_wdata[4],
          ICACHE_wdata[3], ICACHE_wdata[2], ICACHE_wdata[1], ICACHE_wdata[0] }),
      .ICACHE_stall(ICACHE_stall),
      .DCACHE_addr({
          DCACHE_addr[31], DCACHE_addr[30], DCACHE_addr[29], DCACHE_addr[28], DCACHE_addr[27],
          DCACHE_addr[26], DCACHE_addr[25], DCACHE_addr[24], DCACHE_addr[23], DCACHE_addr[22],
          DCACHE_addr[21], DCACHE_addr[20], DCACHE_addr[19], DCACHE_addr[18], DCACHE_addr[17],
          DCACHE_addr[16], DCACHE_addr[15], DCACHE_addr[14], DCACHE_addr[13], DCACHE_addr[12],
          DCACHE_addr[11], DCACHE_addr[10], DCACHE_addr[9], DCACHE_addr[8], DCACHE_addr[7],
          DCACHE_addr[6], DCACHE_addr[5], DCACHE_addr[4], DCACHE_addr[3], DCACHE_addr[2],
          DCACHE_addr[1], DCACHE_addr[0] }),
      .DCACHE_rdata({ DCACHE_rdata[31], DCACHE_rdata[30],
          DCACHE_rdata[29], DCACHE_rdata[28], DCACHE_rdata[27], DCACHE_rdata[26],
          DCACHE_rdata[25], DCACHE_rdata[24], DCACHE_rdata[23], DCACHE_rdata[22],
          DCACHE_rdata[21], DCACHE_rdata[20], DCACHE_rdata[19], DCACHE_rdata[18],
          DCACHE_rdata[17], DCACHE_rdata[16], DCACHE_rdata[15], DCACHE_rdata[14],
          DCACHE_rdata[13], DCACHE_rdata[12], DCACHE_rdata[11], DCACHE_rdata[10],
          DCACHE_rdata[9], DCACHE_rdata[8], DCACHE_rdata[7], DCACHE_rdata[6], DCACHE_rdata[5],
          DCACHE_rdata[4], DCACHE_rdata[3], DCACHE_rdata[2], DCACHE_rdata[1], DCACHE_rdata[0]
          }),
      .DCACHE_ren(DCACHE_ren),
      .DCACHE_wen(DCACHE_wen),
      .DCACHE_wdata({ DCACHE_wdata[31], DCACHE_wdata[30], DCACHE_wdata[29], DCACHE_wdata[28],
          DCACHE_wdata[27], DCACHE_wdata[26], DCACHE_wdata[25], DCACHE_wdata[24],
          DCACHE_wdata[23], DCACHE_wdata[22], DCACHE_wdata[21], DCACHE_wdata[20],
          DCACHE_wdata[19], DCACHE_wdata[18], DCACHE_wdata[17], DCACHE_wdata[16],
          DCACHE_wdata[15], DCACHE_wdata[14], DCACHE_wdata[13], DCACHE_wdata[12],
          DCACHE_wdata[11], DCACHE_wdata[10], DCACHE_wdata[9], DCACHE_wdata[8], DCACHE_wdata[7],
          DCACHE_wdata[6], DCACHE_wdata[5], DCACHE_wdata[4], DCACHE_wdata[3], DCACHE_wdata[2],
          DCACHE_wdata[1], DCACHE_wdata[0] }),
      .DCACHE_stall(DCACHE_stall),
      .test_si(test_si),
      .test_so(test_so),
      .test_se(test_se)   );

   // STIL Direct Pattern Validate Access
   initial begin
      //
      // --- establish a default time format for %t
      //
      $timeformat(-9,2," ns",18);
      vector_number = 0;

      //
      // --- default verbosity to 0; use '+define+tmax_msg=N' on verilog compile line to change.
      //
      `ifdef tmax_msg
         verbose = `tmax_msg ;
      `else
         verbose = 0 ;
      `endif

      //
      // --- default pattern reporting interval is every 5 patterns;
      //     use '+define+tmax_rpt=N' on verilog compile line to change.
      //
      `ifdef tmax_rpt
         report_interval = `tmax_rpt ;
      `else
         report_interval = 5 ;
      `endif

      //
      // --- support generating Extened VCD output by using
      //     '+define+tmax_vcde' on verilog compile line.
      //
      `ifdef tmax_vcde
         // extended VCD, see Verilog specification, IEEE Std. 1364-2001 section 18.3
         if (verbose >= 1) $display("// %t : opening Extended VCD output file sim_vcde.vcd", $time);
         $dumpports( dut, "sim_vcde.vcd");
      `endif

      //
      // --- default miscompare messages are not formatted for TetraMAX diagnostics;
      //     use '+define+tmax_diag=N' on verilog compile line to format errors for diagnostics.
      //
      `ifdef tmax_diag
         diagnostic_msg = `tmax_diag ;
      `else
         diagnostic_msg = 0 ;
      `endif

      // '+define+tmax_parallel=N' on the command line overrides default simulation, using parallel load
      //   with N serial vectors at the end of each Shift
      // '+define+tmax_serial=M' on the command line forces M initial serial patterns,
      //   followed by the remainder in parallel (with N serial vectors if tmax_parallel is also specified)

      // +define+tmax_par_force_time on the command line overrides default parallel check/load time
      `ifdef tmax_par_force_time
         $STILDPV_parallel(,,,`tmax_par_force_time);
      `endif

      // TetraMAX parallel-mode simulation required for these patterns
      `ifdef tmax_parallel
         // +define+tmax_serial_timing on the command line overrides default minimal-time for parallel load behavior
         `ifdef tmax_serial_timing
         `else
            $STILDPV_parallel(,,0); // apply minimal time advance for parallel load_unload
            // if tmax_serial_timing is defined, use equivalent serial load_unload time advance
         `endif
         `ifdef tmax_serial
            $STILDPV_parallel(`tmax_parallel,`tmax_serial);
         `else
            $STILDPV_parallel(`tmax_parallel,0);
         `endif
      `else
         `ifdef tmax_serial
            // +define+tmax_serial_timing on the command line overrides default minimal-time for parallel load behavior
            `ifdef tmax_serial_timing
            `else
               $STILDPV_parallel(,,0); // apply minimal time advance for parallel load_unload
               // if tmax_serial_timing is defined, use equivalent serial load_unload time advance
            `endif
            $STILDPV_parallel(0,`tmax_serial);
         `else
            // default serial mode
         `endif
      `endif

      if (verbose>3)      $STILDPV_trace(1,1,1,1,1,report_interval,diagnostic_msg); // verbose=4; + trace each Vector
      else if (verbose>2) $STILDPV_trace(1,0,1,1,1,report_interval,diagnostic_msg); // verbose=3; + trace labels
      else if (verbose>1) $STILDPV_trace(0,0,1,1,1,report_interval,diagnostic_msg); // verbose=2; + trace WFT-changes
      else if (verbose>0) $STILDPV_trace(0,0,1,0,1,report_interval,diagnostic_msg); // verbose=1; + trace proc/macro entries
      else                $STILDPV_trace(0,0,0,0,0,report_interval,diagnostic_msg); // verbose=0; only pattern-interval

      $STILDPV_setup( "MIPS_Pipeline_syn_ATPG.stil",,,"MIPS_Pipeline_test.dut" );
      while ( !$STILDPV_done()) #($STILDPV_run( pattern_number, vector_number ));
      $display("Time %t: STIL simulation data completed.",$time);
      $finish; // comment this out if you terminate the simulation from other activities
   end

   // STIL Direct Pattern Validate Trace Options
   // The STILDPV_trace() function takes '1' to enable a trace and '0' to disable.
   // Unspecified arguments maintain their current state. Tracing may be changed at any time.
   // The following arguments control tracing of:
   // 1st argument: enable or disable tracing of all STIL labels
   // 2nd argument: enable or disable tracing of each STIL Vector and current Vector count
   // 3rd argument: enable or disable tracing of each additional Thread (new Pattern)
   // 4th argument: enable or disable tracing of each WaveformTable change
   // 5th argument: enable or disable tracing of each Procedure or Macro entry
   // 6th argument: interval to print starting pattern messages; 0 to disable
   // For example, a separate initial block may be used to control these options
   // (uncomment and change time values to use):
   // initial begin
   //    #800000 $STILDPV_trace(1,1);
   //    #600000 $STILDPV_trace(,0);
   // Additional calls to $STILDPV_parallel() may also be defined to change parallel/serial
   // operation during simulation. Any additional calls need a # time value.
   // 1st integer is number of serial (flat) cycles to simulate at end of each shift
   // 2nd integer is TetraMAX pattern number (starting at zero) to start parallel load
   // 3rd optional value '1' will advance time during the load_unload the same as a serial
   //     shift operation (with no events during that time), '0' will advance minimal time
   //     (1 shift vector) during the parallel load_unload.
   // For example,
   //    #8000 $STILDPV_parallel( 2,10 );
   // end // of initial block with additional trace/parallel options
endmodule
