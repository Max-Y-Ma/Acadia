////////////////////////////////////////////////////////////////////////////////
// 
// Boundary Cell Map:
// -----------------------------------------------------------------------------
// ORDER | CELL NAME    | PIN TYPE
// ------|--------------|---------
//   0   | qspi_io_i[0] |   IN
//   1   | qspi_io_i[1] |   IN
//   2   | qspi_io_i[2] |   IN
//   3   | qspi_io_i[3] |   IN
//   4   | qspi_io_o[0] |   OUT
//   5   | qspi_io_o[1] |   OUT
//   6   | qspi_io_o[2] |   OUT
//   7   | qspi_io_o[3] |   OUT
//   8   | qspi_io_t    |   TRI
//   9   | qspi_ck_o    |   OUT
//   10  | qspi_cs_o    |   OUT
//   11  | spi_mosi_o   |   OUT
//   12  | spi_sclk_o   |   OUT
//   13  | i2c1_sda_i   |   IN
//   14  | i2c1_sda_o   |   OUT
//   15  | i2c1_sda_t   |   TRI
//   16  | i2c1_scl_o   |   OUT
//   17  | i2c2_sda_i   |   IN
//   18  | i2c2_sda_o   |   OUT
//   19  | i2c2_sda_t   |   TRI
//   20  | i2c2_scl_o   |   OUT
//   21  | uart1_tx_o   |   OUT
//   22  | uart1_rx_i   |   IN
//   23  | uart2_tx_o   |   OUT
//   24  | uart2_rx_i   |   IN
//   25  | gpio_a_i[0]  |   IN
//   26  | gpio_a_i[1]  |   IN
//   27  | gpio_a_i[2]  |   IN
//   28  | gpio_a_i[3]  |   IN
//   29  | gpio_a_i[4]  |   IN
//   30  | gpio_a_i[5]  |   IN
//   31  | gpio_a_i[6]  |   IN
//   32  | gpio_a_i[7]  |   IN
//   33  | gpio_a_o[0]  |   OUT
//   34  | gpio_a_o[1]  |   OUT
//   35  | gpio_a_o[2]  |   OUT
//   36  | gpio_a_o[3]  |   OUT
//   37  | gpio_a_o[4]  |   OUT
//   38  | gpio_a_o[5]  |   OUT
//   39  | gpio_a_o[6]  |   OUT
//   40  | gpio_a_o[7]  |   OUT
//   41  | gpio_a_t[0]  |   TRI
//   42  | gpio_a_t[1]  |   TRI
//   43  | gpio_a_t[2]  |   TRI
//   44  | gpio_a_t[3]  |   TRI
//   45  | gpio_a_t[4]  |   TRI
//   46  | gpio_a_t[5]  |   TRI
//   47  | gpio_a_t[6]  |   TRI
//   48  | gpio_a_t[7]  |   TRI
//
////////////////////////////////////////////////////////////////////////////////

