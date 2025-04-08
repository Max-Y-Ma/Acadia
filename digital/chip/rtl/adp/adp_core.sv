/**
 * This module holds the main components that make up the Acadia Debug Port (ADP):
 *   - Data Register        : Sampled data from current instruciton and address
 *   - Address Register     : Address for reads and writes
 *   - Instruction Register : Instruction currently under execution
 * 
 * The ADP supports multiple DFT features including scan chain, boundary scan,
 * RV32IMC register reads/writes, and SRAM reads/writes.
 *
 * During, SCAN_MODE instruction, the TDI pin acts as the scan enable pin 
 * for the scan chain. During BOUNDARY_SCAN and STEP_MODE instructions, 
 * the TDI pin acts as the stall signal for the main cpu core.
 *
 * While the ADP TAP is being used, debug mode is enabled. This switches the
 * main system clock and reset to that of the ADP. Returning to the IDLE
 * state in the TAP controller will allow the core to operate normally.
 *
 * The ADP also supports a STEP_MODE, which allows the user to control the
 * core each clock cycle.
 *
 * The most basic bringup for ADP is reading the IDCODE register, which contains
 * Acadia's DEVICE ID, 0x69ECE498.
 *
 * Instruction Map:
 *   - NULL_MODE : Reserved instruction; Garuntees debug mode is disabled
 *     - Set IR to NULL
 *
 *   - DEVICE_ID_READ : Read 32-bit device ID
 *     - Set IR to DEVICE_ID_READ
 *     - Shift out SR 32 times
 *
 *   - SCAN_MODE : Access the scan chain
 *     - Set IR to SCAN_MODE
 *     - Set ADP TDI pin to shift in data for stuck-at checks
 *     - Shift out SR xxx times depending on scan chain
 *
 *   - BOUNDARY_SCAN : Enables control of boundary scan cells
 *     - Set IR to BOUNDARY_SCAN
 *     - Control TAP to execute internal or external tests with 
 *       capture, shift, and update state appropriately
 * 
 *   - BYPASS_MODE : Simply pass TDI to TDO for sanity or daisy chaining chips
 *     - Set IR to BYPASS_MODE
 *     - Shift out SR xxx times depending on bypass functionality
 *
 *   - DEBUG_READ : Output internal register / data SRAM values to TDO
 *     - Set IR to DEBUG_READ
 *     - Set AR to memory mapped address
 *     - Shift out DR 32 times or xxx times
 *
 *   - DEBUG_WRITE : Write to the internal register / data SRAM values from TDI
 *     - Set IR to DEBUG_WRITE
 *     - Set AR to memory mapped address
 *     - Shift in DR to set write data
 *
 *   - STEP_MODE : Step through core operation cycle by cycle using TDI
 *     - Set IR to STEP_MODE
 *     - Set ADP TDI pin to stall/allow core execution
 *
 */

module adp_core 
import adp_types::*;
(
  // Acadia Debug Port Interface
  input  logic        adp_tck_i_buf,
  input  logic        adp_trst_i_buf,
  input  logic        adp_tms_i_buf,
  input  logic        adp_tdi_i_buf,
  output logic        adp_tdo_o_buf,
  output logic [3:0]  adp_tst_o_buf,

  // Core Input Data Interface
  input  logic        adp_imem_stall,
  input  logic        adp_dmem_stall,
  input  logic        adp_func_stall,
  input  logic        adp_load_hazard,
  input  logic [31:0] adp_dmem_rdata,
  input  logic [31:0] adp_core_reg [32],
  input  logic [31:0] adp_core_pc,
  input  logic [31:0] adp_core_ir,
  input  logic [31:0] adp_core_adc,
  input  logic [31:0] adp_core_dac,
  input  logic        adp_scan_end,
  input  logic        adp_bscan_end,

  // Core Control Signal Interface
  output logic [31:0] adp_dmem_addr,
  output logic [3:0]  adp_dmem_rmask,
  output logic [3:0]  adp_dmem_wmask,
  output logic [31:0] adp_dmem_wdata,
  output logic [4:0]  adp_rd_addr,
  output logic [31:0] adp_wdata,
  output logic        adp_reg_we,
  output logic        adp_pc_we,
  output logic        adp_ir_we,
  output logic        adp_adc_we,
  output logic        adp_dac_we,
  output logic        adp_ctrl_stall,
  output logic        adp_scan_enable,
  output logic        adp_scan_start,
  output logic        adp_bscan_se,
  output logic        adp_bscan_oe,
  output logic        adp_bscan_shift_sel,
  output logic        adp_bscan_out_sel,
  output logic        adp_bscan_start,
  output logic        adp_debug_mode
);

