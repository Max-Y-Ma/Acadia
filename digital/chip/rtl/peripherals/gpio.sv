module gpio # (
  parameter NUM_PINS = 8
) (
  input   logic clk,
  input   logic rst,

  /* Face IO cells */
  input   logic [NUM_PINS-1 : 0] io_pins_in,
  output  logic [NUM_PINS-1 : 0] io_pins_out,
  output  logic [NUM_PINS-1 : 0] io_pins_tristate,

  /* Connection to memory map */
  input  logic [31:0] mem_addr,
  input  logic [3:0]  mem_rmask,
  input  logic [3:0]  mem_wmask,
  input  logic [31:0] mem_wdata,
  output logic [31:0] mem_rdata,
  output logic        mem_resp
);

typedef enum logic [3:0] {
  INPUT_REG_OFFSET    = 4'd0 << 2,   // Input register: R only
  OUTPUT_REG_OFFSET   = 4'd1 << 2,   // Output register: R/W
  TRISTATE_REG_OFFSET = 4'd2 << 2    // Tristate register: R/W
} I2C_MEM_OFFSET;

logic [1:0] [NUM_PINS-1 : 0] io_pins_in_sync;
logic [NUM_PINS-1 : 0] input_v;

/* Double Flop synchronizer for input pins */
assign input_v = io_pins_in_sync[0];

always_ff @(posedge clk, posedge rst) begin : INPUT_SYNCHRONIZER
  if (rst) io_pins_in_sync <= '0;
  else     io_pins_in_sync <= {io_pins_in, io_pins_in_sync[1:1]};
end

/* IO Driver control signals */
always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    // Tristate GPIO on reset
    io_pins_out       <= '0;
    io_pins_tristate  <= '0;

    mem_rdata         <= 'x;
    mem_resp          <= '0;
  end else begin
    mem_rdata         <= 'x;
    mem_resp          <= |{mem_rmask, mem_wmask};

    if(|mem_rmask) begin
      unique case(mem_addr[3:0])
        INPUT_REG_OFFSET:     mem_rdata <= {{(32-NUM_PINS){1'b0}}, input_v};
        OUTPUT_REG_OFFSET:    mem_rdata <= {{(32-NUM_PINS){1'b0}}, io_pins_out};
        TRISTATE_REG_OFFSET:  mem_rdata <= {{(32-NUM_PINS){1'b0}}, io_pins_tristate};
        default:              mem_rdata <= 'x;
      endcase
    end

    if(mem_wmask[0]) begin
      unique case(mem_addr[3:0])
        OUTPUT_REG_OFFSET: begin
          io_pins_out[0 +: 8] <= mem_wdata[0 +: 8];
        end

        TRISTATE_REG_OFFSET: begin
          io_pins_tristate[0 +: 8] <= mem_wdata[0 +: 8];
        end
        default: begin end
      endcase
    end
  end
end

endmodule