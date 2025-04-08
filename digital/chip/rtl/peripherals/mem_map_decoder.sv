module mem_map_decoder 
#(
  parameter  INTERRUPT_LINES = 16,
  parameter  INTERRUPT_BITS  = $clog2(INTERRUPT_LINES) 
)(
  input  logic        clk,
  input  logic        rst,
  
  /* UFP to CPU */
  input  logic [31:0] dmem_addr,
  input  logic [3:0]  dmem_rmask,
  input  logic [3:0]  dmem_wmask,
  output logic [31:0] dmem_rdata,
  input  logic [31:0] dmem_wdata,
  output logic        dmem_resp,

  /* DFP to Data SRAM */
  output logic [31:0] data_memory0_addr,
  output logic [3:0]  data_memory0_rmask,
  output logic [3:0]  data_memory0_wmask,
  input  logic [31:0] data_memory0_rdata,
  output logic [31:0] data_memory0_wdata,
  input  logic        data_memory0_resp,

  /* DFP to GPIO drivers */
  output logic [31:0] gpio_a_addr,
  output logic [3:0]  gpio_a_rmask,
  output logic [3:0]  gpio_a_wmask,
  input  logic [31:0] gpio_a_rdata,
  output logic [31:0] gpio_a_wdata,
  input  logic        gpio_a_resp,

  /* DFP to UART1 */
  output logic [31:0] uart1_addr,
  output logic [3:0]  uart1_rmask,
  output logic [3:0]  uart1_wmask,
  input  logic [31:0] uart1_rdata,
  output logic [31:0] uart1_wdata,
  input  logic        uart1_resp,

  /* DFP to UART2 */
  output logic [31:0] uart2_addr,
  output logic [3:0]  uart2_rmask,
  output logic [3:0]  uart2_wmask,
  input  logic [31:0] uart2_rdata,
  output logic [31:0] uart2_wdata,
  input  logic        uart2_resp,

  /* DFP to I2C1 */
  output logic [31:0] i2c1_addr,
  output logic [3:0]  i2c1_rmask,
  output logic [3:0]  i2c1_wmask,
  input  logic [31:0] i2c1_rdata,
  output logic [31:0] i2c1_wdata,
  input  logic        i2c1_resp,

  /* DFP to I2C2 */
  output logic [31:0] i2c2_addr,
  output logic [3:0]  i2c2_rmask,
  output logic [3:0]  i2c2_wmask,
  input  logic [31:0] i2c2_rdata,
  output logic [31:0] i2c2_wdata,
  input  logic        i2c2_resp,

  /* DFP to SPI1 */
  output logic [31:0] spi1_addr,
  output logic [3:0]  spi1_rmask,
  output logic [3:0]  spi1_wmask,
  input  logic [31:0] spi1_rdata,
  output logic [31:0] spi1_wdata,
  input  logic        spi1_resp,

  /* DFP to clock prescalers */
  output logic [3:0]  prescaler_rmask,
  output logic [3:0]  prescaler_wmask,
  input  logic [31:0] prescaler_rdata,

  /* DFP to analog registers */
  output logic [31:0] analog_addr,
  output logic [3:0]  analog_rmask,
  output logic [3:0]  analog_wmask,
  input  logic [31:0] analog_rdata,
  output logic [31:0] analog_wdata,

  /* DFP to Interrupt Controller drivers */
  input  logic [INTERRUPT_LINES-1:0] intr_mask_val,
  output logic                       read_int_mask,
  output logic                       update_int_mask,

  // Vector Table driver signals
  input  logic [31:0]               int_vec_table_pc,
  output logic                      read_vec_table,
  output logic [INTERRUPT_BITS-1:0] int_table_entry_id,
  output logic                      update_int_vec_table,

  /*DFP to RSA Signals*/
  input  logic [15:0] RSA_output_msg,
  input  logic        RSA_idle_flag,
  output logic        start_RSA,
  output logic        update_key,
  output logic        update_mod_n,
  output logic        update_msg_blk,

  /* ADP Debug Signals */
  output logic [31:0] adp_dmem_rdata,
  input  logic [31:0] adp_dmem_addr,
  input  logic [3:0]  adp_dmem_rmask,
  input  logic [3:0]  adp_dmem_wmask,
  input  logic [31:0] adp_dmem_wdata,
  input  logic        adp_debug_mode
);

