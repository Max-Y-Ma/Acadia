//systemVerilog HDL for "acadia", "adc_cap_dac_8_bit_diff_sar_control_diff"
//"systemVerilog"

module adc_cap_dac_8_bit_diff_sar_control_diff (
  input logic clk,
  input logic rst_n,

  input logic adc_en, //Needs to be high for at least one clk cycle to trigger a single ADC sample. You can also hold this high for continuous sampling.
  input logic comp_result, //Comparator output for decision making

  output logic s_in, //0 = float, 1 = connect A_IN to cap bots
  output logic s_c, //0 = float, 1 = connect cap tops to VDD/2 (precharge)
  output logic [2:0] dac_switches_top_0, //for every dac cap, 0 = A_IN, 2 = VDD, 4 = VSS (onehot)
  output logic [2:0] dac_switches_bot_0,
  output logic [2:0] dac_switches_top_1,
  output logic [2:0] dac_switches_bot_1,
  output logic [2:0] dac_switches_top_2,
  output logic [2:0] dac_switches_bot_2,
  output logic [2:0] dac_switches_top_3,
  output logic [2:0] dac_switches_bot_3,
  output logic [2:0] dac_switches_top_4,
  output logic [2:0] dac_switches_bot_4,
  output logic [2:0] dac_switches_top_5,
  output logic [2:0] dac_switches_bot_5,
  output logic [2:0] dac_switches_top_6,
  output logic [2:0] dac_switches_bot_6,
  output logic [2:0] dac_switches_top_7,
  output logic [2:0] dac_switches_bot_7,
  output logic [2:0] dummy_switch_top, //logic for the dummy cap, which will be tied to VSS in hold mode.
  output logic [2:0] dummy_switch_bot,

  output logic eoc_n, //High if busy, low if end of cycle reached. If low, output data is valid on output registers.
  output logic load_reg,
  output logic [7:0] reg_wdata
);

logic [2:0] dac_switches_reg_top_0;
logic [2:0] dac_switches_reg_bot_0;
logic [2:0] dac_switches_reg_top_1;
logic [2:0] dac_switches_reg_bot_1;
logic [2:0] dac_switches_reg_top_2;
logic [2:0] dac_switches_reg_bot_2;
logic [2:0] dac_switches_reg_top_3;
logic [2:0] dac_switches_reg_bot_3;
logic [2:0] dac_switches_reg_top_4;
logic [2:0] dac_switches_reg_bot_4;
logic [2:0] dac_switches_reg_top_5;
logic [2:0] dac_switches_reg_bot_5;
logic [2:0] dac_switches_reg_top_6;
logic [2:0] dac_switches_reg_bot_6;
logic [2:0] dac_switches_reg_top_7;
logic [2:0] dac_switches_reg_bot_7;

logic [2:0] dac_switches_reg_top_next_0;
logic [2:0] dac_switches_reg_bot_next_0;
logic [2:0] dac_switches_reg_top_next_1;
logic [2:0] dac_switches_reg_bot_next_1;
logic [2:0] dac_switches_reg_top_next_2;
logic [2:0] dac_switches_reg_bot_next_2;
logic [2:0] dac_switches_reg_top_next_3;
logic [2:0] dac_switches_reg_bot_next_3;
logic [2:0] dac_switches_reg_top_next_4;
logic [2:0] dac_switches_reg_bot_next_4;
logic [2:0] dac_switches_reg_top_next_5;
logic [2:0] dac_switches_reg_bot_next_5;
logic [2:0] dac_switches_reg_top_next_6;
logic [2:0] dac_switches_reg_bot_next_6;
logic [2:0] dac_switches_reg_top_next_7;
logic [2:0] dac_switches_reg_bot_next_7;

enum logic [3:0] {SAMPLE, HOLD7, HOLD6, HOLD5, HOLD4, HOLD3, HOLD2, HOLD1, HOLD0} c_state, n_state;

