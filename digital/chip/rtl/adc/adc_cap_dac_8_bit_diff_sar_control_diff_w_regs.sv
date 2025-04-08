//systemVerilog HDL for "acadia", "adc_cap_dac_8_bit_diff_sar_control_diff_w_regs"
//"systemVerilog"

module adc_cap_dac_8_bit_diff_sar_control_diff_w_regs (
  input logic clk,
  input logic rst,

  input logic adc_en, //Needs to be high for at least one clk cycle to trigger a single ADC sample. You can also hold this high for continuous sampling.
  input logic calib_en,
  input logic comp_result, //Comparator output for decision making

  output logic s_c, //0 = float, 1 = connect cap tops to VDD/2 (precharge)
  output logic [1:0] dac_switches_top_0, //for every dac cap, 0 = A_IN, 2 = VDD, 4 = VSS (onehot)
  output logic [1:0] dac_switches_bot_0,
  output logic [1:0] dac_switches_top_1,
  output logic [1:0] dac_switches_bot_1,
  output logic [1:0] dac_switches_top_2,
  output logic [1:0] dac_switches_bot_2,
  output logic [1:0] dac_switches_top_3,
  output logic [1:0] dac_switches_bot_3,
  output logic [1:0] dac_switches_top_4,
  output logic [1:0] dac_switches_bot_4,
  output logic [1:0] dac_switches_top_5,
  output logic [1:0] dac_switches_bot_5,
  output logic [1:0] dac_switches_top_6,
  output logic [1:0] dac_switches_bot_6,
  output logic [1:0] dac_switches_top_7,
  output logic [1:0] dac_switches_bot_7,
  output logic [1:0] dummy_switch_top, //logic for the dummy cap, which will be tied to VSS in hold mode.
  output logic [1:0] dummy_switch_bot,

  output logic eoc_n, //High if busy, low if end of cycle reached. If low, output data is valid on output registers.
  output logic load_reg,
  output logic [7:0] reg_wdata,

  output logic [3:0] cn,
  output logic [3:0] cp
);

logic s_c_next;

logic [1:0] dac_switches_top_next_0;
logic [1:0] dac_switches_bot_next_0;
logic [1:0] dac_switches_top_next_1;
logic [1:0] dac_switches_bot_next_1;
logic [1:0] dac_switches_top_next_2;
logic [1:0] dac_switches_bot_next_2;
logic [1:0] dac_switches_top_next_3;
logic [1:0] dac_switches_bot_next_3;
logic [1:0] dac_switches_top_next_4;
logic [1:0] dac_switches_bot_next_4;
logic [1:0] dac_switches_top_next_5;
logic [1:0] dac_switches_bot_next_5;
logic [1:0] dac_switches_top_next_6;
logic [1:0] dac_switches_bot_next_6;
logic [1:0] dac_switches_top_next_7;
logic [1:0] dac_switches_bot_next_7;
logic [1:0] dummy_switch_top_next;
logic [1:0] dummy_switch_bot_next;

enum logic [3:0] {SAMPLE, OFF_SAMPLE, HOLD7, HOLD6, HOLD5, HOLD4, HOLD3, HOLD2, HOLD1, HOLD0, OFF_START, OFF_START1, OFF_DECISION, OFF_RAMP1, OFF_RAMP2, OFF_DONE} c_state, n_state;

logic [3:0] cn_next;
logic [3:0] cp_next;
logic [3:0] cn_store;
logic [3:0] cp_store;
logic [3:0] cn_store_next;
logic [3:0] cp_store_next;
logic off_bit;
logic off_bit_next;

logic [4:0] cn_avg;
logic [4:0] cp_avg;

