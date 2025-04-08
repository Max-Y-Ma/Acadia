module qspi_controller # (
  parameter DATA_NIBBLES = 16
) (
  input   logic           s_pclk,
  input   logic           s_presetn,
  input   logic   [31:0]  s_paddr,
  input   logic           s_psel,
//  input   logic           s_penable,
  input   logic           s_pwrite,
//  input   logic   [31:0]      s_pwdata,
//  input   logic   [3:0]       s_pstrb,
  output  logic           s_pready,
  output  logic   [DATA_NIBBLES * 4 - 1 : 0]      s_prdata,

  input   logic   [3:0]   qspi_io_i,
  output  logic   [3:0]   qspi_io_o,
  output  logic           qspi_io_t,
  output  logic           qspi_ck_o,
  output  logic           qspi_cs_o
);

  enum logic [2:0] {
    QSPI_CTRL_IDLE,
    QSPI_TRI_WAIT,
    QSPI_CTRL_CMD,
    QSPI_CTRL_ADDR,
    QSPI_CTRL_DUMMY,
    QSPI_CTRL_DATA,
    QSPI_CTRL_ACK
  } state, state_next;

      logic [$clog2(DATA_NIBBLES) - 1 : 0]  nibble_counter_d, nibble_counter_q;
      logic                 nibble_counter_d_mux_sel;
      logic [1:0]               io_o_mux_sel;

      logic [23:0]  addr_buffered;
      logic [23:0]  addr_buffered_next;

  always_ff @( posedge s_pclk, negedge s_presetn ) begin : state_ff
    if (~s_presetn) begin
      state <= QSPI_CTRL_IDLE;
      addr_buffered <= '0;
    end else begin
      state <= state_next;
      addr_buffered <= addr_buffered_next;
    end
  end

  always_comb begin : state_comb
    unique case(state)
    QSPI_CTRL_IDLE : begin
      nibble_counter_d_mux_sel = 1'b0;
      io_o_mux_sel = 2'b00;
      qspi_io_t = 1'b0;
      qspi_cs_o = 1'b1;
      s_pready = 1'b0;
      addr_buffered_next = addr_buffered;
      if (~s_psel) begin
        state_next = QSPI_CTRL_IDLE;
      end else begin
        if (~s_pwrite) begin
          state_next = QSPI_TRI_WAIT;
        end else begin
          state_next = QSPI_CTRL_ACK;
        end
      end
    end
    QSPI_TRI_WAIT : begin
      state_next = QSPI_CTRL_CMD;
      nibble_counter_d_mux_sel = 1'b0;
      io_o_mux_sel = 2'b00;
      qspi_io_t = 1'b1;
      qspi_cs_o = 1'b0;
      s_pready = 1'b0;
      addr_buffered_next = s_paddr[23:0];
    end
    QSPI_CTRL_CMD : begin
      if (nibble_counter_q[2:0] != 3'd7) begin
        state_next = QSPI_CTRL_CMD;
        nibble_counter_d_mux_sel = 1'b1;
        io_o_mux_sel = 2'b10;
        qspi_io_t = 1'b1;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end else begin
        state_next = QSPI_CTRL_ADDR;
        nibble_counter_d_mux_sel = 1'b0;
        io_o_mux_sel = 2'b10;
        qspi_io_t = 1'b1;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end
    end
    QSPI_CTRL_ADDR : begin
      if (nibble_counter_q[2:0] != 3'd7) begin
        state_next = QSPI_CTRL_ADDR;
        nibble_counter_d_mux_sel = 1'b1;
        io_o_mux_sel = 2'b11;
        qspi_io_t = 1'b1;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end else begin
        state_next = QSPI_CTRL_DUMMY;
        nibble_counter_d_mux_sel = 1'b0;
        io_o_mux_sel = 2'b11;
        qspi_io_t = 1'b1;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end
    end
    QSPI_CTRL_DUMMY : begin
      if (nibble_counter_q[2:0] != 3'd3) begin
        state_next = QSPI_CTRL_DUMMY;
        nibble_counter_d_mux_sel = 1'b1;
        io_o_mux_sel = 2'b00;
        qspi_io_t = 1'b0;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end else begin
        state_next = QSPI_CTRL_DATA;
        nibble_counter_d_mux_sel = 1'b0;
        io_o_mux_sel = 2'b00;
        qspi_io_t = 1'b0;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end
    end
    QSPI_CTRL_DATA : begin
      if (nibble_counter_q != (DATA_NIBBLES - $clog2(DATA_NIBBLES)'(unsigned'(1)) )) begin
        state_next = QSPI_CTRL_DATA;
        nibble_counter_d_mux_sel = 1'b1;
        io_o_mux_sel = 2'b00;
        qspi_io_t = 1'b0;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end else begin
        state_next = QSPI_CTRL_ACK;
        nibble_counter_d_mux_sel = 1'b0;
        io_o_mux_sel = 2'b00;
        qspi_io_t = 1'b0;
        qspi_cs_o = 1'b0;
        s_pready = 1'b0;
        addr_buffered_next = addr_buffered;
      end
    end
    QSPI_CTRL_ACK : begin
      state_next = QSPI_CTRL_IDLE;
      nibble_counter_d_mux_sel = 1'b0;
      io_o_mux_sel = 2'b00;
      qspi_io_t = 1'b0;
      qspi_cs_o = 1'b1;
      s_pready = 1'b1;
      addr_buffered_next = addr_buffered;
    end
    default: begin
      state_next = QSPI_CTRL_IDLE;
      nibble_counter_d_mux_sel = 1'b0;
      io_o_mux_sel = 2'b00;
      qspi_io_t = 1'b0;
      qspi_cs_o = 1'b1;
      s_pready = 1'b0;
      addr_buffered_next = addr_buffered;
    end
    endcase
  end

  always_comb begin : qspi_clk_comb
    qspi_ck_o = (state != QSPI_CTRL_IDLE) && (state != QSPI_TRI_WAIT) ? ~s_pclk : 1'b0;
  end

  always_comb begin : nibble_mux
    unique case (nibble_counter_d_mux_sel)
      1'b0 : nibble_counter_d = '0;
      1'b1 : nibble_counter_d = nibble_counter_q + $clog2(DATA_NIBBLES)'(1);
    endcase
  end

  always_comb begin : io_o_mux
      automatic logic [3:0]   addr_mux_out;
      automatic logic     cmd_mux_out;
    unique case (nibble_counter_q[2:0])
      3'b000: addr_mux_out = addr_buffered[23:20];
      3'b001: addr_mux_out = addr_buffered[19:16];
      3'b010: addr_mux_out = addr_buffered[15:12]; 
      3'b011: addr_mux_out = addr_buffered[11:8];
      3'b100: addr_mux_out = addr_buffered[7:4];
      3'b101: addr_mux_out = addr_buffered[3:0];
      3'b110: addr_mux_out = 4'hf;
      3'b111: addr_mux_out = 4'hf;
      default: addr_mux_out = 'x; // For xprop
    endcase
    unique case (nibble_counter_q[2:0])
      3'b000: cmd_mux_out = 1'b1;
      3'b001: cmd_mux_out = 1'b1;
      3'b010: cmd_mux_out = 1'b1; 
      3'b011: cmd_mux_out = 1'b0;
      3'b100: cmd_mux_out = 1'b1;
      3'b101: cmd_mux_out = 1'b0;
      3'b110: cmd_mux_out = 1'b1;
      3'b111: cmd_mux_out = 1'b1;
      default: cmd_mux_out = 'x;
    endcase
    unique case (io_o_mux_sel)
      2'b00, 2'b01: qspi_io_o = 4'b0000;
      2'b10:    qspi_io_o = {3'b000, cmd_mux_out};
      2'b11:    qspi_io_o = addr_mux_out;
      default:  qspi_io_o = 'x;
    endcase
  end
  
      logic  [(4*DATA_NIBBLES-1) : 0]  rdata_d, rdata_q, rdata_l;

  always_comb begin : rdata_reg_comb
    rdata_l = 'd0;
    for (int unsigned i = 0; i < DATA_NIBBLES; i++) begin
      if (
      {nibble_counter_q[$clog2(DATA_NIBBLES) - 1:1],
      ~nibble_counter_q[0]} == i[$clog2(DATA_NIBBLES) - 1:0] && 
      state == QSPI_CTRL_DATA) begin
        rdata_l[i*4+:4] = 4'hf;
      end
      rdata_d[i*4+:4] = qspi_io_i;
    end
    s_prdata = rdata_q;
  end  

  always_ff @( posedge s_pclk, negedge s_presetn ) begin : reg_stub
    if (~s_presetn) begin
      nibble_counter_q <= '0;
      rdata_q <= '0;
    end else begin
      nibble_counter_q <= nibble_counter_d;
      for (int unsigned i = 0; i < unsigned'(4)*DATA_NIBBLES; i++) begin
        if (rdata_l[i]) begin
          rdata_q[i] <= rdata_d[i];
        end
      end
    end
  end

endmodule