always_comb begin
  reg_wdata[0] = ~comp_result;
  reg_wdata[1] = dac_switches_top_1[1];
  reg_wdata[2] = dac_switches_top_2[1];
  reg_wdata[3] = dac_switches_top_3[1];
  reg_wdata[4] = dac_switches_top_4[1];
  reg_wdata[5] = dac_switches_top_5[1];
  reg_wdata[6] = dac_switches_top_6[1];
  reg_wdata[7] = dac_switches_top_7[1];
end

always_ff @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    dac_switches_reg_top_0 <= 3'b001;
    dac_switches_reg_bot_0 <= 3'b001;
    dac_switches_reg_top_1 <= 3'b001;
    dac_switches_reg_bot_1 <= 3'b001;
    dac_switches_reg_top_2 <= 3'b001;
    dac_switches_reg_bot_2 <= 3'b001;
    dac_switches_reg_top_3 <= 3'b001;
    dac_switches_reg_bot_3 <= 3'b001;
    dac_switches_reg_top_4 <= 3'b001;
    dac_switches_reg_bot_4 <= 3'b001;
    dac_switches_reg_top_5 <= 3'b001;
    dac_switches_reg_bot_5 <= 3'b001;
    dac_switches_reg_top_6 <= 3'b001;
    dac_switches_reg_bot_6 <= 3'b001;
    dac_switches_reg_top_7 <= 3'b001;
    dac_switches_reg_bot_7 <= 3'b001;
  end else begin
    dac_switches_reg_top_0 <= dac_switches_reg_top_next_0;
    dac_switches_reg_bot_0 <= dac_switches_reg_bot_next_0;
    dac_switches_reg_top_1 <= dac_switches_reg_top_next_1;
    dac_switches_reg_bot_1 <= dac_switches_reg_bot_next_1;
    dac_switches_reg_top_2 <= dac_switches_reg_top_next_2;
    dac_switches_reg_bot_2 <= dac_switches_reg_bot_next_2;
    dac_switches_reg_top_3 <= dac_switches_reg_top_next_3;
    dac_switches_reg_bot_3 <= dac_switches_reg_bot_next_3;
    dac_switches_reg_top_4 <= dac_switches_reg_top_next_4;
    dac_switches_reg_bot_4 <= dac_switches_reg_bot_next_4;
    dac_switches_reg_top_5 <= dac_switches_reg_top_next_5;
    dac_switches_reg_bot_5 <= dac_switches_reg_bot_next_5;
    dac_switches_reg_top_6 <= dac_switches_reg_top_next_6;
    dac_switches_reg_bot_6 <= dac_switches_reg_bot_next_6;
    dac_switches_reg_top_7 <= dac_switches_reg_top_next_7;
    dac_switches_reg_bot_7 <= dac_switches_reg_bot_next_7;
  end
end

