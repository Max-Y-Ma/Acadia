/**
 * This module defines the cells used for the boundary scan registers
 *
 * Port Description:
 * ==================================================================
 * |  clk  | clock signal for flip flops
 * |  rst  | active-high reset signal for flip flops 
 * |  se   | clock enable for input flop
 * |  oe   | output enable for output flop
 * |  in   | normal device operation input 
 * |  bin  | boundary scan serial input 
 * |  out  | normal device operation output
 * |  bout | boundary scan serial output
 */
module adp_cell (
  input  logic clk,
  input  logic rst,
  input  logic se,
  input  logic oe,
  input  logic shift_sel,
  input  logic out_sel,
  input  logic in,
  input  logic bin,
  output logic out,
  output logic bout
);

// Shift Mux
logic conn1;
assign conn1 = shift_sel ? bin : in;

// Cell Flops
logic [1:0] cell_flop;
always_ff @(posedge clk, posedge rst) begin
  if (rst)     cell_flop[0] <= '0;
  else if (se) cell_flop[0] <= conn1;
end

assign bout = cell_flop[0];

always_ff @(posedge clk, posedge rst) begin
  if (rst)     cell_flop[1] <= '0;
  else if (oe) cell_flop[1] <= cell_flop[0];
end

// Output Mux
assign out = out_sel ? cell_flop[1] : in;

endmodule : adp_cell