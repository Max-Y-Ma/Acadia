module detection_unit
import rv32i_types::*;
(
    input  logic id_mem_read,
    input  logic [4:0] ex_rd_addr,
    input  logic [4:0] rs1_addr,
    input  logic [4:0] rs2_addr,
    output ctrl_mux_t ctrl_mux,
    output logic id_reg_we,
    output logic pc_we
);

    // Hazard Detection Logic
    always_comb begin
        // Default Signals
        ctrl_mux = control_out;
        id_reg_we = 1'b1;
        pc_we = 1'b1;
      
        // If the instruction in execute stage is load:
        // Stall 1 cycle, then execute stage will handle forwarding
        if (id_mem_read && ((rs1_addr == ex_rd_addr) || (rs2_addr == ex_rd_addr))) begin
            ctrl_mux = stall_out;
            id_reg_we = 1'b0;
            pc_we = 1'b0;
        end
    end

endmodule : detection_unit