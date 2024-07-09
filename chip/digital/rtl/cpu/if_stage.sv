// Instruction Fetch Pipeline Stage
module if_stage 
import rv32imc_types::*;
(
  // Synchronous Signals
  input  logic clk, rst,

  // Control/Datapath Signals
  input  pc_mux_t     i_pc_mux,
  input  logic [31:0] i_pc_offset,

  // Flush Signals
  input  logic i_flush,

  // Stall Signals
  input  logic if_stall,

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
  if (rst)
    pc <= 32'h60000000;
  else if (!if_stall)
    pc <= pc_next;
end

// Program Counter Logic
assign pc_next = (i_pc_mux == pc_offset) ? (i_pc_offset) : (pc + 'd4);

// Instruction Memory Logic
assign imem_addr = pc;

// Assert read mask on read enable cycle
assign imem_rmask = (!if_stall) ? 4'hF : 4'b0;

// Latch to Pipeline Registers
always_ff @(posedge clk) begin
  if (rst || i_flush) begin
    // Reset Pipeline Registers
    if_stage_reg.pc      <= '0;
    if_stage_reg.pc_next <= '0;
    if_stage_reg.rvfi    <= '0;
  end else if (!if_stall) begin
    // Latch Program Counters
    if_stage_reg.pc      <= pc;
    if_stage_reg.pc_next <= pc_next;

    // Latch RVFI Signals
    if_stage_reg.rvfi.valid    <= 1'b1;
    if_stage_reg.rvfi.pc_rdata <= pc;
    if_stage_reg.rvfi.pc_wdata <= pc_next;
  end
end

endmodule : if_stage