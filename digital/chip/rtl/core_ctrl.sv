module core_ctrl (
  input  logic sys_clk,
  input  logic sys_rst,

  /* Dmem Interface */
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
  output logic adc_clk,

  /* Generated resets */
  output logic sys_rst_sync,
  output logic adp_trst_sync,
  output logic cpu_rst_sync,
  output logic spi_rst_sync,
  output logic i2c1_rst_sync,
  output logic i2c2_rst_sync,
  output logic uart1_rst_sync,
  output logic uart2_rst_sync,
  output logic adc_rst_sync
);

////////////////////////////////////////////////////////////////////////////////
// Reset Generation and Ordering
////////////////////////////////////////////////////////////////////////////////

// System Reset Synchronizer
acadia_rst_sync sys_rst_sync0 (
  .clk(sys_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(sys_rst_sync)
);

// CPU & Peripheral Reset Synchronizers
logic rst_sync_done;
assign rst_sync_done = !(spi_rst_sync   || i2c1_rst_sync  || 
                         i2c2_rst_sync  || uart1_rst_sync ||
                         uart2_rst_sync || adp_trst_sync);

acadia_rst_sync cpu_rst_sync0 (
  .clk(cpu_clk),
  .rst(sys_rst),
  .d(rst_sync_done),
  .q(cpu_rst_sync)
);

acadia_rst_sync adp_trst_sync0 (
  .clk(cpu_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(adp_trst_sync)
);

acadia_rst_sync spi_rst_sync0 (
  .clk(spi_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(spi_rst_sync)
);

acadia_rst_sync i2c1_rst_sync0 (
  .clk(i2c1_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(i2c1_rst_sync)
);

acadia_rst_sync i2c2_rst_sync0 (
  .clk(i2c2_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(i2c2_rst_sync)
);

acadia_rst_sync uart1_rst_sync0 (
  .clk(uart1_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(uart1_rst_sync)
);

acadia_rst_sync uart2_rst_sync0 (
  .clk(uart2_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(uart2_rst_sync)
);

acadia_rst_sync adc_rst_sync0 (
  .clk(adc_clk),
  .rst(sys_rst),
  .d(1'b1),
  .q(adc_rst_sync)
);

////////////////////////////////////////////////////////////////////////////////
// Clock Generation
////////////////////////////////////////////////////////////////////////////////
clk_gen clk_gen0 (
  .clk(sys_clk),
  .rst(sys_rst_sync),

  /* Dmem interface */
  .dmem_addr(dmem_addr),
  .dmem_rmask(dmem_rmask),
  .dmem_wmask(dmem_wmask),
  .dmem_wdata(dmem_wdata),
  .prescaler_rdata(prescaler_rdata),

  /* Generated clocks */
  .cpu_clk(cpu_clk),
  .spi_clk(spi_clk),
  .i2c1_clk(i2c1_clk),
  .i2c2_clk(i2c2_clk),
  .uart1_clk(uart1_clk),
  .uart2_clk(uart2_clk),
  .adc_clk(adc_clk)
);

endmodule : core_ctrl