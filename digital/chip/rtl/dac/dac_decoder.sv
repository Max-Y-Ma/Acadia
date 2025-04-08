module dac_decoder (
  input  logic clk, rst,
  input  logic curr_row, next_row, col,
  output logic dac_p, dac_n
);

assign dac_n = ~dac_p;

always_ff @ (posedge clk or posedge rst) begin
  if (rst == 1'b1) begin
    dac_p <= '0;
  end
  else begin
    dac_p <= (curr_row & col) | next_row;
  end
end

endmodule