int unsigned i;
// Memory Map Address Space
localparam MMAP_ALIGNED_WIDTH = 13; // 8KB Aligned
localparam MMAP_BASE_WIDTH    = 32 - MMAP_ALIGNED_WIDTH;

//count for how many bits away from 32 we have for interrupts
localparam INVERSE_INT_COUNT    = (32 - INTERRUPT_LINES);

localparam MMAP_START_BASE_ADDR = 19'h3_8000;

localparam DATA_SRAM_BASE_ADDR  = 19'h3_8000;
localparam GPIO_BASE_ADDR       = 19'h3_8001;
localparam PRESCALER_BASE_ADDR  = 19'h3_8002;
localparam INT_BASE_ADDR        = 19'h3_8003;
localparam RSA_BASE_ADDR        = 19'h3_8004;
localparam UART1_BASE_ADDR      = 19'h3_8005;
localparam UART2_BASE_ADDR      = 19'h3_8006;
localparam I2C1_BASE_ADDR       = 19'h3_8007;
localparam I2C2_BASE_ADDR       = 19'h3_8008;
localparam SPI1_BASE_ADDR       = 19'h3_8009;
localparam ANALOG_BASE_ADDR     = 19'h3_800A;

localparam MMAP_END_BASE_ADDR   = 19'h7_8000;

localparam INT_VEC_OFFSET_ADDR  = 13'h0004;

// Aligned address from CPU
logic [MMAP_BASE_WIDTH-1:0] mmap_addr;
assign mmap_addr = dmem_addr[31:MMAP_ALIGNED_WIDTH];

logic [MMAP_BASE_WIDTH-1:0] adp_mmap_addr;
assign adp_mmap_addr = adp_dmem_addr[31:MMAP_ALIGNED_WIDTH];

logic [MMAP_ALIGNED_WIDTH-1:0] mmap_offset;
logic [MMAP_ALIGNED_WIDTH-1:0] mmap_offset_active, mmap_offset_saved;
assign mmap_offset = dmem_addr[MMAP_ALIGNED_WIDTH-1:0];

logic [MMAP_BASE_WIDTH-1:0] mmap_addr_active, mmap_addr_saved;
logic [MMAP_BASE_WIDTH-1:0] adp_mmap_addr_active, adp_mmap_addr_saved;
logic request_busy;
logic adp_request_busy;

logic [3:0] dmem_rmask_active, dmem_rmask_saved;
logic [3:0] dmem_wmask_active, dmem_wmask_saved;

always_comb begin
  mmap_addr_active     = request_busy     ? mmap_addr_saved     : mmap_addr;
  mmap_offset_active   = request_busy     ? mmap_offset_saved   : mmap_offset;
  adp_mmap_addr_active = adp_request_busy ? adp_mmap_addr_saved : adp_mmap_addr;
  dmem_rmask_active    = request_busy     ? dmem_rmask_saved    : dmem_rmask;
  dmem_wmask_active    = request_busy     ? dmem_wmask_saved    : dmem_wmask;
end

always_ff @(posedge clk, posedge rst) begin
  if(rst) begin
    request_busy        <= '0;
    adp_request_busy    <= '0;
    mmap_addr_saved     <= 'x;
    adp_mmap_addr_saved <= 'x;
    dmem_rmask_saved    <= 'x;
    dmem_wmask_saved    <= 'x;
    mmap_offset_saved   <= 'x;
  end
  else begin
    if(~request_busy && |{dmem_rmask, dmem_wmask}) begin
      request_busy      <= 1'b1;
      mmap_addr_saved   <= mmap_addr;
      dmem_rmask_saved  <= dmem_rmask;
      dmem_wmask_saved  <= dmem_wmask;
      mmap_offset_saved <= mmap_offset;
    end
    else if(request_busy && dmem_resp) begin
      request_busy      <= 1'b0;
      mmap_addr_saved   <= 'x;
      dmem_rmask_saved  <= 'x;
      dmem_wmask_saved  <= 'x;
      mmap_offset_saved <= 'x;
    end

    if(~adp_request_busy && |{adp_dmem_rmask, adp_dmem_wmask}) begin
      adp_request_busy    <= 1'b1;
      adp_mmap_addr_saved <= adp_mmap_addr;
    end
    else if (adp_request_busy) begin
      adp_request_busy    <= 1'b0;
      adp_mmap_addr_saved <= 'x;
    end
  end
