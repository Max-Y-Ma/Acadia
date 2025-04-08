module clk_gen (
  input logic clk,
  input logic rst,

  /* Dmem interface */
  input  logic [31:0] dmem_addr,
  input  logic [3:0]  dmem_rmask,
  input  logic [3:0]  dmem_wmask,
  input  logic [31:0] dmem_wdata,
  output logic [31:0] prescaler_rdata,

  /* Generated clocks */
  output logic cpu_clk,
  output logic spi_clk,
  output logic i2c1_clk,
  output logic i2c2_clk,
  output logic uart1_clk,
  output logic uart2_clk,
  output logic adc_clk
);

localparam NUM_PRESCALER = 6;
localparam NUM_PRESCALER_WIDTH = $clog2(NUM_PRESCALER);
localparam PRESCALER_WIDTH = 16;
localparam PRESCALER_BYTES = PRESCALER_WIDTH / 8;

localparam SPI_DEFAULT_PRESCALER   = '1;
localparam I2C1_DEFAULT_PRESCALER  = '0;
localparam I2C2_DEFAULT_PRESCALER  = '0;
localparam UART1_DEFAULT_PRESCALER = '0;
localparam UART2_DEFAULT_PRESCALER = '0;
localparam ADC_DEFAULT_PRESCALER   = 'd6;

// Memory Mapped Peripheral Clock Divider Registers
logic [PRESCALER_WIDTH-1:0] spi_prescaler_reg;
logic [PRESCALER_WIDTH-1:0] i2c1_prescaler_reg;
logic [PRESCALER_WIDTH-1:0] i2c2_prescaler_reg;
logic [PRESCALER_WIDTH-1:0] uart1_prescaler_reg;
logic [PRESCALER_WIDTH-1:0] uart2_prescaler_reg;
logic [PRESCALER_WIDTH-1:0] adc_prescaler_reg;

// Prescaler write data
always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    spi_prescaler_reg   <= SPI_DEFAULT_PRESCALER;
    i2c1_prescaler_reg  <= I2C1_DEFAULT_PRESCALER;
    i2c2_prescaler_reg  <= I2C2_DEFAULT_PRESCALER;
    uart1_prescaler_reg <= UART1_DEFAULT_PRESCALER;
    uart2_prescaler_reg <= UART2_DEFAULT_PRESCALER;
    adc_prescaler_reg   <= ADC_DEFAULT_PRESCALER;
  end else begin
    for (int i = 0; i < PRESCALER_BYTES; i++) begin
      if (dmem_wmask[i]) begin
        case (dmem_addr[NUM_PRESCALER_WIDTH-1+2:0])
          'h00 : adc_prescaler_reg   [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          'h04 : spi_prescaler_reg   [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          'h08 : i2c1_prescaler_reg  [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          'h0c : i2c2_prescaler_reg  [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          'h10 : uart1_prescaler_reg [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          'h14 : uart2_prescaler_reg [i*8 +: 8] <= dmem_wdata[i*8 +: 8];
          default : ; // Empty
        endcase
      end
    end
  end
end

// Prescaler read data
always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    prescaler_rdata <= '0;
  end
  else begin
    for (int i = 0; i < PRESCALER_BYTES; i++) begin
      prescaler_rdata <= '0;

      case (dmem_addr[NUM_PRESCALER_WIDTH-1+2:0])
        'h00 : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? adc_prescaler_reg   [i*8 +: 8] : '0;
        'h04 : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? spi_prescaler_reg   [i*8 +: 8] : '0;
        'h08 : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? i2c1_prescaler_reg  [i*8 +: 8] : '0;
        'h0c : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? i2c2_prescaler_reg  [i*8 +: 8] : '0;
        'h10 : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? uart1_prescaler_reg [i*8 +: 8] : '0;
        'h14 : prescaler_rdata[i*8 +: 8] <= dmem_rmask[i] ? uart2_prescaler_reg [i*8 +: 8] : '0;
        default : prescaler_rdata[i*8 +: 8] <= '0;
      endcase
    end
  end
end 

// Clock Dividers
assign cpu_clk = clk; // CPU clock isn't divided, same as base clock

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) spi_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(spi_prescaler_reg),
  .clk_out(spi_clk)
);

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) i2c1_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(i2c1_prescaler_reg),
  .clk_out(i2c1_clk)
);

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) i2c2_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(i2c2_prescaler_reg),
  .clk_out(i2c2_clk)
);

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) uart1_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(uart1_prescaler_reg),
  .clk_out(uart1_clk)
);

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) uart2_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(uart2_prescaler_reg),
  .clk_out(uart2_clk)
);

clk_div #(
  .PRESCALER_WIDTH(PRESCALER_WIDTH)
) adc_clk_div0 (
  .clk(clk),
  .rst(rst),
  .prescaler(adc_prescaler_reg),
  .clk_out(adc_clk)
);

endmodule : clk_gen