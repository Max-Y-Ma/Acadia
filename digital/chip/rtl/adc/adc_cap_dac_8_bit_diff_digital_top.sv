//systemVerilog HDL for "acadia", "adc_cap_dac_8_bit_diff_digital_top_verilog" "systemVerilog"

module adc_cap_dac_8_bit_diff_digital_top (
  /* Digital interface */
  input logic CLK, //9MHz
  input logic RST, //Async rst
  input logic FIRM_EN, //high if core is alive. otherwise, adc will proceed with dead core behavior
  input logic ADC_EN, //valid only if core is alive. Initiate ADC sample.
  input logic CALIB_EN, //valid only if core is alive. Calibrate ADC.
  
  output logic [7:0] Q, //8 bit ADC data
  output logic EOC_N, //High if busy, low if end of cycle reached. If low, output data is valid on output registers.

  /* Analog Interface */
  input logic COMP_RESULT,

  output logic S_C,
  output logic S_C1,
  output logic [1:0] DAC_SWITCHES_TOP_0, //for every dac cap, 0 = A_IN, 2 = VDD, 4 = VSS (onehot)
  output logic [1:0] DAC_SWITCHES_BOT_0,
  output logic [1:0] DAC_SWITCHES_TOP_1,
  output logic [1:0] DAC_SWITCHES_BOT_1,
  output logic [1:0] DAC_SWITCHES_TOP_2,
  output logic [1:0] DAC_SWITCHES_BOT_2,
  output logic [1:0] DAC_SWITCHES_TOP_3,
  output logic [1:0] DAC_SWITCHES_BOT_3,
  output logic [1:0] DAC_SWITCHES_TOP_4,
  output logic [1:0] DAC_SWITCHES_BOT_4,
  output logic [1:0] DAC_SWITCHES_TOP_5,
  output logic [1:0] DAC_SWITCHES_BOT_5,
  output logic [1:0] DAC_SWITCHES_TOP_6,
  output logic [1:0] DAC_SWITCHES_BOT_6,
  output logic [1:0] DAC_SWITCHES_TOP_7,
  output logic [1:0] DAC_SWITCHES_BOT_7,
  output logic [1:0] DUMMY_SWITCH_TOP, //logic for the dummy cap, which will be tied to VSS in hold mode.
  output logic [1:0] DUMMY_SWITCH_BOT,

  output logic [3:0] CN,
  output logic [3:0] CP
);

assign S_C1 = S_C;

logic load_reg;
logic [7:0] reg_wdata;

logic dead_adc_en;
logic real_adc_en;
logic dead_calib_en;
logic [2:0] dead_calib_counter;
logic real_calib_en;

always_comb begin
  if (FIRM_EN) begin
    real_adc_en = ADC_EN;
    real_calib_en = CALIB_EN;
  end else begin
    real_adc_en = dead_adc_en;
    real_calib_en = dead_calib_en;
  end
end

always_ff @ (posedge CLK or posedge RST) begin
  if (RST) begin
    dead_adc_en <= 1'b0;
    dead_calib_en <= 1'b0;
    dead_calib_counter <= 2'b00;
  end else begin
    dead_adc_en <= 1'b1;
    if (dead_calib_counter == 2'b11) begin
      dead_calib_en <= 1'b0;
    end else begin
      dead_calib_en <= 1'b1;
      dead_calib_counter <= dead_calib_counter + 1'b1;
    end
  end
end

adc_cap_dac_8_bit_diff_sar_control_diff_w_regs sar_control0 (
  .clk(CLK),
  .rst(RST),

  .adc_en(real_adc_en), //Needs to be high for at least one clk cycle to trigger a single ADC sample. You can also hold this high for continuous sampling.
  .calib_en(real_calib_en),
  .comp_result(COMP_RESULT), //Comparator output for decision making

  .s_c(S_C), //0 = float, 1 = connect cap tops to VDD/2 (precharge)
  .dac_switches_top_0(DAC_SWITCHES_TOP_0), //for every dac cap, 0 = A_IN, 2 = VDD, 4 = VSS (onehot)
  .dac_switches_bot_0(DAC_SWITCHES_BOT_0),
  .dac_switches_top_1(DAC_SWITCHES_TOP_1),
  .dac_switches_bot_1(DAC_SWITCHES_BOT_1),
  .dac_switches_top_2(DAC_SWITCHES_TOP_2),
  .dac_switches_bot_2(DAC_SWITCHES_BOT_2),
  .dac_switches_top_3(DAC_SWITCHES_TOP_3),
  .dac_switches_bot_3(DAC_SWITCHES_BOT_3),
  .dac_switches_top_4(DAC_SWITCHES_TOP_4),
  .dac_switches_bot_4(DAC_SWITCHES_BOT_4),
  .dac_switches_top_5(DAC_SWITCHES_TOP_5),
  .dac_switches_bot_5(DAC_SWITCHES_BOT_5),
  .dac_switches_top_6(DAC_SWITCHES_TOP_6),
  .dac_switches_bot_6(DAC_SWITCHES_BOT_6),
  .dac_switches_top_7(DAC_SWITCHES_TOP_7),
  .dac_switches_bot_7(DAC_SWITCHES_BOT_7),
  .dummy_switch_top(DUMMY_SWITCH_TOP), //logic for the dummy cap, which will be tied to VSS in hold mode.
  .dummy_switch_bot(DUMMY_SWITCH_BOT),

  .eoc_n(EOC_N), //High if busy, low if end of cycle reached. If low, output data is valid on output registers.
  .load_reg(load_reg),
  .reg_wdata(reg_wdata),

  .cn(CN),
  .cp(CP)
);

adc_cap_dac_8_bit_diff_adc_regs adc_regs0 (
  .clk(CLK),
  .rst(RST),
  .d(reg_wdata),
  .load(load_reg),
  .q(Q)
);

endmodule
