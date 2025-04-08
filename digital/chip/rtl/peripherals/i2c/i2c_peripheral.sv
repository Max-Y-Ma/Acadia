/* i2c_peripheral.sv
 * 
 * Binh-Minh Nguyen (bmn4) 10/14/2024
 *
 * Wrapper around my ece479 I2C controller to conenct to memory bus
 *
 * Memory map:
 *
 *
 */

module i2c_peripheral #(
  parameter D_BAUD_FREQ     = 12'd1, // Clkdiv for 125 MHz -> 200 KHz
  parameter D_BAUD_LIMIT    = 16'd625
) (
  input   clk,
  input   rst,

  output logic  int_req,

  /* Top-level pins */
  input  logic  SDA_in,
  output logic  SDA,
  output logic  SCL,
  
  /* Connection to memory map */
  input  logic [31:0] mem_addr,
  input  logic [3:0]  mem_rmask,
  input  logic [3:0]  mem_wmask,
  input  logic [31:0] mem_wdata,
  output logic [31:0] mem_rdata,
  output logic        mem_resp
);

typedef enum logic [3:0] {
  CONFIG_MEM_OFFSET     = 4'd0 << 2,
  RESULT_MEM_OFFSET     = 4'd1 << 2,
  BAUD_FREQ_MEM_OFFSET  = 4'd2 << 2,
  BAUD_LIMIT_MEM_OFFSET = 4'd3 << 2
} I2C_MEM_OFFSET;

logic [7:0] Dout, Dout_next;
logic [6:0] slaveAddress, slaveAddress_next;
logic RW, RW_next;
logic EN, EN_next;

logic [15:0]  Din;
logic         Busy, Busy_prev;
logic         ACK_bit;
logic         ce;

logic [11:0] clkDiv_step, clkDiv_step_next;
logic [15:0] clkDiv_limit, clkDiv_limit_next;

logic [31:0] mem_rdata_next;
logic [31:0] mem_resp_next;

I2C_transceiver I2C_transceiver0 (
  .SDA_in(SDA_in),
  .SDA(SDA),
  .SCL(SCL),

  .Dout(Dout),
  .slaveAddress(slaveAddress),
  .RW(RW), .EN(EN),
  
  .Din(Din),
  .Busy(Busy),
  .ACK_bit(ACK_bit),

  .ce(ce),
  .clk(clk),
  .rst(rst)
);

baud_gen i2c_baud_gen0 (
	.ce_16(ce), .baud_freq(clkDiv_step), .baud_limit(clkDiv_limit),
	.clock(clk), .reset(rst)
);

assign int_req = Busy_prev & ~Busy; // Active 1st cyle Busy falls

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    Dout          <= 'x;
    slaveAddress  <= 'x;
    RW            <= 'x;
    EN            <= '0;

    clkDiv_step   <= D_BAUD_FREQ; 
    clkDiv_limit  <= D_BAUD_LIMIT;

    mem_rdata     <= 'x;
    mem_resp      <= '0;

    Busy_prev     <= '0;
  end else begin
    Dout          <= Dout_next;
    slaveAddress  <= slaveAddress_next;
    RW            <= RW_next;
    EN            <= EN_next;

    clkDiv_step   <= clkDiv_step_next; 
    clkDiv_limit  <= clkDiv_limit_next;

    mem_rdata     <= mem_rdata_next;
    mem_resp      <= mem_resp_next;

    Busy_prev     <= Busy;
  end
end

always_comb begin
  // Default Assignments
  Dout_next         = Dout;
  slaveAddress_next = slaveAddress;
  RW_next           = RW;
  EN_next           = 1'b0;

  clkDiv_step_next  = clkDiv_step;
  clkDiv_limit_next = clkDiv_limit;

  // Outputs
  mem_rdata_next  = 'x;
  // mem_resp_next   = '0; // TODO which do we want
  mem_resp_next   = |{mem_wmask, mem_rmask};

  unique case (mem_addr[$bits(I2C_MEM_OFFSET) - 1 : 0])
    CONFIG_MEM_OFFSET: begin
      if(mem_wmask[0]) begin
        if(~Busy) begin
          EN_next = mem_wdata[0];
        end
        mem_resp_next   = 1'b1;
      end

      if(mem_wmask[1]) begin
        Dout_next = mem_wdata[15:8];
        mem_resp_next   = 1'b1;
      end

      if(mem_wmask[2]) begin
        {slaveAddress_next, RW_next} = mem_wdata[23:16];
        mem_resp_next   = 1'b1;
      end

      if(|mem_rmask) begin
        mem_rdata_next  = {8'b0, slaveAddress_next, RW_next, Dout_next, 7'b0, EN_next};
        mem_resp_next   = 1'b1;
      end
    end

    RESULT_MEM_OFFSET: begin
      if(|mem_rmask) begin
        mem_rdata_next  = {7'b0, ~ACK_bit, 7'b0, Busy, Din};
        mem_resp_next   = 1'b1;
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