module adp_boundary_scan 
import adp_types::*;
(
  /* ADP Boundary Scan Interface */
  input  logic       adp_bscan_clk,
  input  logic       adp_bscan_rst,
  input  logic       adp_bscan_start,
  input  logic       adp_bscan_se,
  input  logic       adp_bscan_oe,
  input  logic       adp_bscan_shift_sel,
  input  logic       adp_bscan_out_sel,
  output logic       adp_bscan_end,

  /* IO Pin Interface */
  input  logic [3:0] qspi_io_i_buf,
  output logic [3:0] qspi_io_i,
  output logic [3:0] qspi_io_o_buf,
  input  logic [3:0] qspi_io_o,
  output logic       qspi_io_t_buf,
  input  logic       qspi_io_t,
  output logic       qspi_ck_o_buf,
  input  logic       qspi_ck_o,
  output logic       qspi_cs_o_buf,
  input  logic       qspi_cs_o,

  output logic       spi_mosi_o_buf,
  input  logic       spi_mosi_o,
  output logic       spi_sclk_o_buf,
  input  logic       spi_sclk_o,

  input  logic       i2c1_sda_i_buf,
  output logic       i2c1_sda_i,
  output logic       i2c1_sda_o_buf,
  input  logic       i2c1_sda_o,
  output logic       i2c1_sda_t_buf,
  input  logic       i2c1_sda_t,
  output logic       i2c1_scl_o_buf,
  input  logic       i2c1_scl_o,

  input  logic       i2c2_sda_i_buf,
  output logic       i2c2_sda_i,
  output logic       i2c2_sda_o_buf,
  input  logic       i2c2_sda_o,
  output logic       i2c2_sda_t_buf,
  input  logic       i2c2_sda_t,
  output logic       i2c2_scl_o_buf,
  input  logic       i2c2_scl_o,

  output logic       uart1_tx_o_buf,
  input  logic       uart1_tx_o,
  input  logic       uart1_rx_i_buf,
  output logic       uart1_rx_i,

  output logic       uart2_tx_o_buf,
  input  logic       uart2_tx_o,
  input  logic       uart2_rx_i_buf,
  output logic       uart2_rx_i,

  input  logic [7:0] gpio_a_i_buf,
  output logic [7:0] gpio_a_i,
  output logic [7:0] gpio_a_o_buf,
  input  logic [7:0] gpio_a_o,
  output logic [7:0] gpio_a_t_buf,
  input  logic [7:0] gpio_a_t
);

// Cell Port Assignments, Refer to Cell Map 
logic cell_in   [NUM_BOUNDARY_CELLS];
logic cell_out  [NUM_BOUNDARY_CELLS];
logic cell_conn [NUM_BOUNDARY_CELLS+1];

