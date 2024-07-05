module forwarding_unit 
import rv32i_types::*;
(
    input  logic [4:0]     rs1_addr,
    input  logic [4:0]     rs2_addr,
    input  logic [4:0]     ex_rd_addr,
    input  logic [4:0]     mem_rd_addr,
    input  logic           ex_regf_we,
    input  logic           mem_regf_we,
    output a_forward_mux_t forward_a,
    output b_forward_mux_t forward_b
);

    // Execution and Data Memory Stage Hazard
    always_comb begin
        // Default Signals
        forward_a = a_source;
        forward_b = b_source;

        // Execution Conditions
        if (ex_regf_we && (ex_rd_addr != 0) && (ex_rd_addr == rs1_addr)) begin
            forward_a = a_ex_source;
        end else if (mem_regf_we && (mem_rd_addr != 0) && (mem_rd_addr == rs1_addr)) begin
            forward_a = a_mem_source;
        end

        // Data Memory Conditions
        if (ex_regf_we && (ex_rd_addr != 0) && (ex_rd_addr == rs2_addr)) begin
            forward_b = b_ex_source;
        end else if (mem_regf_we && (mem_rd_addr != 0) && (mem_rd_addr == rs2_addr)) begin
            forward_b = b_mem_source;
        end
    end

endmodule : forwarding_unit