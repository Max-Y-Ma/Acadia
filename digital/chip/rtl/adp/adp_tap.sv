/**
 * This module defines the Test Access Port (TAP), which contains the
 * main state machine to controller the Acadia Debug Port Core.
 *
 * Although some states do not serve much purpose, the state machine design
 * is general and symetric.
 *
 * The state machine is designed such that in any state, it takes up to five
 * cycles of TMS high to reset back to idle. Thus, the state machine can never
 * become in deadlock.
 */

module adp_tap
import adp_types::*;
(
  // Acadia Debug Port Interface
  input  logic       adp_tck_i_buf,
  input  logic       adp_trst_i_buf,
  input  logic       adp_tms_i_buf,
  output logic [3:0] adp_tst_o_buf,

  // Core Datapath Interface
  input  inst_reg_t  inst_reg,
  output logic       id_reg_shift_en,
  output logic       bypass_reg_shift_en,
  output logic       inst_reg_shift_en,
  output logic       inst_reg_ld,
  output logic       addr_reg_shift_en,
  output logic       data_reg_shift_en,
  output logic       data_reg_ld,
  output logic       data_reg_we,
  output logic       data_setup,
  
  // Boundary Scan Control Interface
  output logic       adp_bscan_se,
  output logic       adp_bscan_oe,
  output logic       adp_bscan_shift_sel,
  output logic       adp_bscan_out_sel,

  // Debug Interface
  output logic       adp_debug_mode
);

// Sequential Output Logic
tap_state_t current_state, next_state;
always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf) current_state <= IDLE;
  else                current_state <= next_state;
end

assign adp_tst_o_buf = current_state;

// State Transition Logic
always_comb begin
  // Default Condition
  next_state = current_state;

  case (current_state)
    IDLE       : next_state = adp_tms_i_buf ? IDLE      : DR_SCAN;
    DR_SCAN    : next_state = adp_tms_i_buf ? SR_SCAN   : DR_JUMP;
    DR_JUMP    : next_state = adp_tms_i_buf ? DR_SETUP  : EX_SHIFT;
    DR_SETUP   : next_state = adp_tms_i_buf ? DR_SCAN   : IN_CAPTURE;
    EX_SHIFT   : next_state = adp_tms_i_buf ? EX_UPDATE : EX_SHIFT;
    EX_UPDATE  : next_state = adp_tms_i_buf ? PAUSE     : DR_SCAN;
    IN_CAPTURE : next_state = adp_tms_i_buf ? PAUSE     : IN_SHIFT;
    IN_SHIFT   : next_state = adp_tms_i_buf ? PAUSE     : IN_SHIFT;
    SR_SCAN    : next_state = adp_tms_i_buf ? IR_SCAN   : SR_SHIFT;
    SR_SHIFT   : next_state = adp_tms_i_buf ? PAUSE     : SR_SHIFT;
    IR_SCAN    : next_state = adp_tms_i_buf ? AR_SCAN   : IR_CAPTURE;
    IR_CAPTURE : next_state = adp_tms_i_buf ? PAUSE     : IR_SHIFT;
    IR_SHIFT   : next_state = adp_tms_i_buf ? PAUSE     : IR_SHIFT;
    AR_SCAN    : next_state = adp_tms_i_buf ? IDLE      : AR_SHIFT;
    AR_SHIFT   : next_state = adp_tms_i_buf ? PAUSE     : AR_SHIFT;
    PAUSE      : next_state = adp_tms_i_buf ? DR_SCAN   : PAUSE;
  endcase
end

