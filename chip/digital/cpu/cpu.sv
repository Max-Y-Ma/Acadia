module cpu 
import rv32i_types::*;
(
    input  logic        clk,
    input  logic        rst,

    output logic [31:0] imem_addr,
    output logic [3:0]  imem_rmask,
    input  logic [31:0] imem_rdata,
    input  logic        imem_resp,

    output logic [31:0] dmem_addr,
    output logic [3:0]  dmem_rmask,
    output logic [3:0]  dmem_wmask,
    input  logic [31:0] dmem_rdata,
    output logic [31:0] dmem_wdata,
    input  logic        dmem_resp
);
    
    // Pipeline Stages
    if_stage_t  if_stage_reg;
    id_stage_t  id_stage_reg;
    ex_stage_t  ex_stage_reg;
    mem_stage_t mem_stage_reg;
    wb_stage_t  wb_stage_reg;

    // Stall Signals and Logic
    logic i_id_reg_we;
    logic i_pc_we;

    // Flush Signals
    logic i_flush;
    
    // Indicates that instruction memory has finished reading
    // This signal stays high until the stall cycles complete
    logic imem_ready;   
    
    // Indicates that data memory has finished reading or writing
    // This signal stays high until the stall cycles complete
    logic dmem_ready;

    // Combinational write enable signals
    logic if_reg_we; 
    logic id_reg_we; 
    logic ex_reg_we; 
    logic mem_reg_we;
    logic wb_reg_we; 
    assign if_reg_we = i_id_reg_we & i_pc_we & !i_flush & imem_ready & dmem_ready;
    assign id_reg_we = imem_ready & dmem_ready;
    assign ex_reg_we = imem_ready & dmem_ready;
    assign mem_reg_we = imem_ready & dmem_ready;
    assign wb_reg_we = imem_ready & dmem_ready;

    pc_mux_t     i_pc_mux;
    logic [31:0] i_pc_imm;
    if_stage if_stage (
        .clk          (clk),
        .rst          (rst),
        .i_pc_mux     (i_pc_mux),
        .i_pc_imm     (i_pc_imm),
        .if_reg_we    (if_reg_we),
        .imem_resp    (imem_resp),
        .imem_addr    (imem_addr),
        .imem_rmask   (imem_rmask),
        .if_stage_reg (if_stage_reg)
    );

    logic        i_regf_we;
    logic [4:0]  i_rd_addr;
    logic [31:0] i_write_data;
    id_stage id_stage (
        .clk           (clk),
        .rst           (rst),
        .i_regf_we     (i_regf_we),
        .i_rd_addr     (i_rd_addr),
        .i_rd_wdata    (i_write_data),
        .i_flush       (i_flush),
        .id_reg_we     (id_reg_we),
        .imem_ready    (imem_ready),
        .o_id_reg_we   (i_id_reg_we),
        .o_pc_we       (i_pc_we),
        .imem_rmask    (imem_rmask),
        .imem_rdata    (imem_rdata),
        .imem_resp     (imem_resp),
        .if_stage_reg  (if_stage_reg),
        .id_stage_reg  (id_stage_reg)
    );

    ex_stage ex_stage (
        .clk           (clk),
        .rst           (rst),
        .o_pc_mux      (i_pc_mux),
        .o_pc_imm      (i_pc_imm),
        .ex_reg_we     (ex_reg_we),
        .o_flush       (i_flush),
        .i_wb_data     (i_write_data),
        .id_stage_reg  (id_stage_reg),
        .mem_stage_reg (mem_stage_reg),
        .ex_stage_reg  (ex_stage_reg)
    );

    mem_stage mem_stage (
        .clk           (clk),
        .rst           (rst),
        .mem_reg_we    (mem_reg_we),
        .dmem_addr     (dmem_addr),
        .dmem_rmask    (dmem_rmask),
        .dmem_wmask    (dmem_wmask),
        .dmem_wdata    (dmem_wdata),
        .ex_stage_reg  (ex_stage_reg),
        .mem_stage_reg (mem_stage_reg)
    );

    wb_stage wb_stage (
        .clk           (clk),
        .rst           (rst),
        .o_regf_we     (i_regf_we),
        .o_rd_addr     (i_rd_addr),
        .o_write_data  (i_write_data),
        .wb_reg_we     (wb_reg_we),
        .dmem_ready    (dmem_ready),
        .dmem_rdata    (dmem_rdata),
        .dmem_rmask    (dmem_rmask),
        .dmem_wmask    (dmem_wmask),
        .dmem_resp     (dmem_resp),
        .mem_stage_reg (mem_stage_reg),
        .wb_stage_reg  (wb_stage_reg)
    );

    // RVFI Specific Signals
    logic        monitor_valid;
    logic [63:0] monitor_order;
    logic [31:0] monitor_inst;
    logic [4:0]  monitor_rs1_addr;
    logic [4:0]  monitor_rs2_addr;
    logic [31:0] monitor_rs1_rdata;
    logic [31:0] monitor_rs2_rdata;
    logic        monitor_regf_we;
    logic [4:0]  monitor_rd_addr;
    logic [31:0] monitor_rd_wdata;
    logic [31:0] monitor_pc_rdata;
    logic [31:0] monitor_pc_wdata;
    logic [31:0] monitor_mem_addr;
    logic [3:0]  monitor_mem_rmask;
    logic [3:0]  monitor_mem_wmask;
    logic [31:0] monitor_mem_rdata;
    logic [31:0] monitor_mem_wdata;

    // RVFI Valid Logic
    logic new_order;
    logic [63:0] rvfi_order_probe;
    always_ff @(posedge clk) begin
        if (rst) begin
            rvfi_order_probe <= '1;
        end else if (wb_stage_reg.rvfi.valid) begin
            rvfi_order_probe <= wb_stage_reg.rvfi.order;
        end
    end
    assign new_order = (rvfi_order_probe == wb_stage_reg.rvfi.order);

    assign monitor_valid     = wb_stage_reg.rvfi.valid && !new_order;
    assign monitor_order     = wb_stage_reg.rvfi.order;
    assign monitor_inst      = wb_stage_reg.rvfi.inst;
    assign monitor_rs1_addr  = wb_stage_reg.rvfi.rs1_addr;
    assign monitor_rs2_addr  = wb_stage_reg.rvfi.rs2_addr;
    assign monitor_rs1_rdata = wb_stage_reg.rvfi.rs1_rdata;
    assign monitor_rs2_rdata = wb_stage_reg.rvfi.rs2_rdata;
    assign monitor_rd_addr   = wb_stage_reg.rvfi.rd_addr;
    assign monitor_rd_wdata  = wb_stage_reg.rvfi.rd_wdata;
    assign monitor_pc_rdata  = wb_stage_reg.rvfi.pc_rdata;
    assign monitor_pc_wdata  = wb_stage_reg.rvfi.pc_wdata;
    assign monitor_mem_addr  = wb_stage_reg.rvfi.mem_addr;
    assign monitor_mem_rmask = wb_stage_reg.rvfi.mem_rmask;
    assign monitor_mem_wmask = wb_stage_reg.rvfi.mem_wmask;
    assign monitor_mem_rdata = wb_stage_reg.rvfi.mem_rdata;
    assign monitor_mem_wdata = wb_stage_reg.rvfi.mem_wdata;

endmodule : cpu
