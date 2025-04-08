module dac_thermometer (
  input  logic [3:0]  binary,
  output logic [14:0] thermometer
);

assign thermometer[0] = binary[3] | (binary[2] | (binary[1] | (binary[0])));
assign thermometer[1] = binary[3] | (binary[2] | (binary[1]));
assign thermometer[2] = binary[3] | (binary[2] | (binary[1] & (binary[0])));
assign thermometer[3] = binary[3] | (binary[2]);
assign thermometer[4] = binary[3] | (binary[2] & (binary[1] | (binary[0])));
assign thermometer[5] = binary[3] | (binary[2] & (binary[1]));
assign thermometer[6] = binary[3] | (binary[2] & (binary[1] & (binary[0])));
assign thermometer[7] = binary[3];
assign thermometer[8] = binary[3] & (binary[2] | (binary[1] | (binary[0])));
assign thermometer[9] = binary[3] & (binary[2] | (binary[1]));
assign thermometer[10] = binary[3] & (binary[2] | (binary[1] & (binary[0])));
assign thermometer[11] = binary[3] & (binary[2]);
assign thermometer[12] = binary[3] & (binary[2] & (binary[1] | (binary[0])));
assign thermometer[13] = binary[3] & (binary[2] & (binary[1]));
assign thermometer[14] = binary[3] & (binary[2] & (binary[1] & (binary[0])));

endmodule