// Sequential Output Logic 
always_ff @(posedge adp_tck_i_buf, posedge adp_trst_i_buf) begin
  if (adp_trst_i_buf) begin
    id_reg_shift_en     <= '0;
    bypass_reg_shift_en <= '0;
    inst_reg_shift_en   <= '0;
    inst_reg_ld         <= '0;
    addr_reg_shift_en   <= '0;
    data_reg_shift_en   <= '0;
    data_reg_ld         <= '0;
    data_reg_we         <= '0;
    data_setup          <= '0;
    adp_bscan_se        <= '0;
    adp_bscan_oe        <= '0;
    adp_bscan_shift_sel <= '0;
    adp_bscan_out_sel   <= '0;
    adp_debug_mode      <= '0;
  end
  else begin
    id_reg_shift_en     <= '0;
    bypass_reg_shift_en <= '0;
    inst_reg_shift_en   <= '0;
    inst_reg_ld         <= '0;
    addr_reg_shift_en   <= '0;
    data_reg_shift_en   <= '0;
    data_reg_ld         <= '0;
    data_reg_we         <= '0;
    data_setup          <= '0;
    adp_bscan_se        <= '0;
    adp_bscan_oe        <= '0;
    adp_bscan_shift_sel <= '0;
    adp_bscan_out_sel   <= '0;
    adp_debug_mode      <= '1;
    
    case (next_state)
      IDLE : begin
        /* Disable Scan Mode */
        adp_debug_mode <= '0;
      end 
      DR_SCAN : begin
        /* Do nothing */
      end
      DR_JUMP : begin
        /* Do nothing */
      end
      DR_SETUP : begin
        /* In DEBUG_READ mode, complete data read setup for SRAM */
        if (inst_reg == DEBUG_READ) begin
          data_setup <= '1;
        end
      end
      EX_SHIFT : begin
        /* In BOUNDARY_SCAN mode, set shift_sel and ce */
        if (inst_reg == BOUNDARY_SCAN) begin
          adp_bscan_shift_sel <= '1;
          adp_bscan_se <= '1;
        end
        /* In DEBUG_WRITE mode, shift write data into data register */
        else if (inst_reg == DEBUG_WRITE) begin
          data_reg_shift_en <= '1;
        end
      end
      EX_UPDATE : begin
        /* In BOUNDARY_SCAN mode, set out_sel and oe */
        if (inst_reg == BOUNDARY_SCAN) begin
          adp_bscan_out_sel <= '1;
          adp_bscan_oe <= '1;
        end
        /* In DEBUG_WRITE mode, assert write transaction after shift */
        else if (inst_reg == DEBUG_WRITE) begin
          data_reg_we <= '1;
        end
      end
      IN_CAPTURE : begin
        /* In BOUNDARY_SCAN mode, set !shift_sel and ce */
        if (inst_reg == BOUNDARY_SCAN) begin
          adp_bscan_shift_sel <= '0;
          adp_bscan_se <= '1;
        end
        /* In DEBUG_READ mode, load data register */
        else if (inst_reg == DEBUG_READ) begin
          data_reg_ld <= '1;
        end
      end
      IN_SHIFT : begin
        /* In BOUNDARY_SCAN mode, set shift_sel and ce */
        if (inst_reg == BOUNDARY_SCAN) begin
          adp_bscan_shift_sel <= '1;
          adp_bscan_se <= '1;
        end
        /* In DEBUG_READ mode, shift read data out of data register */
        else if (inst_reg == DEBUG_READ) begin
          data_reg_shift_en <= '1;
        end
      end
      SR_SCAN : begin
        /* Do nothing */
      end
      SR_SHIFT : begin
        /* In DEVICE_ID_READ instruction, shift device ID register */
        if (inst_reg == DEVICE_ID_READ) begin
          id_reg_shift_en <= '1;
        end
        /* In BYPASS_MODE instruction, shift bypass register */
        else if (inst_reg == BYPASS_MODE) begin
          bypass_reg_shift_en <= '1;
        end
        /* In SCAN_MODE instruction, wait during scan chain operation*/
      end
      IR_SCAN : begin
        /* Do nothing */
      end
      IR_CAPTURE : begin
        /* Load debug signals into start of instruction register */
        inst_reg_ld <= '1; 
      end
      IR_SHIFT : begin
        /* Shift TDI into instruction register */
        inst_reg_shift_en <= '1;
      end
      AR_SCAN : begin
        /* Do nothing */
      end
      AR_SHIFT : begin
        /* Shift TDI into address register */
        addr_reg_shift_en <= '1;
      end
      PAUSE : begin
        /* Do nothing */
      end
    endcase
  end
end

endmodule : adp_tap