module analog_ctrl (
  input logic clk,
  input logic rst,

  input logic analog_clk,
  input logic analog_rst,

  /* Memory Mapped Bus Interface */
  input  logic [31:0] dmem_addr,
  input  logic [3:0]  dmem_rmask,
  input  logic [3:0]  dmem_wmask,
  input  logic [31:0] dmem_wdata,
  output logic [31:0] analog_rdata,

  /* ADP Interface */
  output logic [31:0] adp_core_adc,
  output logic [31:0] adp_core_dac,
  input  logic [31:0] adp_wdata,
  input  logic        adp_adc_we,
  input  logic        adp_dac_we,

  /* ADC Register Interface */
  input  logic        adc_eoc_n,  // End of Conversation
  input  logic [7:0]  adc_data, 
  output logic        adc_firmware_en,
  output logic        adc_adc_en,
  output logic        adc_calib_en,
  output logic        adc_eoc_2ff,
  output logic        adc_ext_opt,

  /* DAC Register Interface */
  output logic [7:0] dac_reg_slow,
  output logic dac_ack
);

// For the memory map
// 32'h70014000 : ADC
// 32'h70014001 : DAC

localparam ANALOG_BYTES = 4;
localparam ANALOG_ADDR_BIT = 2;
localparam ADC_OFFSET = 0;
localparam DAC_OFFSET = 1;

// ADC Register Format
// FIELD | SRC | DEST |DESC
// -------------------------
// [11]  | CPU | ADC | Pass transistor enable
// [10]  | CPU | ADC | Enable Firmware Control
// [9]   | CPU | ADC | Enable ADC
// [8]   | CPU | ADC | CALIBRATE ADC
// [7:0] | ADC | CPU | 8 Bit ADC Data Value

localparam EXT_OPT_BIT      = 11;
localparam FIRMWARE_EN_BIT  = 10;
localparam ADC_EN_BIT       = 9;
localparam CALIBRATE_EN_BIT = 8;
localparam ADC_DATA_BIT     = 7;

logic [31:0] adc_reg;

logic adc_firmware_en_fast;
logic adc_adc_en_fast;
logic adc_calib_en_fast;

logic dac_rdy;
logic dac_rdy_slow;
logic dac_rdy_slow_delay;
logic dac_resp;
logic dac_resp_delay;
logic load_dac_reg;
logic dac_busy;
logic dac_busy_next;

logic [7:0] dac_reg;

logic adc_eoc_n_2ff;
logic adc_eoc_n_2ff_delayed;

assign adc_firmware_en_fast = adc_reg[FIRMWARE_EN_BIT];
assign adc_adc_en_fast      = adc_reg[ADC_EN_BIT];
assign adc_calib_en_fast    = adc_reg[CALIBRATE_EN_BIT];
assign adc_ext_opt          = adc_reg[EXT_OPT_BIT];

// Synchronize ADC
acadia_double_sync adc_firmware_en_fast_2ff (.clk(analog_clk), .d(adc_firmware_en_fast), .q(adc_firmware_en));
acadia_double_sync adc_adc_en_fast_2ff (.clk(analog_clk), .d(adc_adc_en_fast), .q(adc_adc_en));
acadia_double_sync adc_calib_en_fast_2ff (.clk(analog_clk), .d(adc_calib_en_fast), .q(adc_calib_en));

// Synchronize Load
acadia_double_sync eoc_2ff (.clk(clk), .d(adc_eoc_n), .q(adc_eoc_n_2ff));
assign adc_eoc_2ff = adc_eoc_n_2ff_delayed && ~adc_eoc_n_2ff;

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    adc_eoc_n_2ff_delayed <= '1;
  end else begin
    adc_eoc_n_2ff_delayed <= adc_eoc_n_2ff;
  end
end

////////////////////////////////////////////////////////////////////////////////
///// DAC Load/CDC logic
////////////////////////////////////////////////////////////////////////////////
acadia_double_sync dac_rdy_2ff (.clk(analog_clk), .d(dac_rdy), .q(dac_rdy_slow));

always_ff @(negedge analog_clk, posedge analog_rst) begin
  if(analog_rst) begin
    dac_rdy_slow_delay  <= '0;
    dac_reg_slow        <= '0;
  end else begin
    dac_rdy_slow_delay  <= dac_rdy_slow;

    if(load_dac_reg) begin
      dac_reg_slow <= dac_reg;
    end
  end
end

assign load_dac_reg = dac_rdy_slow ^ dac_rdy_slow_delay;

acadia_double_sync dac_resp_2ff (.clk(clk), .d(dac_rdy_slow_delay), .q(dac_resp));

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    dac_resp_delay  <= '0;
    dac_busy        <= '0;
  end else begin 
    dac_resp_delay <= dac_resp;

    dac_busy <= dac_busy_next;
  end
end

always_comb begin
  dac_busy_next = dac_busy;

  if( ((dmem_addr[ANALOG_ADDR_BIT] == DAC_OFFSET) && dmem_wmask[0]) || adp_dac_we ) begin
    dac_busy_next = 1'b1;
  end

  if(dac_ack) begin
    dac_busy_next = '0;
  end
end

assign dac_ack = dac_resp ^ dac_resp_delay;

////////////////////////////////////////////////////////////////////////////////
///// Mem map controller
////////////////////////////////////////////////////////////////////////////////
always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    adc_reg <= 'b1 << EXT_OPT_BIT;
  end 
  else begin
    // Acadia Core Writes
    if (adp_adc_we) begin
      adc_reg[31:8] <= adp_wdata[31:8];
    end
    else if (dmem_addr[ANALOG_ADDR_BIT] == ADC_OFFSET) begin
      for (int i = 1; i < ANALOG_BYTES; i++) begin
        if (dmem_wmask[i]) begin
          adc_reg[i*8 +: 8] <= dmem_wdata[i*8 +: 8];
        end
      end
    end

    // ADC Data Writes
    if (adc_eoc_2ff) begin
      adc_reg[7:0] <= adc_data;
    end
  end
end

always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    dac_reg <= '0;
    dac_rdy <= '0;
  end else begin
    if (adp_dac_we) begin
      dac_rdy <= ~dac_rdy;
      dac_reg <= adp_wdata[7:0];
    end
    else if (dmem_addr[ANALOG_ADDR_BIT] == DAC_OFFSET) begin
      if (dmem_wmask[0] && ~dac_busy) begin
        dac_rdy <= ~dac_rdy;
        dac_reg <= dmem_wdata[7:0];
      end
    end
  end
end

// Analog read data
always_ff @(posedge clk, posedge rst) begin
  if (rst) begin
    analog_rdata <= '0;
  end
  else begin
    for (int i = 0; i < ANALOG_BYTES; i++) begin
      case (dmem_addr[ANALOG_ADDR_BIT])
        'h0 : analog_rdata[i*8 +: 8] <= dmem_rmask[i] ? adc_reg[i*8 +: 8] : '0;
        'h1 : begin 
          analog_rdata[0 +: 8]  <= dmem_rmask[0] ? dac_reg : '0;
          analog_rdata[8 +: 8]  <= '0;
          analog_rdata[16 +: 8] <= '0;
          analog_rdata[24 +: 8] <= dmem_rmask[3] ? {dac_busy, 7'b0} : '0;
        end
      endcase
    end
  end
end 

// ADP Registers
assign adp_core_adc = adc_reg;
assign adp_core_dac = dac_reg;

endmodule : analog_ctrl