////////////////////////////////////////////////////////////////////////////////
// Core Control Signals
////////////////////////////////////////////////////////////////////////////////
logic        id_reg_shift_en;
logic [31:0] id_reg;

logic        bypass_reg_shift_en;
logic        bypass_reg;

logic        inst_reg_shift_en;
logic        inst_reg_ld;
inst_reg_t   inst_reg;

logic        addr_reg_shift_en;
logic [15:0] addr_reg;

logic        data_reg_shift_en;
logic        data_reg_ld;
logic        data_reg_we;
logic        data_setup;
logic [31:0] data_reg;
logic [31:0] data_reg_next;

logic [2:0]  tdo_mux_sel;

////////////////////////////////////////////////////////////////////////////////
// TAP Controller
////////////////////////////////////////////////////////////////////////////////
adp_tap adp_tap0 (
  .adp_tck_i_buf(adp_tck_i_buf),
  .adp_trst_i_buf(adp_trst_i_buf),
  .adp_tms_i_buf(adp_tms_i_buf),
  .adp_tst_o_buf(adp_tst_o_buf),
  .inst_reg(inst_reg),
  .id_reg_shift_en(id_reg_shift_en),
  .bypass_reg_shift_en(bypass_reg_shift_en),
  .inst_reg_shift_en(inst_reg_shift_en),
  .inst_reg_ld(inst_reg_ld),
  .addr_reg_shift_en(addr_reg_shift_en),
  .data_reg_shift_en(data_reg_shift_en),
  .data_reg_ld(data_reg_ld),
  .data_reg_we(data_reg_we),
  .data_setup(data_setup),
  .adp_bscan_se(adp_bscan_se),
  .adp_bscan_oe(adp_bscan_oe),
  .adp_bscan_shift_sel(adp_bscan_shift_sel),
  .adp_bscan_out_sel(adp_bscan_out_sel),
  .adp_debug_mode(adp_debug_mode)
);

////////////////////////////////////////////////////////////////////////////////
// Data Sram Read and Write Logic
////////////////////////////////////////////////////////////////////////////////
always_comb begin
  // Default Case
  adp_dmem_addr  = '0;
  adp_dmem_rmask = '0;
  adp_dmem_wmask = '0;
  adp_dmem_wdata = '0;

  // Assert SRAM Read Signals
  if (addr_reg[SRAM_ADDR_BIT] && data_setup) begin
    adp_dmem_addr  = {19'h3_8000, addr_reg[SRAM_ADDR_WIDTH-1:0]};
    adp_dmem_rmask = 'hF;
  end
  else if (addr_reg[SRAM_ADDR_BIT] && data_reg_we) begin
    adp_dmem_addr  = {19'h3_8000, addr_reg[SRAM_ADDR_WIDTH-1:0]};
    adp_dmem_wmask = 'hF;
    adp_dmem_wdata = data_reg;
  end
end

////////////////////////////////////////////////////////////////////////////////
// Debug Address Map Read Logic
////////////////////////////////////////////////////////////////////////////////
always_comb begin
  // Default Case
  data_reg_next = '0;

  // Read from data sram
  if (addr_reg[SRAM_ADDR_BIT]) begin
    data_reg_next = adp_dmem_rdata;
  end
  // Read from core register bank
  else if (addr_reg[REG_ADDR_BIT]) begin
    data_reg_next = adp_core_reg[addr_reg[REG_ADDR_WIDTH-1:0]];
  end
  // Read from core data registers
  else if (addr_reg[CORE_ADDR_BIT]) begin
    case (addr_reg[CORE_ADDR_WIDTH-1:0])
      CORE_PC_ADDR  : data_reg_next = adp_core_pc;
      CORE_IR_ADDR  : data_reg_next = adp_core_ir;
      CORE_ADC_ADDR : data_reg_next = adp_core_adc;
      CORE_DAC_ADDR : data_reg_next = adp_core_dac;
    endcase
  end
end

////////////////////////////////////////////////////////////////////////////////
// Debug Address Map Write Logic
////////////////////////////////////////////////////////////////////////////////
assign adp_rd_addr = addr_reg[4:0];
assign adp_wdata   = data_reg;

always_comb begin
  // Default Case
  adp_reg_we = '0;
  adp_pc_we  = '0;
  adp_ir_we  = '0;
  adp_adc_we = '0;
  adp_dac_we = '0;

  if (data_reg_we) begin
    // NOTE: Write to data sram handled seperately with read logic
    // Write to core register bank
    if (addr_reg[REG_ADDR_BIT]) begin
      adp_reg_we = '1;
    end
    // Write to core data registers
    else if (addr_reg[CORE_ADDR_BIT]) begin
      case (addr_reg[CORE_ADDR_WIDTH-1:0])
        CORE_PC_ADDR  : adp_pc_we  = '1;
        CORE_IR_ADDR  : adp_ir_we  = '1;
        CORE_ADC_ADDR : adp_adc_we = '1;
        CORE_DAC_ADDR : adp_dac_we = '1;
      endcase
    end
  end
end

////////////////////////////////////////////////////////////////////////////////
// ADP Core Registers
////////////////////////////////////////////////////////////////////////////////

// Device ID Register
always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf)       id_reg <= ACADIA_DEVICE_ID;
  else if (id_reg_shift_en) id_reg <= {id_reg[30:0], id_reg[31]};
end

// Bypass Register
always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf)           bypass_reg <= '0;
  else if (bypass_reg_shift_en) bypass_reg <= adp_tdi_i_buf;
