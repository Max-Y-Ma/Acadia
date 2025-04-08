/* uart_peripheral.sv
 * 
 * Binh-Minh Nguyen (bmn4) 10/7/2024
 *
 * Wrapper FSM+logic around opencores UART controller to conenct to memory bus
 *
 * Memory map:
 *
 *
 */

module uart_peripheral #(
  parameter RX_BUFFER_DEPTH = 64, /* MUST be power of 2*/
  parameter TX_BUFFER_DEPTH = 64, /* MUST be power of 2*/

  // parameter D_BAUD_FREQ     = 12'h90, // TODO adjust this to be good for 115200
  // parameter D_BAUD_LIMIT    = 16'h0ba5

  parameter D_BAUD_FREQ     = 12'd48, // Clkdiv for 125 MHz -> 16*115200 baud
  parameter D_BAUD_LIMIT    = 16'd3077
) (
  input   clk,
  input   rst,

  output  logic int_req,

  /* Top-level pins */
  input   logic rx,
  output  logic tx,

  /* Connection to memory map */
  input  logic [31:0] mem_addr,
  input  logic [3:0]  mem_rmask,
  input  logic [3:0]  mem_wmask,
  output logic [31:0] mem_rdata,
  input  logic [31:0] mem_wdata,
  output logic        mem_resp
);

typedef enum logic [3:0] {
  RX_MEM_OFFSET         = 4'd0 << 2,
  TX_MEM_OFFSET         = 4'd1 << 2,
  BAUD_FREQ_MEM_OFFSET  = 4'd2 << 2,
  BAUD_LIMIT_MEM_OFFSET = 4'd3 << 2
} UART_MEM_OFFSET;

logic [7:0] rx_data;
logic [7:0] tx_data;
logic       new_rx_data;
logic       new_tx_data;
logic       tx_busy;

logic rx_buf_wen;
logic rx_buf_ren;
logic rx_buf_full;
logic rx_buf_empty;

logic [7:0] rx_buf_rdata;

logic tx_buf_wen;
logic tx_buf_ren;
logic tx_buf_full;
logic tx_buf_empty;

logic [7:0]   tx_buf_wdata;

logic	[11:0]	baud_freq_reg, baud_freq_next;
logic	[15:0]	baud_limit_reg, baud_limit_next;

logic tx_stall, tx_stall_next;

logic [7:0] tx_byte_saved, tx_byte_saved_next;

logic [31:0]  mem_rdata_next;
logic mem_resp_next;

assign int_req = new_rx_data;

/* Buffer <-> UART module control logic */
always_comb begin
  // Drop packets if rx_buf full
  rx_buf_wen = new_rx_data && ~rx_buf_full;

  new_tx_data = ~tx_buf_empty && ~tx_busy;
  tx_buf_ren  = new_tx_data;
end

