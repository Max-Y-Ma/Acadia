//systemVerilog HDL for "acadia", "adc_cap_dac_8_bit_diff_adc_regs" "systemVerilog"

module adc_cap_dac_8_bit_diff_adc_regs (
  input logic clk,
  input logic rst,
  input logic [7:0] d,
  input logic load,
  output logic [7:0] q
);

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    q <= 8'h00;
  end else begin
    if (load) q <= d;
  end
end

endmodule