always_comb begin
  // QSPI Flash Interface Pins
  cell_in[0]   = qspi_io_i_buf[0];
  qspi_io_i[0] = cell_out[0];
  
  cell_in[1]   = qspi_io_i_buf[1];
  qspi_io_i[1] = cell_out[1];
  
  cell_in[2]   = qspi_io_i_buf[2];
  qspi_io_i[2] = cell_out[2];
  
  cell_in[3]   = qspi_io_i_buf[3];
  qspi_io_i[3] = cell_out[3];
  
  cell_in[4]       = qspi_io_o[0];
  qspi_io_o_buf[0] = cell_out[4];
  
  cell_in[5]       = qspi_io_o[1];
  qspi_io_o_buf[1] = cell_out[5];
  
  cell_in[6]       = qspi_io_o[2];
  qspi_io_o_buf[2] = cell_out[6];
  
  cell_in[7]       = qspi_io_o[3];
  qspi_io_o_buf[3] = cell_out[7];
  
  cell_in[8]    = qspi_io_t;
  qspi_io_t_buf = cell_out[8];
  
  cell_in[9]    = qspi_ck_o;
  qspi_ck_o_buf = cell_out[9];
  
  cell_in[10]   = qspi_cs_o;
  qspi_cs_o_buf = cell_out[10];
  
  /* SPI Interface Pins */
  cell_in[11]    = spi_mosi_o;
  spi_mosi_o_buf = cell_out[11];
  
  cell_in[12]    = spi_sclk_o;
  spi_sclk_o_buf = cell_out[12];
  
  /* I2C1 Interface Pins */
  cell_in[13] = i2c1_sda_i_buf;
  i2c1_sda_i  = cell_out[13];
  
  cell_in[14]    = i2c1_sda_o;
  i2c1_sda_o_buf = cell_out[14];
  
  cell_in[15]    = i2c1_sda_t;
  i2c1_sda_t_buf = cell_out[15];
  
  cell_in[16]    = i2c1_scl_o;
  i2c1_scl_o_buf = cell_out[16];
  
  /* I2C2 Interface Pins */
  cell_in[17] = i2c2_sda_i_buf;
  i2c2_sda_i  = cell_out[17];
  
  cell_in[18]    = i2c2_sda_o;
  i2c2_sda_o_buf = cell_out[18];
  
  cell_in[19]    = i2c2_sda_t;
  i2c2_sda_t_buf = cell_out[19];
  
  cell_in[20]    = i2c2_scl_o;
  i2c2_scl_o_buf = cell_out[20];
  
  /* UART1 Interface Pins */
  cell_in[21]    = uart1_tx_o;
  uart1_tx_o_buf = cell_out[21];
  
  cell_in[22] = uart1_rx_i_buf;
  uart1_rx_i  = cell_out[22];
  
  /* UART2 Interface Pins */
  cell_in[23]    = uart2_tx_o;
  uart2_tx_o_buf = cell_out[23];
  
  cell_in[24] = uart2_rx_i_buf;
  uart2_rx_i  = cell_out[24];
  
  /* GPIO Pins */
  cell_in[25] = gpio_a_i_buf[0];
  gpio_a_i[0] = cell_out[25];
  
  cell_in[26] = gpio_a_i_buf[1];
  gpio_a_i[1] = cell_out[26];
  
  cell_in[27] = gpio_a_i_buf[2];
  gpio_a_i[2] = cell_out[27];
  
  cell_in[28] = gpio_a_i_buf[3];
  gpio_a_i[3] = cell_out[28];
  
  cell_in[29] = gpio_a_i_buf[4];
  gpio_a_i[4] = cell_out[29];
  
  cell_in[30] = gpio_a_i_buf[5];
  gpio_a_i[5] = cell_out[30];
  
  cell_in[31] = gpio_a_i_buf[6];
  gpio_a_i[6] = cell_out[31];
  
  cell_in[32] = gpio_a_i_buf[7];
  gpio_a_i[7] = cell_out[32];
  
  cell_in[33]     = gpio_a_o[0];
  gpio_a_o_buf[0] = cell_out[33];
  
  cell_in[34]     = gpio_a_o[1];
  gpio_a_o_buf[1] = cell_out[34];
  
  cell_in[35]     = gpio_a_o[2];
  gpio_a_o_buf[2] = cell_out[35];
  
  cell_in[36]     = gpio_a_o[3];
  gpio_a_o_buf[3] = cell_out[36];
  
  cell_in[37]     = gpio_a_o[4];
  gpio_a_o_buf[4] = cell_out[37];
  
  cell_in[38]     = gpio_a_o[5];
  gpio_a_o_buf[5] = cell_out[38];
  
  cell_in[39]     = gpio_a_o[6];
  gpio_a_o_buf[6] = cell_out[39];
  
  cell_in[40]     = gpio_a_o[7];
  gpio_a_o_buf[7] = cell_out[40];
  
  cell_in[41]     = gpio_a_t[0];
  gpio_a_t_buf[0] = cell_out[41];
  
  cell_in[42]     = gpio_a_t[1];
  gpio_a_t_buf[1] = cell_out[42];
  
  cell_in[43]     = gpio_a_t[2];
  gpio_a_t_buf[2] = cell_out[43];
  
  cell_in[44]     = gpio_a_t[3];
  gpio_a_t_buf[3] = cell_out[44];
  
  cell_in[45]     = gpio_a_t[4];
  gpio_a_t_buf[4] = cell_out[45];
  
  cell_in[46]     = gpio_a_t[5];
  gpio_a_t_buf[5] = cell_out[46];
  
  cell_in[47]     = gpio_a_t[6];
  gpio_a_t_buf[6] = cell_out[47];
  
  cell_in[48]     = gpio_a_t[7];
  gpio_a_t_buf[7] = cell_out[48];
  
  // Assign cell boundary chain start and end 
  cell_conn[0]  = adp_bscan_start;
  adp_bscan_end = cell_conn[NUM_BOUNDARY_CELLS];
end

// Cell Generation
generate 
  for (genvar i = 0; i < NUM_BOUNDARY_CELLS; i++) begin
    adp_cell adp_cell0 (
      .clk(adp_bscan_clk),
      .rst(adp_bscan_rst),
      .se(adp_bscan_se),
      .oe(adp_bscan_oe),
      .shift_sel(adp_bscan_shift_sel),
      .out_sel(adp_bscan_out_sel),
      .in(cell_in[i]),
      .bin(cell_conn[i]),
      .out(cell_out[i]),
      .bout(cell_conn[i+1])
    );
  end
endgenerate

endmodule : adp_boundary_scan
