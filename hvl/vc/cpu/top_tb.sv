// Toggle Test Types
// `define CONSTRAINED_RANDOM  // Comment out for directed tests

`ifdef CONSTRAINED_RANDOM
    `include "cpu_pkg.svh"
`endif

module top_tb;
    timeunit 1ps;
    timeprecision 1ps;

    // UVM Imports
    `ifdef CONSTRAINED_RANDOM
        import uvm_pkg::*;
        `include "uvm_macros.svh"
    `endif

    // Clock Generation
    `define CLK_HALF_PERIOD (5)
    bit clk;
    always #(`CLK_HALF_PERIOD) clk = ~clk;

    bit rst;

    // Memory Interface
    mem_itf mem_itf_i(.clk(clk), .rst(rst));
    mem_itf mem_itf_d(.clk(clk), .rst(rst));

    // Monitor Interface
    mon_itf mon_itf(.*);    
    monitor monitor(.itf(mon_itf));

    // Test Suite
    `ifdef CONSTRAINED_RANDOM
        initial begin
            // UVM Constrained Random Tests
            uvm_config_db #(virtual mem_itf)::set(null, "*", "mem_itf_i", mem_itf_i);
            uvm_config_db #(virtual mem_itf)::set(null, "*", "mem_itf_d", mem_itf_d);
            run_test();
        end
    `else
        // Memory Types for Directed Test
        // magic_dual_port mem(.itf_i(mem_itf_i), .itf_d(mem_itf_d));
        ordinary_dual_port mem(.itf_i(mem_itf_i), .itf_d(mem_itf_d));
    `endif

    // DUT Instantiation
    cpu dut(
        .clk            (clk),
        .rst            (rst),

        // Instruction Memory Port
        .imem_addr      (mem_itf_i.addr),
        .imem_rmask     (mem_itf_i.rmask),
        .imem_rdata     (mem_itf_i.rdata),
        .imem_resp      (mem_itf_i.resp),

        // Data Memory Port
        .dmem_addr      (mem_itf_d.addr),
        .dmem_rmask     (mem_itf_d.rmask),
        .dmem_wmask     (mem_itf_d.wmask),
        .dmem_rdata     (mem_itf_d.rdata),
        .dmem_wdata     (mem_itf_d.wdata),
        .dmem_resp      (mem_itf_d.resp)
    );

    // Monitor Interface DUT Wiring
    `include "../../hvl/rvfi_reference.svh"

    // Waveform Dumpfiles and Reset
    initial begin
        $fsdbDumpfile("dump.fsdb");
        $fsdbDumpvars(0, "+all");
        rst = 1'b1;
        repeat (2) @(posedge clk);
        rst <= 1'b0;
    end

    // End Condition
    int timeout_cycles = 10000000;
    always @(posedge clk) begin
        if (mon_itf.halt) begin
            $finish;
        end
        if (timeout_cycles == 0) begin
            $error("TB Error: Timed out");
            $finish;
        end
        if (mon_itf.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        if (mem_itf_i.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        if (mem_itf_d.error != 0) begin
            repeat (5) @(posedge clk);
            $finish;
        end
        timeout_cycles <= timeout_cycles - 1;
    end
endmodule : top_tb


// import "DPI-C" function string getenv(input string env_name);

// module top_tb;
//     timeunit 1ps;
//     timeprecision 1ps;

//     import rv32i_types::*;
//     int clock_half_period_ps = getenv("ECE411_CLOCK_PERIOD_PS").atoi() / 2;

//     bit clk;
//     always #(clock_half_period_ps) clk = ~clk;

//     bit rst;

//     int timeout = 5000000; // in cycles, change according to your needs

//     banked_mem_itf bmem_itf(.*);
//     banked_memory mem(.itf(bmem_itf));
//     // random_banked_memory random_banked_memory(.itf(bmem_itf));

//     mon_itf mon_itf(.*);
//     monitor monitor(.itf(mon_itf));

//     cpu dut(
//         .clk            (clk),
//         .rst            (rst),

//         .bmem_addr      (bmem_itf.addr),
//         .bmem_read      (bmem_itf.read),
//         .bmem_write     (bmem_itf.write),
//         .bmem_wdata     (bmem_itf.wdata),
//         .bmem_ready     (bmem_itf.ready),

//         .bmem_raddr     (bmem_itf.raddr),
//         .bmem_rdata     (bmem_itf.rdata),
//         .bmem_rvalid    (bmem_itf.rvalid)
//     );

//     // Signal for Scalar RVFI Interface
//     rvfi_signal_t scalar_itf;
//     assign scalar_itf = dut.backend0.commit0.monitor;

//     `include "../../hvl/rvfi_reference.svh"

//     initial begin
//         $fsdbDumpfile("dump.fsdb");
//         $fsdbDumpvars(0, "+all");
//         rst = 1'b1;
//         repeat (2) @(posedge clk);
//         rst <= 1'b0;
//     end

//     always @(posedge clk) begin
//         for (int unsigned i=0; i < 8; ++i) begin
//             if (mon_itf.halt[i]) begin
//                 //$display("Branch Misses: %0d", dut.frontend0.branch_misses);
//                 //$display("Branch Hits: %0d", dut.frontend0.branch_hits);
//                 //$display("Wrong Guesses: %0d", dut.frontend0.num_wrong_guesses);
//                 //$display("Wrong Guess Addresses: %0d", dut.frontend0.num_wrong_guess_addrs);
//                 //$display("Flush Count: %0d", dut.frontend0.num_flushes);

//                 //$display("============ PREFETCH METRICS ============");
//                 //$display("Prefetch Hits: %0d", dut.cache_line0.prefetch_hits);
//                 //$display("Prefetch Misses: %0d", dut.cache_line0.prefetch_misses);
//                 //$display("Number Icycle Waits: %0d", dut.cache_line0.num_icache_wait_cycles);
//                 //$display("Number Dcycle Waits: %0d", dut.cache_line0.num_dcache_wait_cycles);
//                 $finish;
//             end
//         end
//         if (timeout == 0) begin
//             $error("TB Error: Timed out");
//             $finish;
//         end
//         if (mon_itf.error != 0) begin
//             repeat (5) @(posedge clk);
//             $finish;
//         end
//         // if (mem_itf_i.error != 0) begin
//         //     repeat (5) @(posedge clk);
//         //     $finish;
//         // end
//         // if (mem_itf_d.error != 0) begin
//         //     repeat (5) @(posedge clk);
//         //     $finish;
//         // end
//         if (bmem_itf.error != 0) begin
//             repeat (5) @(posedge clk);
//             $finish;
//         end
//         timeout <= timeout - 1;
//     end

// endmodule