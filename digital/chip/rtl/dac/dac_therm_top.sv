module dac_therm_top (
  input logic CLK, RST,
  input logic [7:0] DAC_IN,
  output logic [14:0] ROWS,
  output logic [14:0] COLS
);

logic [3:0] row_in;
logic [3:0] col_in;
//assign row_in = DAC_IN[7:4];
//assign col_in = DAC_IN[3:0];

//logic [14:0] rows;
//logic [14:0] cols;

always_ff @ (posedge CLK or posedge RST) begin
  if (RST) begin
    row_in <= '0;
    col_in <= '0;
    //ROWS <= '0;
    //COLS <= '0;
  end else begin
    row_in <= DAC_IN[7:4];
    col_in <= DAC_IN[3:0];
    //ROWS <= rows;
    //COLS <= cols;
  end
end

dac_thermometer therm0 (
  .binary(row_in),
  .thermometer(ROWS)
);

dac_thermometer therm1 (
  .binary(col_in),
  .thermometer(COLS)
);

endmodule