always_ff @ (posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    c_state <= SAMPLE;
  end else begin
    c_state <= n_state;
  end
end

always_comb begin
  //Consider the adc free on default.
  eoc_n = 1'b0;

  //Set into S&R mode on default.
  s_in = 1'b1;
  s_c = 1'b1;
  dac_switches_top_0 = 3'b001;
  dac_switches_bot_0 = 3'b001;
  dac_switches_top_1 = 3'b001;
  dac_switches_bot_1 = 3'b001;
  dac_switches_top_2 = 3'b001;
  dac_switches_bot_2 = 3'b001;
  dac_switches_top_3 = 3'b001;
  dac_switches_bot_3 = 3'b001;
  dac_switches_top_4 = 3'b001;
  dac_switches_bot_4 = 3'b001;
  dac_switches_top_5 = 3'b001;
  dac_switches_bot_5 = 3'b001;
  dac_switches_top_6 = 3'b001;
  dac_switches_bot_6 = 3'b001;
  dac_switches_top_7 = 3'b001;
  dac_switches_bot_7 = 3'b001;
  dummy_switch_top = 3'b001;
  dummy_switch_bot = 3'b001;

  dac_switches_reg_top_next_0 = 3'b001;
  dac_switches_reg_bot_next_0 = 3'b001;
  dac_switches_reg_top_next_1 = 3'b001;
  dac_switches_reg_bot_next_1 = 3'b001;
  dac_switches_reg_top_next_2 = 3'b001;
  dac_switches_reg_bot_next_2 = 3'b001;
  dac_switches_reg_top_next_3 = 3'b001;
  dac_switches_reg_bot_next_3 = 3'b001;
  dac_switches_reg_top_next_4 = 3'b001;
  dac_switches_reg_bot_next_4 = 3'b001;
  dac_switches_reg_top_next_5 = 3'b001;
  dac_switches_reg_bot_next_5 = 3'b001;
  dac_switches_reg_top_next_6 = 3'b001;
  dac_switches_reg_bot_next_6 = 3'b001;
  dac_switches_reg_top_next_7 = 3'b001;
  dac_switches_reg_bot_next_7 = 3'b001;

  load_reg = 1'b0;

  n_state = c_state;
  case (c_state)
    SAMPLE: begin
      if (adc_en) begin
        n_state = HOLD7;
      end
    end

    HOLD7: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = 3'b100;
      dac_switches_bot_7 = 3'b010;

      dac_switches_top_6 = 3'b010;
      dac_switches_bot_6 = 3'b100;
      dac_switches_top_5 = 3'b010;
      dac_switches_bot_5 = 3'b100;
      dac_switches_top_4 = 3'b010;
      dac_switches_bot_4 = 3'b100;
      dac_switches_top_3 = 3'b010;
      dac_switches_bot_3 = 3'b100;
      dac_switches_top_2 = 3'b010;
      dac_switches_bot_2 = 3'b100;
      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_7 = 3'b100 >> comp_result;

      n_state = HOLD6;
    end

    HOLD6: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      
      dac_switches_top_6 = 3'b100;
      dac_switches_bot_6 = 3'b010;

      dac_switches_top_5 = 3'b010;
      dac_switches_bot_5 = 3'b100;
      dac_switches_top_4 = 3'b010;
      dac_switches_bot_4 = 3'b100;
      dac_switches_top_3 = 3'b010;
      dac_switches_bot_3 = 3'b100;
      dac_switches_top_2 = 3'b010;
      dac_switches_bot_2 = 3'b100;
      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_6 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD5;
    end

    HOLD5: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      
      dac_switches_top_5 = 3'b100;
      dac_switches_bot_5 = 3'b010;

      dac_switches_top_4 = 3'b010;
      dac_switches_bot_4 = 3'b100;
      dac_switches_top_3 = 3'b010;
      dac_switches_bot_3 = 3'b100;
      dac_switches_top_2 = 3'b010;
      dac_switches_bot_2 = 3'b100;
      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_5 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD4;
    end

    HOLD4: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      dac_switches_top_5 = dac_switches_reg_top_5;
      dac_switches_bot_5 = dac_switches_reg_bot_5;
      
      dac_switches_top_4 = 3'b100;
      dac_switches_bot_4 = 3'b010;

      dac_switches_top_3 = 3'b010;
      dac_switches_bot_3 = 3'b100;
      dac_switches_top_2 = 3'b010;
      dac_switches_bot_2 = 3'b100;
      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_4 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD3;
    end

    HOLD3: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      dac_switches_top_5 = dac_switches_reg_top_5;
      dac_switches_bot_5 = dac_switches_reg_bot_5;
      dac_switches_top_4 = dac_switches_reg_top_4;
      dac_switches_bot_4 = dac_switches_reg_bot_4;
      
      dac_switches_top_3 = 3'b100;
      dac_switches_bot_3 = 3'b010;

      dac_switches_top_2 = 3'b010;
      dac_switches_bot_2 = 3'b100;
      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_3 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD2;
    end

    HOLD2: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      dac_switches_top_5 = dac_switches_reg_top_5;
      dac_switches_bot_5 = dac_switches_reg_bot_5;
      dac_switches_top_4 = dac_switches_reg_top_4;
      dac_switches_bot_4 = dac_switches_reg_bot_4;
      dac_switches_top_3 = dac_switches_reg_top_3;
      dac_switches_bot_3 = dac_switches_reg_bot_3;
      
      dac_switches_top_2 = 3'b100;
      dac_switches_bot_2 = 3'b010;

      dac_switches_top_1 = 3'b010;
      dac_switches_bot_1 = 3'b100;
      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_2 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD1;
    end

    HOLD1: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      dac_switches_top_5 = dac_switches_reg_top_5;
      dac_switches_bot_5 = dac_switches_reg_bot_5;
      dac_switches_top_4 = dac_switches_reg_top_4;
      dac_switches_bot_4 = dac_switches_reg_bot_4;
      dac_switches_top_3 = dac_switches_reg_top_3;
      dac_switches_bot_3 = dac_switches_reg_bot_3;
      dac_switches_top_2 = dac_switches_reg_top_2;
      dac_switches_bot_2 = dac_switches_reg_bot_2;
      
      dac_switches_top_1 = 3'b100;
      dac_switches_bot_1 = 3'b010;

      dac_switches_top_0 = 3'b010;
      dac_switches_bot_0 = 3'b100;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = dac_switches_top_0;
      dac_switches_reg_bot_next_0 = dac_switches_bot_0;
      dac_switches_reg_top_next_1 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_1 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      n_state = HOLD0;
    end

    HOLD0: begin
      eoc_n = 1'b1;

      s_in = 1'b0;
      s_c = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_7 = dac_switches_reg_top_7;
      dac_switches_bot_7 = dac_switches_reg_bot_7;
      dac_switches_top_6 = dac_switches_reg_top_6;
      dac_switches_bot_6 = dac_switches_reg_bot_6;
      dac_switches_top_5 = dac_switches_reg_top_5;
      dac_switches_bot_5 = dac_switches_reg_bot_5;
      dac_switches_top_4 = dac_switches_reg_top_4;
      dac_switches_bot_4 = dac_switches_reg_bot_4;
      dac_switches_top_3 = dac_switches_reg_top_3;
      dac_switches_bot_3 = dac_switches_reg_bot_3;
      dac_switches_top_2 = dac_switches_reg_top_2;
      dac_switches_bot_2 = dac_switches_reg_bot_2;
      dac_switches_top_1 = dac_switches_reg_top_1;
      dac_switches_bot_1 = dac_switches_reg_bot_1;
      
      dac_switches_top_0 = 3'b100;
      dac_switches_bot_0 = 3'b010;

      dummy_switch_top = 3'b010;
      dummy_switch_bot = 3'b100;

      dac_switches_reg_top_next_0 = 3'b100 >> ~comp_result;
      dac_switches_reg_bot_next_0 = 3'b100 >> comp_result;
      dac_switches_reg_top_next_1 = dac_switches_top_1;
      dac_switches_reg_bot_next_1 = dac_switches_bot_1;
      dac_switches_reg_top_next_2 = dac_switches_top_2;
      dac_switches_reg_bot_next_2 = dac_switches_bot_2;
      dac_switches_reg_top_next_3 = dac_switches_top_3;
      dac_switches_reg_bot_next_3 = dac_switches_bot_3;
      dac_switches_reg_top_next_4 = dac_switches_top_4;
      dac_switches_reg_bot_next_4 = dac_switches_bot_4;
      dac_switches_reg_top_next_5 = dac_switches_top_5;
      dac_switches_reg_bot_next_5 = dac_switches_bot_5;
      dac_switches_reg_top_next_6 = dac_switches_top_6;
      dac_switches_reg_bot_next_6 = dac_switches_bot_6;
      dac_switches_reg_top_next_7 = dac_switches_top_7;
      dac_switches_reg_bot_next_7 = dac_switches_bot_7;

      load_reg = 1'b1;
      n_state = SAMPLE;
    end
  endcase
end

endmodule
