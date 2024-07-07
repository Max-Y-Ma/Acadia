// Instruction Fetch Pipeline Stage
module if_stage 
import rv32imc_types::*;
(
  // Synchronous Signals
  input  logic        clk, rst,

  // Control/Datapath Signals
  input  pc_mux_t     i_pc_mux,
  input  logic [31:0] i_pc_imm,

  // Stall Signals
  input  logic        if_reg_we,

  // Instruction Memory Ports
  input  logic        imem_resp,
  output logic [31:0] imem_addr,
  output logic [3:0]  imem_rmask,

  // Pipeline Stage Registers
  output if_stage_t if_stage_reg
);

// Program Counter
logic [31:0] pc;
logic [31:0] pc_next;
always_ff @(posedge clk) begin
  if (rst) begin
    pc <= 32'h60000000;
  end else if (if_reg_we) begin
    pc <= pc_next;
  end else begin
    pc <= pc;
  end
end

// Program Counter Logic
assign pc_next = (i_pc_mux == pc_offset) ? (i_pc_imm) : (pc + 'd4);

// We only want to read from instruction memory once, despite stall cycles
logic imem_rmask_re;
always_ff @(posedge clk) begin
  // We are allowed to read after a reset or non-stall cycle
  if (rst || if_reg_we) begin
    imem_rmask_re <= 1'b1;
  end 
  // We are not allowed to read on stall cycles
  else begin
    imem_rmask_re <= 1'b0;
  end
end

// Instruction Memory Logic
assign imem_addr = (if_reg_we) ? pc_next : pc;

// Assert read mask on read enable cycle
assign imem_rmask = (imem_rmask_re || imem_resp) ? 4'hF : 4'b0;

// Latch to Pipeline Registers
always_ff @(posedge clk) begin
  if (rst) begin
    // Reset Pipeline Registers
    if_stage_reg.pc      <= '0;
    if_stage_reg.pc_next <= '0;
    if_stage_reg.rvfi    <= '0;
  end else begin
    // Latch Program Counters
    if_stage_reg.pc      <= imem_addr;
    if_stage_reg.pc_next <= (imem_addr + 'd4);

    // Latch RVFI Signals
    if_stage_reg.rvfi.valid    <= 1'b1;
    if_stage_reg.rvfi.pc_rdata <= imem_addr;
    if_stage_reg.rvfi.pc_wdata <= (imem_addr + 'd4);
  end
end

endmodule : if_stage