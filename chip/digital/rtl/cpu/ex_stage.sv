// Execute Pipeline Stage
module ex_stage 
import rv32imc_types::*;
(
  // Synchronous Signals
  input  logic clk, rst,

  // Datapath Signals
  output pc_mux_t     o_pc_mux,
  output logic [31:0] o_pc_imm,

  // Stall Signals
  input  logic ex_reg_we,

  // Flush Signals
  output logic o_flush,

  // Writeback Signal
  input  logic [31:0] i_wb_data,

  // Pipeline Stage Registers
  input  id_stage_t id_stage_reg,
  input  mem_stage_t mem_stage_reg,
  output ex_stage_t ex_stage_reg
);

// Forwarding Unit
a_forward_mux_t forward_a;
b_forward_mux_t forward_b;
forwarding_unit forwarding_unit (
  .rs1_addr    (id_stage_reg.rs1_addr),
  .rs2_addr    (id_stage_reg.rs2_addr),
  .ex_rd_addr  (ex_stage_reg.rd_addr),
  .mem_rd_addr (mem_stage_reg.rd_addr),
  .ex_regf_we  (ex_stage_reg.wb_ctrl.regf_we),
  .mem_regf_we (mem_stage_reg.wb_ctrl.regf_we),
  .forward_a   (forward_a),
  .forward_b   (forward_b)
);

// ALU Source Operands
logic [31:0] a, b;
logic [31:0] forward_a_op, forward_b_op;
always_comb begin
  // Default Values
  a = '0; forward_a_op = '0;
  b = '0; forward_b_op = '0;

  // Forwarding ALU Values
  if (forward_a == a_ex_source) begin
    forward_a_op = ex_stage_reg.alu_out;
  end else if (forward_a == a_mem_source) begin
    forward_a_op = i_wb_data;
  end else begin
    forward_a_op = id_stage_reg.rs1_rdata;
  end

  if (forward_b == b_ex_source) begin
    forward_b_op = ex_stage_reg.alu_out;
  end else if (forward_b == b_mem_source) begin
    forward_b_op = i_wb_data;
  end else begin
    forward_b_op = id_stage_reg.rs2_rdata;
  end
  
  // Decoded ALU Values
  if (id_stage_reg.ex_ctrl.alu1_mux == pc_out) begin
    a = id_stage_reg.pc;
  end else begin
    a = forward_a_op;
  end

  if (id_stage_reg.ex_ctrl.alu2_mux == imm_out) begin
    b = id_stage_reg.imm;
  end else begin
    b = forward_b_op;
  end
end

// Arithmetic Logic Unit
logic [31:0] f;
alu alu (
  .a       (a),
  .b       (b),
  .alu_op  (id_stage_reg.ex_ctrl.alu_op),
  .f       (f)
);

// Comparator
logic br_en;
cmp cmp (
  .a (a),
  .b (b),
  .cmp_op (id_stage_reg.ex_ctrl.cmp_op),
  .br_en (br_en)
);

// ALU Output Logic
logic [31:0] alu_out;
always_comb begin
  if (id_stage_reg.ex_ctrl.aluout_mux == cmp_out) begin
    alu_out = {31'd0, br_en};
  end else if (id_stage_reg.ex_ctrl.aluout_mux == addr_out) begin
    alu_out = id_stage_reg.pc + 'h4;
  end else begin
    alu_out = f;
  end
end

// Branch Logic
logic [31:0] target_op, target_addr, pc_imm;
always_comb begin
  target_op = (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? forward_a_op : id_stage_reg.pc;
  target_addr = target_op + id_stage_reg.imm;
  
  pc_imm <= (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? (target_addr & 32'hfffffffe) : (target_addr);
end

always_ff @(posedge clk) begin
  if (ex_reg_we) begin
    o_pc_mux <= (id_stage_reg.ex_ctrl.branch & br_en) ? (pc_offset) : (pc_next);
    o_pc_imm <= (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? (target_addr & 32'hfffffffe) : (target_addr);
  end
end

// Branch Flush Logic
assign o_flush = id_stage_reg.ex_ctrl.branch & br_en;

// Latch to Pipeline Registers
always_ff @(posedge clk) begin
  if (rst) begin
    // Reset Pipeline Registers
    ex_stage_reg.pc_next   <= '0;
    ex_stage_reg.alu_out   <= '0;
    ex_stage_reg.rs2_rdata <= '0;
    ex_stage_reg.rd_addr   <= '0;
    ex_stage_reg.mem_ctrl  <= '0;
    ex_stage_reg.wb_ctrl   <= '0;
    ex_stage_reg.rvfi      <= '0;
  end else if (ex_reg_we) begin
    // Latch Data Signals
    ex_stage_reg.alu_out   <= alu_out;
    ex_stage_reg.rs2_rdata <= forward_b_op;
    ex_stage_reg.rd_addr   <= id_stage_reg.rd_addr;

    // Latch Control Signals
    ex_stage_reg.mem_ctrl <= id_stage_reg.mem_ctrl;
    ex_stage_reg.wb_ctrl  <= id_stage_reg.wb_ctrl;

    // Latch RVFI Signals
    ex_stage_reg.rvfi.valid     <= id_stage_reg.rvfi.valid;
    ex_stage_reg.rvfi.order     <= id_stage_reg.rvfi.order;
    ex_stage_reg.rvfi.inst      <= id_stage_reg.rvfi.inst;
    ex_stage_reg.rvfi.rs1_addr  <= id_stage_reg.rvfi.rs1_addr;
    ex_stage_reg.rvfi.rs2_addr  <= id_stage_reg.rvfi.rs2_addr;
    ex_stage_reg.rvfi.rs1_rdata <= forward_a_op;
    ex_stage_reg.rvfi.rs2_rdata <= forward_b_op;
    ex_stage_reg.rvfi.rd_addr   <= id_stage_reg.rvfi.rd_addr;
    ex_stage_reg.rvfi.pc_rdata  <= id_stage_reg.rvfi.pc_rdata;
    ex_stage_reg.rvfi.pc_wdata  <= (id_stage_reg.ex_ctrl.branch & br_en) ? pc_imm : id_stage_reg.rvfi.pc_wdata;
  end
end

endmodule : ex_stage