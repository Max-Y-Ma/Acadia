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
forward_mux_t fwd_src_a;
forward_mux_t fwd_src_b;
forwarding_unit forwarding_unit (
  .rs1_addr    (id_stage_reg.rs1_addr),
  .rs2_addr    (id_stage_reg.rs2_addr),
  .ex_rd_addr  (ex_stage_reg.rd_addr),
  .mem_rd_addr (mem_stage_reg.rd_addr),
  .ex_regf_we  (ex_stage_reg.wb_ctrl.regf_we),
  .mem_regf_we (mem_stage_reg.wb_ctrl.regf_we),
  .fwd_src_a   (fwd_src_a),
  .fwd_src_b   (fwd_src_b)
);

// ALU Source Operands
logic [31:0] a, b;
logic [31:0] fwd_src_a_data, fwd_src_b_data;
always_comb begin
  // Default Values
  a = '0; fwd_src_a_data = '0;
  b = '0; fwd_src_b_data = '0;

  // Assign RS1 data based on forwarding unit
  if (fwd_src_a == ex_source) begin
    fwd_src_a_data = ex_stage_reg.alu_out;
  end 
  else if (fwd_src_a == mem_source) begin
    fwd_src_a_data = i_wb_data;
  end 
  else begin
    fwd_src_a_data = id_stage_reg.rs1_rdata;
  end

  // Assign RS2 data based on forwarding unit
  if (fwd_src_b == ex_source) begin
    fwd_src_b_data = ex_stage_reg.alu_out;
  end 
  else if (fwd_src_b == mem_source) begin
    fwd_src_b_data = i_wb_data;
  end 
  else begin
    fwd_src_b_data = id_stage_reg.rs2_rdata;
  end
  
  // Operand multiplexers
  if (id_stage_reg.ex_ctrl.alu1_mux == pc_out) begin
    a = id_stage_reg.pc;
  end 
  else begin
    a = fwd_src_a_data;
  end

  if (id_stage_reg.ex_ctrl.alu2_mux == imm_out) begin
    b = id_stage_reg.imm;
  end 
  else begin
    b = fwd_src_b_data;
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
  end 
  else if (id_stage_reg.ex_ctrl.aluout_mux == addr_out) begin
    alu_out = id_stage_reg.pc + 'h4;
  end 
  else begin
    alu_out = f;
  end
end

// Branch Logic
logic  branch_taken;
assign branch_taken = id_stage_reg.ex_ctrl.branch & br_en;

logic [31:0] target_op, target_addr, pc_imm;
always_comb begin
  target_op = (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? fwd_src_a_data : id_stage_reg.pc;
  target_addr = target_op + id_stage_reg.imm;
  
  pc_imm <= (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? (target_addr & 32'hfffffffe) : (target_addr);
end

always_ff @(posedge clk) begin
  if (ex_reg_we) begin
    o_pc_mux <= branch_taken ? pc_offset : pc_next;
    o_pc_imm <= (id_stage_reg.ex_ctrl.target_addr_mux == rs1_op) ? (target_addr & 32'hfffffffe) : (target_addr);
  end
end

// Branch Flush Logic
assign o_flush = branch_taken;

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
    ex_stage_reg.rs2_rdata <= fwd_src_b_data;
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
    ex_stage_reg.rvfi.rs1_rdata <= fwd_src_a_data;
    ex_stage_reg.rvfi.rs2_rdata <= fwd_src_b_data;
    ex_stage_reg.rvfi.rd_addr   <= id_stage_reg.rvfi.rd_addr;
    ex_stage_reg.rvfi.pc_rdata  <= id_stage_reg.rvfi.pc_rdata;
    ex_stage_reg.rvfi.pc_wdata  <= branch_taken ? pc_imm : id_stage_reg.rvfi.pc_wdata;
  end
end

endmodule : ex_stage