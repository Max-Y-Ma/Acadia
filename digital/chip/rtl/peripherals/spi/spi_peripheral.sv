/* spi_peripheral.sv
 * 
 * Binh-Minh Nguyen (bmn4) 10/29/2024
 *
 * Wrapper around SPI tx only controller to conenct to memory bus
 *
 * Memory map:
 *
 *
 */

module spi_peripheral #(
  parameter D_BAUD_FREQ     = 12'd1, // Clkdiv for 125 MHz -> 200 KHz
  parameter D_BAUD_LIMIT    = 16'd1
) (
  input   clk,
  input   rst,

  /* Top-level pins */
  output logic  MOSI,
  output logic  SCLK,
  
  /* Connection to memory map */
  input  logic [31:0] mem_addr,
  input  logic [3:0]  mem_rmask,
  input  logic [3:0]  mem_wmask,
  input  logic [31:0] mem_wdata,
  output logic [31:0] mem_rdata,
  output logic        mem_resp
);

typedef enum logic [3:0] {
  BUF_WRITE_OFFSET      = 4'd0 << 2,
  BUF_PTR_OFFSET        = 4'd1 << 2,
  BAUD_FREQ_MEM_OFFSET  = 4'd2 << 2,
  BAUD_LIMIT_MEM_OFFSET = 4'd3 << 2
} I2C_MEM_OFFSET;

logic ce;

logic wen;
logic [7:0] w_data;
logic [4:0] rptr;
logic [4:0] wptr;

logic [11:0] clkDiv_step, clkDiv_step_next;
logic [15:0] clkDiv_limit, clkDiv_limit_next;

logic [31:0] mem_rdata_next;
logic [31:0] mem_resp_next;

spi_transmitter spi0 (
    .clk(clk),
    .rst(rst),

    .clk_en(ce),

    .wen(wen),
    .w_data(w_data),

    .rptr(rptr),
    .wptr(wptr),

    .SCLK(SCLK),
    .MOSI(MOSI)
);

baud_gen spi_baud_gen0 (
	.ce_16(ce), .baud_freq(clkDiv_step), .baud_limit(clkDiv_limit),
	.clock(clk), .reset(rst)
);

always_ff @( posedge clk ) begin
  if(rst) begin
    clkDiv_step   <= D_BAUD_FREQ; 
    clkDiv_limit  <= D_BAUD_LIMIT;

    mem_rdata     <= 'x;
    mem_resp      <= '0;
  end else begin
    clkDiv_step   <= clkDiv_step_next; 
    clkDiv_limit  <= clkDiv_limit_next;

    mem_rdata     <= mem_rdata_next;
    mem_resp      <= mem_resp_next;
  end
end

always_comb begin
  // Default Assignments
  clkDiv_step_next  = clkDiv_step;
  clkDiv_limit_next = clkDiv_limit;

  w_data  = mem_wdata[7:0];
  wen     = '0;

  // Outputs
  mem_rdata_next  = 'x;
  mem_resp_next   = |{mem_wmask, mem_rmask}; // So we don't stall processor

  unique case (mem_addr[$bits(I2C_MEM_OFFSET) - 1 : 0])
    BUF_WRITE_OFFSET: begin
      if(mem_wmask[0]) begin
        wen = 1'b1; // Overflow handling done in spi_transmitter
        mem_resp_next = 1'b1;
      end
    end

    BUF_PTR_OFFSET: begin
      if(|mem_rmask) begin
        mem_rdata_next = {11'b0, wptr, 11'b0, rptr};
        mem_resp_next  = 1'b1;
      end
    end

    BAUD_FREQ_MEM_OFFSET: begin
      if(mem_wmask[0]) begin
        clkDiv_step_next[7:0] = mem_wdata[7:0];
        mem_resp_next = 1'b1;
      end

      if(mem_wmask[1]) begin
        clkDiv_step_next[11:8] = mem_wdata[11:8];
        mem_resp_next = 1'b1;
      end

      if(|mem_rmask) begin
        mem_rdata_next = {24'b0, clkDiv_step};
        mem_resp_next = 1'b1;
      end
    end

    BAUD_LIMIT_MEM_OFFSET: begin
      if(mem_wmask[0]) begin
        clkDiv_limit_next[7:0] = mem_wdata[7:0];
        mem_resp_next = 1'b1;
      end

      if(mem_wmask[1]) begin
        clkDiv_limit_next[15:8] = mem_wdata[15:8];
        mem_resp_next = 1'b1;
      end

      if(|mem_rmask) begin
        mem_rdata_next = {16'b0, clkDiv_limit};
        mem_resp_next = 1'b1;
      end
    end

    default begin end // Catch 'x in sim
  endcase
end

endmodule