/* Connection to memory interface */
always_comb begin
  mem_rdata_next  = 'x; // TODO: should it be set to some set val in case in invalid read?
  mem_resp_next   = '0;

  rx_buf_ren = '0;

  baud_freq_next  = baud_freq_reg;
  baud_limit_next = baud_limit_reg;

  tx_buf_wen          = '0;
  tx_buf_wdata        = 'x;

  tx_byte_saved_next  = tx_byte_saved;
  tx_stall_next       = tx_stall;

  if(tx_stall) begin
    if(~tx_buf_full) begin
      tx_stall_next = '0;

      tx_buf_wen    = 1'b1;
      tx_buf_wdata  = tx_byte_saved;
      tx_byte_saved_next = 'x;

      mem_resp_next = 1'b1;
    end
  end else begin
    unique case (mem_addr[$bits(UART_MEM_OFFSET) - 1 : 0])
      RX_MEM_OFFSET: begin
        // If read from rx buffer
        if(|mem_rmask) begin
          mem_rdata_next  = {{24{rx_buf_empty}}, rx_buf_rdata};
          rx_buf_ren      = ~rx_buf_empty;  // Underflow protection
          mem_resp_next   = 1'b1;
        end
      end

      TX_MEM_OFFSET: begin
        if(mem_wmask[0]) begin
          if(~tx_buf_full) begin
            tx_buf_wen    = 1'b1;
            tx_buf_wdata  = mem_wdata[7:0];
            mem_resp_next = 1'b1;
          end else begin
            tx_stall_next       = 1'b1;
            tx_byte_saved_next  = mem_wdata[7:0];;
          end
        end
      end

      BAUD_FREQ_MEM_OFFSET: begin
        if(mem_wmask[0]) begin
          baud_freq_next[7:0] = mem_wdata[7:0];
          mem_resp_next = 1'b1;
        end

        if(mem_wmask[1]) begin
          baud_freq_next[11:8] = mem_wdata[11:8];
          mem_resp_next = 1'b1;
        end

        if(|mem_rmask) begin
          mem_rdata_next = {24'b0, baud_freq_reg};
          mem_resp_next = 1'b1;
        end
      end

      BAUD_LIMIT_MEM_OFFSET: begin
        if(mem_wmask[0]) begin
          baud_limit_next[7:0] = mem_wdata[7:0];
          mem_resp_next = 1'b1;
        end

        if(mem_wmask[1]) begin
          baud_limit_next[15:8] = mem_wdata[15:8];
          mem_resp_next = 1'b1;
        end

        if(|mem_rmask) begin
          mem_rdata_next = {16'b0, baud_limit_reg};
          mem_resp_next = 1'b1;
        end
      end

      default begin end // Catch 'x in sim
    endcase
  end
end

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    mem_resp  <= '0;
    mem_rdata <= 'x;

    tx_stall      <= '0;
    tx_byte_saved <= 'x;
    
    // TODO: Change to useful default value
    baud_freq_reg <= D_BAUD_FREQ;
    baud_limit_reg <= D_BAUD_LIMIT;
  end else begin
    mem_resp  <= mem_resp_next;
    mem_rdata <= mem_rdata_next;

    tx_stall      <= tx_stall_next;
    tx_byte_saved <= tx_byte_saved_next;

    baud_freq_reg <= baud_freq_next;
    baud_limit_reg <= baud_limit_next;
  end
end


/* TX/RX Buffers */
fifo # (
  .WIDTH(1),
  .DEPTH(RX_BUFFER_DEPTH),
  .DTYPE(logic[7:0])
) rx_buffer (
  .clk(clk),
  .rst(rst),
  .wen(rx_buf_wen),
  .wdata(rx_data),
  .ren(rx_buf_ren),
  .rdata(rx_buf_rdata),
  .full(rx_buf_full),
  .empty(rx_buf_empty)
);

fifo # (
  .WIDTH(1),
  .DEPTH(TX_BUFFER_DEPTH),
  .DTYPE(logic[7:0])
) tx_buffer (
  .clk(clk),
  .rst(rst),
  .wen(tx_buf_wen),
  .wdata(tx_buf_wdata),
  .ren(tx_buf_ren),
  .rdata(tx_data),
  .full(tx_buf_full),
  .empty(tx_buf_empty)
);

/* UART module from OpenCores */
uart_top uart_top0 (
	// global signals 
	.clock(clk),
	.reset(rst),
	// uart serial signals 
	.ser_in(rx),
	.ser_out(tx),
	// transmit and receive internal interface signals 
	.rx_data(rx_data),
	.new_rx_data(new_rx_data), 
	.tx_data(tx_data),
	.new_tx_data(new_tx_data),
	.tx_busy(tx_busy), 
	// baud rate configuration register - see baud_gen.v for details 
	.baud_freq(baud_freq_reg),
	.baud_limit(baud_limit_reg), 
	.baud_clk() // Unconnected baud clk, not used for external stuff 
);

`ifdef ACADIA_ASSERTIONS
initial begin : VALIDATE_PARAMETERS
  assert ($countones(RX_BUFFER_DEPTH) == 1) else begin
    $error("[ERROR] %m: parameter RX_BUFFER_DEPTH is not a power of 2, %d",
      RX_BUFFER_DEPTH);
  end

  assert ($countones(TX_BUFFER_DEPTH) == 1) else begin
    $error("[ERROR] %m: parameter TX_BUFFER_DEPTH is not a power of 2, %d",
      TX_BUFFER_DEPTH);
  end
end


// Assert mem_rmask and mem_wmask not at same time
always @ (posedge clk) begin
  assert(~(|mem_rmask & |mem_wmask)) else begin
    $error("[ERROR] %m: mem_rmask and mem_wmask asserted at same time");
  end
end

// TODO assert mem_addr is on legal offsets

// Assert fifos don't get under or overflowed
always @ (posedge clk) begin
  assert(~(rx_buf_ren & rx_buf_empty)) else begin
    $error("[ERROR] %m: rx_buf underflow");
  end

  assert(~(rx_buf_wen & rx_buf_full)) else begin
    $error("[ERROR] %m: rx_buf overflow");
  end
end

// TODO Assert no request comes in until resp

always @ (posedge clk) begin
    assert(~$isunknown(mem_addr[$bits(UART_MEM_OFFSET) - 1 : 0])
                        || (mem_rmask == '0 && mem_wmask == '0)) else begin
      
      $error("[ERROR] %m: mem_addr bits contains x (%x) when masks are non-zero (rmask: %b, wmask: %b)", mem_addr[$bits(UART_MEM_OFFSET) - 1 : 0], mem_rmask, mem_wmask);
    end
end
`endif 

endmodule