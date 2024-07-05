<<<<<<<< HEAD:mp_pipeline/hvl/mem_itf.sv
interface mem_itf(
========
interface banked_mem_itf(
>>>>>>>> 9181244 (mp_ooo patch2):mp_ooo/hvl/banked_mem_itf.sv
    input   bit         clk,
    input   bit         rst
);

    logic   [31:0]      addr;
<<<<<<<< HEAD:mp_pipeline/hvl/mem_itf.sv
    logic   [3:0]       rmask;
    logic   [3:0]       wmask;
    logic   [31:0]      rdata;
    logic   [31:0]      wdata;
    logic               resp;
========
    logic               read;
    logic               write;
    logic   [63:0]      wdata;
    logic               ready;

    logic   [31:0]      raddr;
    logic   [63:0]      rdata;
    logic               rvalid;
>>>>>>>> 9181244 (mp_ooo patch2):mp_ooo/hvl/banked_mem_itf.sv

    bit                 error = 1'b0;

    modport dut (
        input           clk,
        input           rst,

        output          addr,
<<<<<<<< HEAD:mp_pipeline/hvl/mem_itf.sv
        output          rmask,
        output          wmask,
        input           rdata,
========
        output          read,
        output          write,
>>>>>>>> 9181244 (mp_ooo patch2):mp_ooo/hvl/banked_mem_itf.sv
        output          wdata,
        input           ready,

        input           raddr,
        input           rdata,
        input           rvalid
    );

    modport mem (
        input           clk,
        input           rst,

        input           addr,
<<<<<<<< HEAD:mp_pipeline/hvl/mem_itf.sv
        input           rmask,
        input           wmask,
        output          rdata,
========
        input           read,
        input           write,
>>>>>>>> 9181244 (mp_ooo patch2):mp_ooo/hvl/banked_mem_itf.sv
        input           wdata,
        output          ready,

        output          rdata,
        output          raddr,
        output          rvalid,

        output          error
    );

    modport mon (
        input           clk,
        input           rst,

        input           addr,
<<<<<<<< HEAD:mp_pipeline/hvl/mem_itf.sv
        input           rmask,
        input           wmask,
        input           rdata,
========
        input           read,
        input           write,
>>>>>>>> 9181244 (mp_ooo patch2):mp_ooo/hvl/banked_mem_itf.sv
        input           wdata,
        input           ready,

        input           rdata,
        input           raddr,
        input           rvalid,

        input           error
    );

endinterface
