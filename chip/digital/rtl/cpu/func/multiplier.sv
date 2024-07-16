module multiplier
import rv32imc_types::*;
# (
  parameter DEPTH = 1
) (
  input logic clk, rst,

  input  logic [31:0] a, 
  input  logic [31:0] b,
  input  logic        start,
  input  logic [2:0]  mul_op,
  output logic [31:0] mul_out,
  output logic        mul_stall
);

/* Stall Signal */
logic mul_busy;
logic done [DEPTH+1:0];
always_ff @ (posedge clk) begin
  /* Reset when the multiplier operation completes */
  if (rst || done[DEPTH+1]) begin
    mul_busy <= '0;
  end 
  /* Stall until the multiplication operation completes */
  else if (start) begin
    mul_busy <= '1;
  end
end

assign mul_stall = mul_busy & ~done[DEPTH+1];

/* Pipeline Signals */
logic [63:0] mul_result [DEPTH+1:0];
always_ff @ (posedge clk) begin
  for (integer i = 0; i < DEPTH+1; i++) begin
    if (rst) begin
      mul_result[i+1] <= '0;
      done[i+1] <= '0;
    end
    else begin
      mul_result[i+1] <= mul_result[i];
      done[i+1] <= done[i];
    end
  end
end

multiplier_combinational multiplier_combinational0 (
  .a(a),
  .b(b),
  .mul_type(mul_op[1:0]),
  .p(mul_result[0])
);

/* Output Logic */
logic [63:0] mul_p;
assign mul_p = mul_result[DEPTH+1];

always_comb begin
  unique case (mul_op)
    {1'b0, mulr}   : mul_out = mul_p[31:0];
    {1'b0, mulhr}  : mul_out = mul_p[63:32];
    {1'b0, mulhsur}: mul_out = mul_p[63:32];
    {1'b0, mulhur} : mul_out = mul_p[63:32];
    default        : mul_out = 'x;
  endcase
end

endmodule : multiplier