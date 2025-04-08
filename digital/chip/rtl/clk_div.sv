/**
 * Clock divider using an adjustable prescaler. The prescaler value defines 
 * how many original clk cycles are in the half period of the divided clock.
 *
 * Generated output clock will be in-phase to the source clock signal.
 *
 * Generated output clock is registered for clean clock signal.
 *
 * Note, do not allow scan chains on clock dividers
 *
 * Example: If you want to divide the clock by 8. The half period is 4, so the
 * prescaler should be loaded with 4.
 */
module clk_div # (
  parameter PRESCALER_WIDTH = 16
) (
  input  logic                       clk,
  input  logic                       rst,
  input  logic [PRESCALER_WIDTH-1:0] prescaler,
  output logic                       clk_out
);

localparam COUNT_WIDTH = PRESCALER_WIDTH;

logic [COUNT_WIDTH-1:0] div_count;

// Rollover the divider counter when count is equal to prescaler.
// This implements the half period of the divided clock frequency.
logic rollover;
assign rollover = (div_count >= prescaler);

always_ff @(posedge clk, posedge rst) begin
  if (rst)           div_count <= '0;
  else if (rollover) div_count <= '0;
  else               div_count <= div_count + 1'b1;
end

// Output divided clock is registered.
always_ff @(posedge clk, posedge rst) begin
  if (rst)           clk_out <= '0;
  else if (rollover) clk_out <= !clk_out;
end

endmodule : clk_div