module spi_transmitter # (
  parameter MOSI_BUFFER_DEPTH = 16
) (
  input   logic clk,
  input   logic rst,

  input   logic clk_en,

  input   logic       wen,
  input   logic [7:0] w_data,

  output  logic [4:0] rptr,
  output  logic [4:0] wptr,

  /**/
  output  logic SCLK,
  output  logic MOSI
);

  logic mosi_buf_full;
  logic mosi_buf_empty;

  logic [7:0] mosi_out_byte;
  logic       mosi_buf_ren;

  logic [2:0] bit_counter;

  always_comb begin
    MOSI = mosi_out_byte[bit_counter];

    mosi_buf_ren = SCLK && (bit_counter == 3'b0) && clk_en;
  end

  always_ff @(posedge clk, posedge rst) begin
    if(rst) begin
      SCLK        <= '0;
      bit_counter <= 3'b111;
    end else if(clk_en) begin
      if(~mosi_buf_empty) begin
        SCLK <= ~SCLK;
        if(SCLK) begin
          bit_counter <= bit_counter - 3'b1;
        end
      end
    end
  end

  fifo # (
    .WIDTH(1),
    .DEPTH(MOSI_BUFFER_DEPTH),
    .DTYPE(logic[7:0])
  ) mosi_buf (
    .clk(clk),
    .rst(rst),

    .wen(wen && ~mosi_buf_full),
    .wdata(w_data),
    .ren(mosi_buf_ren),
    .rdata(mosi_out_byte),

    .wptr(wptr),
    .rptr(rptr),

    .full(mosi_buf_full),
    .empty(mosi_buf_empty)
  );

endmodule