// Instruction Decode Pipeline Stage
module id_stage 
import rv32imc_types::*;
(
  // Synchronous Signals
  input  logic clk, rst,

  // Control/Datapath Signals
  input  logic        i_regf_we,
  input  logic [4:0]  i_rd_addr,
  input  logic [31:0] i_rd_wdata,

  // Flush Signals
  input  logic i_flush,

  // Stall Signals
  input  logic id_reg_we,
  output logic imem_ready,
  output logic o_id_reg_we,
  output logic o_pc_we,

  // Instruction Memory Ports
  input  logic [3:0]  imem_rmask,
  input  logic [31:0] imem_rdata,
  input  logic        imem_resp,

  // Pipeline Stage Registers
  input  if_stage_t if_stage_reg,
  output id_stage_t id_stage_reg
);

// Signal indicating if instruction memory is ready
logic imem_valid;
logic imem_valid_probe;
always_ff @(posedge clk) begin
  if (rst || id_reg_we) begin
    imem_valid_probe <= '0;
  end else if (imem_resp) begin
    // Probe should stay high if other stalls occur (i.e !id_reg_we)
    imem_valid_probe <= !id_reg_we;
  end
end

// Instruction memory is ready during a response or probe signal is high
assign imem_valid = imem_resp ? 1'b1 : imem_valid_probe;

// Signal indicating we are not reading from instruction memory
logic ready_valid;
logic ready_valid_probe;
always_ff @(posedge clk) begin
  if (rst || imem_valid) begin
    ready_valid_probe <= 1'b1;
  end else if (|imem_rmask) begin
    ready_valid_probe <= '0;
  end
end
assign ready_valid = (|imem_rmask) ? 1'b0 : ready_valid_probe;

// Instruction memory is ready during a response or probe signal is high
assign imem_ready = imem_valid | ready_valid;

// Branch Flush Logic
logic i_flush_dff;
always_ff @(posedge clk) begin
  if (rst) begin
    i_flush_dff <= '0;
  end else if (id_reg_we) begin
    i_flush_dff <= i_flush;
  end
end

// Instruction Stall Logic
logic [31:0] inst, inst_dff;
always_ff @(posedge clk) begin
  if (rst) begin
    inst_dff <= '0;
  end else begin
    inst_dff <= inst;
  end
end 

// Signal indicating if the current cycle is after a stall cycle (i.e !id_reg_we_dff)
logic id_reg_we_dff; 
always_ff @(posedge clk) begin
  if (rst) begin
    id_reg_we_dff <= '1;
  end else if (id_reg_we) begin
    id_reg_we_dff <= o_id_reg_we;
  end
end 

// Current instruction logic
always_comb begin
  if (i_flush_dff) begin
    inst = 'h13;
  end else if (!id_reg_we_dff) begin
    inst = inst_dff;
  end else begin
    inst = imem_resp ? imem_rdata : inst_dff;
  end
end

// Control Unit
logic [4:0]   rs1_addr, rs2_addr, rd_addr;
logic [31:0]  o_imm;
ex_ctrl_t     ex_ctrl, o_ex_ctrl;
mem_ctrl_t    mem_ctrl, o_mem_ctrl;
wb_ctrl_t     wb_ctrl, o_wb_ctrl;
control_unit control_unit (
  .inst(inst),
  .o_rs1_addr(rs1_addr),
  .o_rs2_addr(rs2_addr),
  .o_rd_addr(rd_addr),
  .o_imm(o_imm),
  .ex_ctrl(o_ex_ctrl),
  .mem_ctrl(o_mem_ctrl),
  .wb_ctrl(o_wb_ctrl)
);

// Register File
logic [31:0] rs1_rdata, rs2_rdata;
regfile #(
  .NUM_REGS(32)
) regfile (
  .clk(clk),
  .rst(rst),
  .regf_we(i_regf_we),
  .rd_wdata(i_rd_wdata),
  .rs1_addr(rs1_addr),
  .rs2_addr(rs2_addr),
  .rd_addr(i_rd_addr),
  .rs1_rdata(rs1_rdata),
  .rs2_rdata(rs2_rdata)
);