assign cn_avg = ({1'b0, cn_store} + {1'b0, cn} >> 1'b1);
assign cp_avg = ({1'b0, cp_store} + {1'b0, cp} >> 1'b1);

always_comb begin
  reg_wdata[0] = ~comp_result;
  reg_wdata[1] = dac_switches_top_1[0];
  reg_wdata[2] = dac_switches_top_2[0];
  reg_wdata[3] = dac_switches_top_3[0];
  reg_wdata[4] = dac_switches_top_4[0];
  reg_wdata[5] = dac_switches_top_5[0];
  reg_wdata[6] = dac_switches_top_6[0];
  reg_wdata[7] = dac_switches_top_7[0];
end

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    s_c <= 1'b1;

    dac_switches_top_0 <= 2'b00;
    dac_switches_bot_0 <= 2'b00;
    dac_switches_top_1 <= 2'b00;
    dac_switches_bot_1 <= 2'b00;
    dac_switches_top_2 <= 2'b00;
    dac_switches_bot_2 <= 2'b00;
    dac_switches_top_3 <= 2'b00;
    dac_switches_bot_3 <= 2'b00;
    dac_switches_top_4 <= 2'b00;
    dac_switches_bot_4 <= 2'b00;
    dac_switches_top_5 <= 2'b00;
    dac_switches_bot_5 <= 2'b00;
    dac_switches_top_6 <= 2'b00;
    dac_switches_bot_6 <= 2'b00;
    dac_switches_top_7 <= 2'b00;
    dac_switches_bot_7 <= 2'b00;

    dummy_switch_top <= 2'b00;
    dummy_switch_bot <= 2'b00;
  end else begin
    s_c <= s_c_next;

    dac_switches_top_0 <= dac_switches_top_next_0;
    dac_switches_bot_0 <= dac_switches_bot_next_0;
    dac_switches_top_1 <= dac_switches_top_next_1;
    dac_switches_bot_1 <= dac_switches_bot_next_1;
    dac_switches_top_2 <= dac_switches_top_next_2;
    dac_switches_bot_2 <= dac_switches_bot_next_2;
    dac_switches_top_3 <= dac_switches_top_next_3;
    dac_switches_bot_3 <= dac_switches_bot_next_3;
    dac_switches_top_4 <= dac_switches_top_next_4;
    dac_switches_bot_4 <= dac_switches_bot_next_4;
    dac_switches_top_5 <= dac_switches_top_next_5;
    dac_switches_bot_5 <= dac_switches_bot_next_5;
    dac_switches_top_6 <= dac_switches_top_next_6;
    dac_switches_bot_6 <= dac_switches_bot_next_6;
    dac_switches_top_7 <= dac_switches_top_next_7;
    dac_switches_bot_7 <= dac_switches_bot_next_7;

    dummy_switch_top <= dummy_switch_top_next;
    dummy_switch_bot <= dummy_switch_bot_next;
  end
end

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    cn <= '0;
    cp <= '0;
    cn_store <= '0;
    cp_store <= '0;
    off_bit <= 1'b0;
  end else begin
    cn <= cn_next;
    cp <= cp_next;
    cn_store <= cn_store_next;
    cp_store <= cp_store_next;
    off_bit <= off_bit_next;
  end
end

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    c_state <= SAMPLE;
  end else begin
    c_state <= n_state;
  end
end

always_comb begin
  //Consider the adc free on default.
  eoc_n = 1'b0;

  //Set into S&R mode on default.
  s_c_next = 1'b1;
  dac_switches_top_next_0 = 2'b00;
  dac_switches_bot_next_0 = 2'b00;
  dac_switches_top_next_1 = 2'b00;
  dac_switches_bot_next_1 = 2'b00;
  dac_switches_top_next_2 = 2'b00;
  dac_switches_bot_next_2 = 2'b00;
  dac_switches_top_next_3 = 2'b00;
  dac_switches_bot_next_3 = 2'b00;
  dac_switches_top_next_4 = 2'b00;
  dac_switches_bot_next_4 = 2'b00;
  dac_switches_top_next_5 = 2'b00;
  dac_switches_bot_next_5 = 2'b00;
  dac_switches_top_next_6 = 2'b00;
  dac_switches_bot_next_6 = 2'b00;
  dac_switches_top_next_7 = 2'b00;
  dac_switches_bot_next_7 = 2'b00;
  dummy_switch_top_next = 2'b00;
  dummy_switch_bot_next = 2'b00;

  load_reg = 1'b0;

  cn_next = cn;
  cp_next = cp;

  cn_store_next = cn_store;
  cp_store_next = cp_store;

  off_bit_next = off_bit;

  n_state = c_state;

  case (c_state)
    SAMPLE: begin
      if (calib_en) begin
        s_c_next = 1'b1;

        n_state = OFF_START;
      end else if (adc_en) begin
        s_c_next = 1'b0;

        //In order:
        //1. Any decisions already made should be held.
        //2. The current decision maker is set to VDD.
        //3. Any decisions yet to be made are set to VSS.
        //4. The dummy switch is always set to VSS.
        dac_switches_top_next_7 = 2'b00;
        dac_switches_bot_next_7 = 2'b00;

        dac_switches_top_next_6 = 2'b00;
        dac_switches_bot_next_6 = 2'b00;
        dac_switches_top_next_5 = 2'b00;
        dac_switches_bot_next_5 = 2'b00;
        dac_switches_top_next_4 = 2'b00;
        dac_switches_bot_next_4 = 2'b00;
        dac_switches_top_next_3 = 2'b00;
        dac_switches_bot_next_3 = 2'b00;
        dac_switches_top_next_2 = 2'b00;
        dac_switches_bot_next_2 = 2'b00;
        dac_switches_top_next_1 = 2'b00;
        dac_switches_bot_next_1 = 2'b00;
        dac_switches_top_next_0 = 2'b00;
        dac_switches_bot_next_0 = 2'b00;

        dummy_switch_top_next = 2'b00;
        dummy_switch_bot_next = 2'b00;

        n_state = OFF_SAMPLE;
      end
    end

    OFF_SAMPLE: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dac_switches_top_next_6 = 2'b01;
      dac_switches_bot_next_6 = 2'b10;
      dac_switches_top_next_5 = 2'b01;
      dac_switches_bot_next_5 = 2'b10;
      dac_switches_top_next_4 = 2'b01;
      dac_switches_bot_next_4 = 2'b10;
      dac_switches_top_next_3 = 2'b01;
      dac_switches_bot_next_3 = 2'b10;
      dac_switches_top_next_2 = 2'b01;
      dac_switches_bot_next_2 = 2'b10;
      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD7;
    end

    HOLD7: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_7 = 2'b10 >> comp_result;
      
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;

      dac_switches_top_next_5 = 2'b01;
      dac_switches_bot_next_5 = 2'b10;
      dac_switches_top_next_4 = 2'b01;
      dac_switches_bot_next_4 = 2'b10;
      dac_switches_top_next_3 = 2'b01;
      dac_switches_bot_next_3 = 2'b10;
      dac_switches_top_next_2 = 2'b01;
      dac_switches_bot_next_2 = 2'b10;
      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD6;
    end

    HOLD6: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_6 = 2'b10 >> comp_result;
      
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;

      dac_switches_top_next_4 = 2'b01;
      dac_switches_bot_next_4 = 2'b10;
      dac_switches_top_next_3 = 2'b01;
      dac_switches_bot_next_3 = 2'b10;
      dac_switches_top_next_2 = 2'b01;
      dac_switches_bot_next_2 = 2'b10;
      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD5;
    end

    HOLD5: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = dac_switches_top_6;
      dac_switches_bot_next_6 = dac_switches_bot_6;
      dac_switches_top_next_5 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_5 = 2'b10 >> comp_result;
      
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;

      dac_switches_top_next_3 = 2'b01;
      dac_switches_bot_next_3 = 2'b10;
      dac_switches_top_next_2 = 2'b01;
      dac_switches_bot_next_2 = 2'b10;
      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD4;
    end

    HOLD4: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = dac_switches_top_6;
      dac_switches_bot_next_6 = dac_switches_bot_6;
      dac_switches_top_next_5 = dac_switches_top_5;
      dac_switches_bot_next_5 = dac_switches_bot_5;
      dac_switches_top_next_4 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_4 = 2'b10 >> comp_result;
      
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;

      dac_switches_top_next_2 = 2'b01;
      dac_switches_bot_next_2 = 2'b10;
      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD3;
    end

    HOLD3: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = dac_switches_top_6;
      dac_switches_bot_next_6 = dac_switches_bot_6;
      dac_switches_top_next_5 = dac_switches_top_5;
      dac_switches_bot_next_5 = dac_switches_bot_5;
      dac_switches_top_next_4 = dac_switches_top_4;
      dac_switches_bot_next_4 = dac_switches_bot_4;
      dac_switches_top_next_3 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_3 = 2'b10 >> comp_result;
      
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;

      dac_switches_top_next_1 = 2'b01;
      dac_switches_bot_next_1 = 2'b10;
      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD2;
    end

    HOLD2: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = dac_switches_top_6;
      dac_switches_bot_next_6 = dac_switches_bot_6;
      dac_switches_top_next_5 = dac_switches_top_5;
      dac_switches_bot_next_5 = dac_switches_bot_5;
      dac_switches_top_next_4 = dac_switches_top_4;
      dac_switches_bot_next_4 = dac_switches_bot_4;
      dac_switches_top_next_3 = dac_switches_top_3;
      dac_switches_bot_next_3 = dac_switches_bot_3;
      dac_switches_top_next_2 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_2 = 2'b10 >> comp_result;
      
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;

      dac_switches_top_next_0 = 2'b01;
      dac_switches_bot_next_0 = 2'b10;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD1;
    end

    HOLD1: begin
      eoc_n = 1'b1;

      s_c_next = 1'b0;

      //In order:
      //1. Any decisions already made should be held.
      //2. The current decision maker is set to VDD.
      //3. Any decisions yet to be made are set to VSS.
      //4. The dummy switch is always set to VSS.
      dac_switches_top_next_7 = dac_switches_top_7;
      dac_switches_bot_next_7 = dac_switches_bot_7;
      dac_switches_top_next_6 = dac_switches_top_6;
      dac_switches_bot_next_6 = dac_switches_bot_6;
      dac_switches_top_next_5 = dac_switches_top_5;
      dac_switches_bot_next_5 = dac_switches_bot_5;
      dac_switches_top_next_4 = dac_switches_top_4;
      dac_switches_bot_next_4 = dac_switches_bot_4;
      dac_switches_top_next_3 = dac_switches_top_3;
      dac_switches_bot_next_3 = dac_switches_bot_3;
      dac_switches_top_next_2 = dac_switches_top_2;
      dac_switches_bot_next_2 = dac_switches_bot_2;
      dac_switches_top_next_1 = 2'b10 >> ~comp_result;
      dac_switches_bot_next_1 = 2'b10 >> comp_result;
      
      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;

      dummy_switch_top_next = 2'b01;
      dummy_switch_bot_next = 2'b10;

      n_state = HOLD0;
    end

    HOLD0: begin
      eoc_n = 1'b1;

      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b00;
      dac_switches_bot_next_0 = 2'b00;
      dac_switches_top_next_1 = 2'b00;
      dac_switches_bot_next_1 = 2'b00;
      dac_switches_top_next_2 = 2'b00;
      dac_switches_bot_next_2 = 2'b00;
      dac_switches_top_next_3 = 2'b00;
      dac_switches_bot_next_3 = 2'b00;
      dac_switches_top_next_4 = 2'b00;
      dac_switches_bot_next_4 = 2'b00;
      dac_switches_top_next_5 = 2'b00;
      dac_switches_bot_next_5 = 2'b00;
      dac_switches_top_next_6 = 2'b00;
      dac_switches_bot_next_6 = 2'b00;
      dac_switches_top_next_7 = 2'b00;
      dac_switches_bot_next_7 = 2'b00;

      dummy_switch_top_next = 2'b00;
      dummy_switch_bot_next = 2'b00;

      load_reg = 1'b1;
      n_state = SAMPLE;
    end

    OFF_START: begin
      eoc_n = 1'b0;

      //Prepare for offset calibration: VDD_HALF switch always on, all cap
      //switches to VSS
      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dummy_switch_top_next = 2'b10;
      dummy_switch_bot_next = 2'b01;

      //Reset the current offset
      cn_next = '0;
      cp_next = '0;

      n_state = OFF_START1;
    end

    OFF_START1: begin
      eoc_n = 1'b0;

      //Prepare for offset calibration: VDD_HALF switch always on, all cap
      //switches to VSS
      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dummy_switch_top_next = 2'b10;
      dummy_switch_bot_next = 2'b01;

      //Reset the current offset
      cn_next = '0;
      cp_next = '0;

      n_state = OFF_DECISION;
    end

    OFF_DECISION: begin
      eoc_n = 1'b0;

      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dummy_switch_top_next = 2'b10;
      dummy_switch_bot_next = 2'b01;

      off_bit_next = comp_result;

      n_state = OFF_RAMP1;
    end
    
    OFF_RAMP1: begin
      eoc_n = 1'b0;

      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dummy_switch_top_next = 2'b10;
      dummy_switch_bot_next = 2'b01;

      if ((off_bit != comp_result) || (off_bit && (cn == 4'b1111)) || (~off_bit && (cp == 4'b1111))) begin
        n_state = OFF_RAMP2;
        cn_next = {off_bit, off_bit, off_bit, off_bit};
        cp_next = {~off_bit, ~off_bit, ~off_bit, ~off_bit};
        cn_store_next = cn;
        cp_store_next = cp;
      end else begin
        n_state = c_state;
        cn_next = cn + (off_bit ? 1'b1 : 1'b0);
        cp_next = cp + (off_bit ? 1'b0 : 1'b1);
      end
    end

    OFF_RAMP2: begin
      eoc_n = 1'b0;

      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b10;
      dac_switches_bot_next_0 = 2'b01;
      dac_switches_top_next_1 = 2'b10;
      dac_switches_bot_next_1 = 2'b01;
      dac_switches_top_next_2 = 2'b10;
      dac_switches_bot_next_2 = 2'b01;
      dac_switches_top_next_3 = 2'b10;
      dac_switches_bot_next_3 = 2'b01;
      dac_switches_top_next_4 = 2'b10;
      dac_switches_bot_next_4 = 2'b01;
      dac_switches_top_next_5 = 2'b10;
      dac_switches_bot_next_5 = 2'b01;
      dac_switches_top_next_6 = 2'b10;
      dac_switches_bot_next_6 = 2'b01;
      dac_switches_top_next_7 = 2'b10;
      dac_switches_bot_next_7 = 2'b01;

      dummy_switch_top_next = 2'b10;
      dummy_switch_bot_next = 2'b01;

      if ((off_bit == comp_result) || (off_bit && (cn == 4'b0000)) || (~off_bit && (cp == 4'b0000))) begin
        n_state = OFF_DONE;

        //Set the offset
        cn_next = cn_avg;
        cp_next = cp_avg;
      end else begin
        n_state = c_state;
        cn_next = cn - (off_bit ? 1'b1 : 1'b0);
        cp_next = cp - (off_bit ? 1'b0 : 1'b1);
      end
    end

    OFF_DONE: begin
      eoc_n = 1'b0;

      s_c_next = 1'b1;

      dac_switches_top_next_0 = 2'b00;
      dac_switches_bot_next_0 = 2'b00;
      dac_switches_top_next_1 = 2'b00;
      dac_switches_bot_next_1 = 2'b00;
      dac_switches_top_next_2 = 2'b00;
      dac_switches_bot_next_2 = 2'b00;
      dac_switches_top_next_3 = 2'b00;
      dac_switches_bot_next_3 = 2'b00;
      dac_switches_top_next_4 = 2'b00;
      dac_switches_bot_next_4 = 2'b00;
      dac_switches_top_next_5 = 2'b00;
      dac_switches_bot_next_5 = 2'b00;
      dac_switches_top_next_6 = 2'b00;
      dac_switches_bot_next_6 = 2'b00;
      dac_switches_top_next_7 = 2'b00;
      dac_switches_bot_next_7 = 2'b00;

      dummy_switch_top_next = 2'b00;
      dummy_switch_bot_next = 2'b00;

      n_state = SAMPLE;
    end

  endcase
end

endmodule