end

// For one cycle memory requests  
logic delayed_request;
always_ff @(posedge clk, posedge rst) begin
  if(rst) delayed_request <= '0;
  else    delayed_request <= |(dmem_rmask | dmem_wmask);
end

// Address decoder with output logic
always_comb begin
  // Default signals
  data_memory0_addr   = dmem_addr;
  data_memory0_wdata  = dmem_wdata;
  data_memory0_rmask  = '0;
  data_memory0_wmask  = '0;

  gpio_a_addr         = dmem_addr;
  gpio_a_wdata        = dmem_wdata;
  gpio_a_rmask        = '0;
  gpio_a_wmask        = '0;

  uart1_addr          = dmem_addr;
  uart1_wdata         = dmem_wdata;
  uart1_rmask         = '0;
  uart1_wmask         = '0;

  uart2_addr          = dmem_addr;
  uart2_wdata         = dmem_wdata;
  uart2_rmask         = '0;
  uart2_wmask         = '0;

  i2c1_addr           = dmem_addr;
  i2c1_wdata          = dmem_wdata;
  i2c1_rmask          = '0;
  i2c1_wmask          = '0;

  i2c2_addr           = dmem_addr;
  i2c2_wdata          = dmem_wdata;
  i2c2_rmask          = '0;
  i2c2_wmask          = '0;

  spi1_addr           = dmem_addr;
  spi1_wdata          = dmem_wdata;
  spi1_rmask          = '0;
  spi1_wmask          = '0;

  prescaler_rmask     = '0;
  prescaler_wmask     = '0;

  analog_addr         = dmem_addr;
  analog_wdata        = dmem_wdata;
  analog_rmask        = '0;
  analog_wmask        = '0;

  dmem_rdata          = '0;
  dmem_resp           = '0;

  adp_dmem_rdata      = '0;

  read_int_mask        = '0;
  read_vec_table       = '0;
  update_int_mask      = '0;
  update_int_vec_table = '0;
  int_table_entry_id   = 'x;

  // update_key           = '0;
  // update_mod_n         = '0;
  // update_msg_blk       = '0;

  // extracted_RSA_msg    = 'x;

  update_key           = '0;
  update_mod_n         = '0;
  update_msg_blk       = '0;
  start_RSA            = '0;

  //////////////////////////////////////////////////////////////////////////////
  // Data SRAM / Memory
  //////////////////////////////////////////////////////////////////////////////

  // Support ADP Debug SRAM writes and reads
  if (adp_debug_mode) begin
    if (adp_mmap_addr_active == DATA_SRAM_BASE_ADDR) begin
      data_memory0_addr  = adp_dmem_addr;
      data_memory0_rmask = adp_dmem_rmask;
      data_memory0_wmask = adp_dmem_wmask;
      data_memory0_wdata = adp_dmem_wdata;

      adp_dmem_rdata = data_memory0_rdata;
    end
  end
  else begin
    if(mmap_addr_active == DATA_SRAM_BASE_ADDR) begin
      data_memory0_rmask = dmem_rmask;
      data_memory0_wmask = dmem_wmask;

      dmem_rdata = data_memory0_rdata;
      dmem_resp  = data_memory0_resp;
    end
    ////////////////////////////////////////////////////////////////////////////
    // GPIO
    ////////////////////////////////////////////////////////////////////////////
    else if(mmap_addr_active == GPIO_BASE_ADDR) begin
      gpio_a_rmask = dmem_rmask;
      gpio_a_wmask = dmem_wmask;

      dmem_rdata = gpio_a_rdata;
      dmem_resp  = gpio_a_resp;
    end
    ////////////////////////////////////////////////////////////////////////////
    // RSA
    ////////////////////////////////////////////////////////////////////////////
    else if(mmap_addr_active == RSA_BASE_ADDR) begin
      dmem_resp = delayed_request;

      // if accesing interrupt mask
      if(|dmem_wmask) begin
        case(dmem_addr[3:0])
          4'd0: update_key     = 1'b1;
          4'd4: update_mod_n   = 1'b1;
          4'd8: update_msg_blk = 1'b1;
          4'd12: start_RSA     = 1'b1;
        endcase
      end 
      
      if(|dmem_rmask_active) begin
        case(dmem_addr[2:0])
          3'd0: dmem_rdata = {16'b0, RSA_output_msg};
          3'd4: dmem_rdata = RSA_idle_flag;
        endcase
      end
    end
    ////////////////////////////////////////////////////////////////////////////
    // Interupts
    ////////////////////////////////////////////////////////////////////////////
    else if(mmap_addr_active == INT_BASE_ADDR) begin
      dmem_resp = delayed_request;

      //if accesing interrupt mask
      if(mmap_offset_active  == 13'h0000) begin 

        //if reading from interrupt mask
        if(|dmem_rmask_active) begin
          read_int_mask = 1'b1;
          dmem_rdata = {16'd0, intr_mask_val}; //had to hardcode 16 bc params don't work here, need to change manually
        end 
        
        //if writing to the intterupt mask
        else if(|dmem_wmask) begin
          update_int_mask = 1'b1;
        end

      end else begin
      
          //ensure that we are a multiple of 4
        if(mmap_offset_active[1:0] == '0) begin
          
          //if servicing a read request, send index to controller and recieve pc
          if(|dmem_rmask_active) begin
            read_vec_table     = 1'b1;
            int_table_entry_id = ((mmap_offset_active >> 2) - 1'b1);
            dmem_rdata         = int_vec_table_pc;
          end 
          
          //if writing to the intterupt mask
          else if(|dmem_wmask) begin
              int_table_entry_id   = ((mmap_offset_active >> 2) - 1'b1);
              update_int_vec_table = 1'b1;
          end
        end
      end

    end
    ////////////////////////////////////////////////////////////////////////////
    // Clock prescalers
    ////////////////////////////////////////////////////////////////////////////
    else if (mmap_addr_active == PRESCALER_BASE_ADDR) begin
      prescaler_rmask = dmem_rmask;
      prescaler_wmask = dmem_wmask;

      dmem_rdata = prescaler_rdata;
      dmem_resp  = delayed_request;
    end
    ////////////////////////////////////////////////////////////////////////////
    // UARTs
    ////////////////////////////////////////////////////////////////////////////
    else if (mmap_addr_active == UART1_BASE_ADDR) begin
      uart1_rmask = dmem_rmask;
      uart1_wmask = dmem_wmask;

      dmem_rdata = uart1_rdata;
      dmem_resp  = uart1_resp;
    end
    else if (mmap_addr_active == UART2_BASE_ADDR) begin
      uart2_rmask = dmem_rmask;
      uart2_wmask = dmem_wmask;

      dmem_rdata = uart2_rdata;
      dmem_resp  = uart2_resp;
    end
    ////////////////////////////////////////////////////////////////////////////
    // I2C Controllers
    ////////////////////////////////////////////////////////////////////////////
    else if (mmap_addr_active == I2C1_BASE_ADDR) begin
      i2c1_rmask = dmem_rmask;
      i2c1_wmask = dmem_wmask;

      dmem_rdata = i2c1_rdata;
      dmem_resp  = i2c1_resp;
    end
    else if (mmap_addr_active == I2C2_BASE_ADDR) begin
      i2c2_rmask = dmem_rmask;
      i2c2_wmask = dmem_wmask;

      dmem_rdata = i2c2_rdata;
      dmem_resp  = i2c2_resp;
    end
    ////////////////////////////////////////////////////////////////////////////
    // SPI Controller
    ////////////////////////////////////////////////////////////////////////////
    else if (mmap_addr_active == SPI1_BASE_ADDR) begin
      spi1_rmask = dmem_rmask;
      spi1_wmask = dmem_wmask;

      dmem_rdata = spi1_rdata;
      dmem_resp  = spi1_resp;
    end
    ////////////////////////////////////////////////////////////////////////////
    // ADC / DAC Register
    ////////////////////////////////////////////////////////////////////////////
    else if (mmap_addr_active == ANALOG_BASE_ADDR) begin
      analog_rmask = dmem_rmask;
      analog_wmask = dmem_wmask;

      dmem_rdata = analog_rdata;
      dmem_resp  = delayed_request;
    end
    ////////////////////////////////////////////////////////////////////////////
    // Avoid data bus hanging
    ////////////////////////////////////////////////////////////////////////////
    else begin
      // Trigger response, even if address cannot be decoded and is invalid
      dmem_resp = delayed_request;
    end
  end
end

endmodule