end

// Instruction, Address, and Data Registers
always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf)         inst_reg <= NULL_MODE;
  else if (inst_reg_ld)       inst_reg <= {adp_imem_stall, adp_dmem_stall, adp_func_stall, adp_load_hazard};
  else if (inst_reg_shift_en) inst_reg <= {inst_reg[5:0], adp_tdi_i_buf};
end

always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf)         addr_reg <= '0;
  else if (addr_reg_shift_en) addr_reg <= {addr_reg[14:0], adp_tdi_i_buf};
end

always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf)         data_reg <= '0;
  else if (data_reg_ld)       data_reg <= data_reg_next;
  else if (data_reg_shift_en) data_reg <= {data_reg[30:0], adp_tdi_i_buf};
end

////////////////////////////////////////////////////////////////////////////////
// Boundary Scan
////////////////////////////////////////////////////////////////////////////////
assign adp_bscan_start = adp_tdi_i_buf;

////////////////////////////////////////////////////////////////////////////////
// Scan Chain
////////////////////////////////////////////////////////////////////////////////
assign adp_scan_start = adp_tdi_i_buf;

always_comb begin
  // Default Case
  adp_scan_enable = 1'b0;

  // Allow scan enable during SCAN_MODE instruction and SR shifting state
  if ((inst_reg == SCAN_MODE) && (adp_tst_o_buf == SR_SHIFT)) begin
    adp_scan_enable = 1'b1; 
  end
end

////////////////////////////////////////////////////////////////////////////////
// Step Mode
////////////////////////////////////////////////////////////////////////////////
always_comb begin
  // Default Case
  adp_ctrl_stall = adp_debug_mode;

  // Allow step control during STEP_MODE instruction and SR shifting state
  if ((inst_reg == STEP_MODE) && (adp_tst_o_buf == SR_SHIFT)) begin
    adp_ctrl_stall = adp_tdi_i_buf; 
  end
end

////////////////////////////////////////////////////////////////////////////////
// TDO Output Decoder + Mux
////////////////////////////////////////////////////////////////////////////////
always_comb begin
  // Default Case
  tdo_mux_sel = NULL;

  case (inst_reg[2:0])
    NULL_MODE      : tdo_mux_sel = NULL;
    DEVICE_ID_READ : tdo_mux_sel = DEVICE_ID;
    SCAN_MODE      : tdo_mux_sel = SCAN_CHAIN;
    BOUNDARY_SCAN  : tdo_mux_sel = BOUNDARY;
    BYPASS_MODE    : tdo_mux_sel = BYPASS;
    DEBUG_READ     : tdo_mux_sel = DATA_REG;
    DEBUG_WRITE    : tdo_mux_sel = DATA_REG;
    STEP_MODE      : tdo_mux_sel = BYPASS;
  endcase
end

always_comb begin
  // Default Case
  adp_tdo_o_buf = '0;
  
  case (tdo_mux_sel)
    NULL       : adp_tdo_o_buf = '0;
    DEVICE_ID  : adp_tdo_o_buf = id_reg[31];
    SCAN_CHAIN : adp_tdo_o_buf = adp_scan_end;
    BOUNDARY   : adp_tdo_o_buf = adp_bscan_end;
    BYPASS     : adp_tdo_o_buf = bypass_reg;
    DATA_REG   : adp_tdo_o_buf = data_reg[31];
  endcase
end

endmodule : adp_core