// Hazard Detection Unit
ctrl_mux_t ctrl_mux;
detection_unit detection_unit (
  .id_mem_read(id_stage_reg.mem_ctrl.mem_read),
  .ex_rd_addr(id_stage_reg.rd_addr),
  .rs1_addr(rs1_addr),
  .rs2_addr(rs2_addr),
  .ctrl_mux(ctrl_mux),
  .id_reg_we(o_id_reg_we),
  .pc_we(o_pc_we)
);

// Control stall mux
always_comb begin
  ex_ctrl  = (ctrl_mux == stall_out) ? '0 : o_ex_ctrl;
  mem_ctrl = (ctrl_mux == stall_out) ? '0 : o_mem_ctrl;
  wb_ctrl  = (ctrl_mux == stall_out) ? '0 : o_wb_ctrl;
end

// RVFI Order Logic
logic [63:0] order;
always_ff @(posedge clk) begin
  if (rst) begin
    order <= '0;
  end 
  // Order unchanged if branch taken or instruction stalls
  else if (!o_id_reg_we || (i_flush && id_reg_we) || i_flush_dff) begin
    order <= order;
  end
  else if (if_stage_reg.rvfi.valid && id_reg_we) begin
    order <= order + 1'b1;
  end
end

logic valid;
assign valid = (!o_id_reg_we) ? 1'b0 : if_stage_reg.rvfi.valid;

// Latch to Pipeline Registers
always_ff @(posedge clk) begin
  // Flush stage during reset, stall cycle, or either flush cycle
  if (rst || (i_flush && id_reg_we) || i_flush_dff) begin
    id_stage_reg.pc         <= '0;
    id_stage_reg.pc_next    <= '0;
    id_stage_reg.rs1_addr   <= '0;
    id_stage_reg.rs2_addr   <= '0;
    id_stage_reg.rd_addr    <= '0;
    id_stage_reg.imm        <= '0;
    id_stage_reg.rs1_rdata  <= '0;
    id_stage_reg.rs2_rdata  <= '0;
    id_stage_reg.ex_ctrl    <= '0;
    id_stage_reg.mem_ctrl   <= '0;
    id_stage_reg.wb_ctrl    <= '0;
    id_stage_reg.rvfi       <= '0;
  end else if (id_reg_we) begin
    // Latch Program Counters
    id_stage_reg.pc      <= if_stage_reg.pc;
    id_stage_reg.pc_next <= if_stage_reg.pc_next;

    // Latch Immediate Value
    id_stage_reg.imm <= o_imm;

    // Latch Register File Data
    id_stage_reg.rs1_addr <= rs1_addr;
    id_stage_reg.rs2_addr <= rs2_addr;
    id_stage_reg.rd_addr <= rd_addr;
    id_stage_reg.rs1_rdata <= rs1_rdata;
    id_stage_reg.rs2_rdata <= rs2_rdata;

    // Latch Control Signals
    id_stage_reg.ex_ctrl  <= ex_ctrl;
    id_stage_reg.mem_ctrl <= mem_ctrl;
    id_stage_reg.wb_ctrl  <= wb_ctrl;

    // Latch RVFI Signals
    id_stage_reg.rvfi.valid     <= valid;
    id_stage_reg.rvfi.order     <= order;
    id_stage_reg.rvfi.inst      <= inst;
    id_stage_reg.rvfi.rs1_addr  <= rs1_addr;
    id_stage_reg.rvfi.rs2_addr  <= rs2_addr;
    id_stage_reg.rvfi.rs1_rdata <= rs1_rdata;
    id_stage_reg.rvfi.rs2_rdata <= rs2_rdata;
    id_stage_reg.rvfi.rd_addr   <= rd_addr;
    id_stage_reg.rvfi.pc_rdata  <= if_stage_reg.rvfi.pc_rdata;
    id_stage_reg.rvfi.pc_wdata  <= if_stage_reg.rvfi.pc_wdata;
  end
end

endmodule : id_stage