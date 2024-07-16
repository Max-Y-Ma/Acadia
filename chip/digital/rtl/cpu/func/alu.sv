module alu
import rv32imc_types::*;
(
  input  logic [31:0] a, 
  input  logic [31:0] b,
  input  logic [2:0]  alu_op,
  output logic [31:0] alu_out
);

logic signed   [31:0] as;
logic signed   [31:0] bs;
logic unsigned [31:0] au;
logic unsigned [31:0] bu;

assign as = signed'(a);
assign bs = signed'(b);
assign au = unsigned'(a);
assign bu = unsigned'(b);

// ALU Operations
always_comb begin
  unique case (alu_op)
    alu_add: alu_out = au + bu;
    alu_sll: alu_out = au << bu[4:0];
    alu_sra: alu_out = unsigned'(as >>> bu[4:0]);
    alu_sub: alu_out = au - bu;
    alu_xor: alu_out = au ^ bu;
    alu_srl: alu_out = au >> bu[4:0];
    alu_or:  alu_out = au | bu;
    alu_and: alu_out = au & bu;
    default: alu_out = 'x;
  endcase
end

endmodule : alu
