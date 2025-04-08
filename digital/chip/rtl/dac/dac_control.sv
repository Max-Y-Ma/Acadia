module dac_control (
  input  logic        clk, rst,
  input  logic [7:0]  binary,
  output logic current_enable   [255:1],
  output logic current_enable_b [255:1]
);

logic [14:0] thermometer [1:0];

generate
for (genvar i = 0; i < 2; i++) begin
  always_comb begin
    thermometer[i][0]  = binary[4*i+3] | (binary[4*i+2] | (binary[4*i+1] | (binary[4*i+0])));
    thermometer[i][1]  = binary[4*i+3] | (binary[4*i+2] | (binary[4*i+1]));
    thermometer[i][2]  = binary[4*i+3] | (binary[4*i+2] | (binary[4*i+1] & (binary[4*i+0])));
    thermometer[i][3]  = binary[4*i+3] | (binary[4*i+2]);
    thermometer[i][4]  = binary[4*i+3] | (binary[4*i+2] & (binary[4*i+1] | (binary[4*i+0])));
    thermometer[i][5]  = binary[4*i+3] | (binary[4*i+2] & (binary[4*i+1]));
    thermometer[i][6]  = binary[4*i+3] | (binary[4*i+2] & (binary[4*i+1] & (binary[4*i+0])));
    thermometer[i][7]  = binary[4*i+3];
    thermometer[i][8]  = binary[4*i+3] & (binary[4*i+2] | (binary[4*i+1] | (binary[4*i+0])));
    thermometer[i][9]  = binary[4*i+3] & (binary[4*i+2] | (binary[4*i+1]));
    thermometer[i][10] = binary[4*i+3] & (binary[4*i+2] | (binary[4*i+1] & (binary[4*i+0])));
    thermometer[i][11] = binary[4*i+3] & (binary[4*i+2]);
    thermometer[i][12] = binary[4*i+3] & (binary[4*i+2] & (binary[4*i+1] | (binary[4*i+0])));
    thermometer[i][13] = binary[4*i+3] & (binary[4*i+2] & (binary[4*i+1]));
    thermometer[i][14] = binary[4*i+3] & (binary[4*i+2] & (binary[4*i+1] & (binary[4*i+0])));
  end
end
endgenerate

generate
for (genvar col = 1; col < 16; col++) begin // First Row
  always_ff @ (posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
      current_enable  [col] <= 1'b0;
      current_enable_b[col] <= 1'b1;
    end
    else begin
      current_enable  [col] <=  (thermometer[0][col-1] | thermometer[1][0]);
      current_enable_b[col] <= ~(thermometer[0][col-1] | thermometer[1][0]);
    end
  end

  always_ff @ (posedge clk or negedge rst) begin // Last Row
    if (rst == 1'b0) begin
      current_enable  [16*15+col] <= 1'b0;
      current_enable_b[16*15+col] <= 1'b1;
    end
    else begin
      current_enable  [16*15+col] <=  (thermometer[1][14] & thermometer[0][col-1]);
      current_enable_b[16*15+col] <= ~(thermometer[1][14] & thermometer[0][col-1]);
    end
  end
end

for (genvar row = 1; row < 16; row++) begin // First Column
  always_ff @ (posedge clk or negedge rst) begin 
    if (rst == 1'b0) begin
      current_enable  [16*row] <= 1'b0;
      current_enable_b[16*row] <= 1'b1;
    end
    else begin
      current_enable  [16*row] <=  thermometer[1][row-1];
      current_enable_b[16*row] <= ~thermometer[1][row-1];
    end
  end
end

for (genvar row = 1; row < 15; row++) begin // Normal case
  for (genvar col = 1; col < 16; col++) begin
    always_ff @ (posedge clk or negedge rst) begin
      if (rst == 1'b0) begin
        current_enable  [16*row+col] <= 1'b0;
        current_enable_b[16*row+col] <= 1'b1;
      end
      else begin
        current_enable  [16*row+col] <=  ((thermometer[1][row-1] & thermometer[0][col-1]) | thermometer[1][row]);
        current_enable_b[16*row+col] <= ~((thermometer[1][row-1] & thermometer[0][col-1]) | thermometer[1][row]);
      end
    end
  end
end
endgenerate

endmodule
