package rv32imc_types;
 // Typedefs for RV32I Instruction Format
    typedef enum bit [6:0] {
        op_lui   = 7'b0110111, // U load upper immediate 
        op_auipc = 7'b0010111, // U add upper immediate PC 
        op_jal   = 7'b1101111, // J jump and link 
        op_jalr  = 7'b1100111, // I jump and link register 
        op_br    = 7'b1100011, // B branch 
        op_load  = 7'b0000011, // I load 
        op_store = 7'b0100011, // S store 
        op_imm   = 7'b0010011, // I arith ops with register/immediate operands 
        op_reg   = 7'b0110011  // R arith ops with register operands 
    } rv32i_opcode_t;

    typedef enum bit [2:0] {
        beq  = 3'b000,
        bne  = 3'b001,
        blt  = 3'b100,
        bge  = 3'b101,
        bltu = 3'b110,
        bgeu = 3'b111
    } branch_funct3_t;

    typedef enum bit [2:0] {
        lb  = 3'b000,
        lh  = 3'b001,
        lw  = 3'b010,
        lbu = 3'b100,
        lhu = 3'b101
    } load_funct3_t;

    typedef enum bit [2:0] {
        sb = 3'b000,
        sh = 3'b001,
        sw = 3'b010
    } store_funct3_t;

    typedef enum bit [2:0] {
        addi  = 3'b000,
        slli  = 3'b001,
        slti  = 3'b010,
        sltiu = 3'b011,
        xori  = 3'b100,
        sri   = 3'b101, // Check bit 30 for logical/arithmetic
        ori   = 3'b110,
        andi  = 3'b111
    } arith_funct3_t;

    typedef enum bit [2:0] {
        addr  = 3'b000,
        sllr  = 3'b001,
        sltr  = 3'b010,
        sltru = 3'b011,
        xorr  = 3'b100,
        srr   = 3'b101, // Check bit 30 for logical/arithmetic
        orr   = 3'b110,
        andr  = 3'b111
    } arith_reg_funct3_t;

    typedef enum bit [2:0] {
        alu_add = 3'b000, // Check bit 30 for add/sub
        alu_sll = 3'b001,
        alu_sra = 3'b010,
        alu_sub = 3'b011,
        alu_xor = 3'b100,
        alu_srl = 3'b101, // Check bit 30 for logical/arithmetic
        alu_or  = 3'b110,
        alu_and = 3'b111
    } rv32i_alu_opcode_t;

    // Typedefs for RV32I Datapath/Control Signals
    typedef enum bit {
        pc_next = 1'b0,
        pc_offset = 1'b1
    } pc_mux_t;

    typedef enum bit {
        rs1_out = 1'b0,
        pc_out = 1'b1
    } alu1_mux_t;

    typedef enum bit {
        rs2_out = 1'b0,
        imm_out = 1'b1
    } alu2_mux_t;

    typedef enum bit [1:0] {
        a_source = 2'b00,
        a_ex_source = 2'b01,
        a_mem_source = 2'b10
    } a_forward_mux_t;

    typedef enum bit [1:0] {
        b_source = 2'b00,
        b_ex_source = 2'b01,
        b_mem_source = 2'b10
    } b_forward_mux_t;

    typedef enum bit {
        rs2_cmp = 1'b0,
        imm_cmp = 1'b1
    } cmp_mux_t;

    typedef enum bit {
        pc_op  = 1'b0,
        rs1_op = 1'b1
    } target_addr_mux_t;

    typedef enum bit [1:0] {
        f_out   = 2'b00,
        cmp_out = 2'b01,
        addr_out  = 2'b10
    } aluout_mux_t;

    typedef enum bit {
        mem_rdata_out = 1'b0,
        alu_out       = 1'b1
    } wb_mux_t;

    typedef enum bit {
        control_out = 1'b0,
        stall_out = 1'b1
    } ctrl_mux_t;

    // Execute State Control Signals
    typedef struct packed {
        alu1_mux_t   alu1_mux;
        alu2_mux_t   alu2_mux;
        aluout_mux_t aluout_mux;
        target_addr_mux_t target_addr_mux;
        logic        branch;
        logic [2:0]  alu_op;
        logic [2:0]  cmp_op;
    } ex_ctrl_t;

    // Memory State Control Signals
    typedef struct packed {
        logic       mem_write;
        logic       mem_read;
        logic [2:0] mem_funct3;
    } mem_ctrl_t;

    // Writeback State Control Signals
    typedef struct packed {
        wb_mux_t     wb_mux;
        logic [2:0]  mem_funct3;
        logic        regf_we;
    } wb_ctrl_t;

    // Typedefs for RVFI Monitor Signals
    typedef struct packed {
        // Required Signals
        logic        valid;
        logic [63:0] order;
        logic [31:0] inst;
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [31:0] rs1_rdata;
        logic [31:0] rs2_rdata;
        logic [4:0]  rd_addr;
        logic [31:0] rd_wdata;
        logic [31:0] pc_rdata;
        logic [31:0] pc_wdata;
        logic [31:0] mem_addr;
        logic [3:0]  mem_rmask;
        logic [3:0]  mem_wmask;
        logic [31:0] mem_rdata;
        logic [31:0] mem_wdata;
    } rvfi_signal_t;

    // Typedefs for RV32I Pipeline Stages
    typedef struct packed {
        // RVFI Signals
        rvfi_signal_t rvfi;

        // Data Signals
        logic [31:0] pc;
        logic [31:0] pc_next;
    } if_stage_t;

    typedef struct packed {
        // RVFI Signals
        rvfi_signal_t rvfi;

        // Data Signals
        logic [31:0] pc;
        logic [31:0] pc_next;
        
        // Instruction Signals
        logic [4:0]  rs1_addr;
        logic [4:0]  rs2_addr;
        logic [4:0]  rd_addr;
        logic [31:0] imm;
        logic [31:0] rs1_rdata;
        logic [31:0] rs2_rdata;

        // Control Signals
        ex_ctrl_t  ex_ctrl;
        mem_ctrl_t mem_ctrl;
        wb_ctrl_t  wb_ctrl;
    } id_stage_t;

    typedef struct packed {
        // RVFI Signals
        rvfi_signal_t rvfi;

        // Data Signals
        logic [31:0] alu_out;
        logic [31:0] pc_next;

        // Instruction Signals
        logic [4:0]  rd_addr;
        logic [31:0] rs2_rdata;

        // Control Signals
        mem_ctrl_t mem_ctrl;
        wb_ctrl_t wb_ctrl;
    } ex_stage_t;

    typedef struct packed {
        // RVFI Signals
        rvfi_signal_t rvfi;

        // Data Signals
        logic [31:0] alu_out;
        logic [31:0] pc_next;

        // Instruction Signals
        logic [4:0]  rd_addr;

        // Control Signals
        mem_ctrl_t mem_ctrl;
        wb_ctrl_t wb_ctrl;
    } mem_stage_t;

    typedef struct packed {
        // RVFI Signals
        rvfi_signal_t rvfi;
    } wb_stage_t;

  typedef enum bit [2:0] { 
    mulr    = 3'b000,
    mulhr   = 3'b001,
    mulhsur = 3'b010,
    mulhur  = 3'b011
  } arith_mul_funct3_t;

  typedef enum bit [1:0] { 
    uu_mul = 2'b00,
    ss_mul = 2'b01,
    su_mul = 2'b10
  } mul_type_t;

  typedef enum bit [1:0] {
    ss_div = 2'b00,
    uu_div = 2'b01,
    ss_rem = 2'b10,
    uu_rem = 2'b11
  } div_type_t;
endpackage
