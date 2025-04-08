module small_test (
  input logic CLK,
  input logic RST,
  output logic A
);

always_ff @ (posedge CLK or posedge RST) begin
  if (RST) begin
    A <= 1'b0;
  end else begin
    A <= 1'b1;
  end
end

endmodule
