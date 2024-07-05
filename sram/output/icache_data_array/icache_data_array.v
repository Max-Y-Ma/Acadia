// OpenRAM SRAM model
// Words: 64
// Word size: 128
// Write size: 8

module icache_data_array(
`ifdef USE_POWER_PINS
    vdd,
    gnd,
`endif
// Port 0: RW
    clk0,csb0,web0,wmask0,addr0,din0,dout0
  );

  parameter NUM_WMASKS = 16 ;
  parameter DATA_WIDTH = 128 ;
  parameter ADDR_WIDTH = 6 ;
  parameter RAM_DEPTH = 1 << ADDR_WIDTH;

`ifdef USE_POWER_PINS
    inout vdd;
    inout gnd;
`endif
  input  clk0; // clock
  input   csb0; // active low chip select
  input  web0; // active low write control
  input [ADDR_WIDTH-1:0]  addr0;
  input [NUM_WMASKS-1:0]   wmask0; // write mask
  input [DATA_WIDTH-1:0]  din0;
  output [DATA_WIDTH-1:0] dout0;

  reg [DATA_WIDTH-1:0]    mem [0:RAM_DEPTH-1];

  reg  web0_reg;
  reg [NUM_WMASKS-1:0]   wmask0_reg;
  reg [ADDR_WIDTH-1:0]  addr0_reg;
  reg [DATA_WIDTH-1:0]  din0_reg;
  reg [DATA_WIDTH-1:0]  dout0;

  always @(posedge clk0)
  begin
    if( !csb0 ) begin
      web0_reg <= web0;
      wmask0_reg <= wmask0;
      addr0_reg <= addr0;
      din0_reg <= din0;
    end
  end


  always @ (posedge clk0)
  begin : MEM_WRITE0
    if ( !web0_reg ) begin
        if (wmask0_reg[0])
                mem[addr0_reg][7:0] <= din0_reg[7:0];
        if (wmask0_reg[1])
                mem[addr0_reg][15:8] <= din0_reg[15:8];
        if (wmask0_reg[2])
                mem[addr0_reg][23:16] <= din0_reg[23:16];
        if (wmask0_reg[3])
                mem[addr0_reg][31:24] <= din0_reg[31:24];
        if (wmask0_reg[4])
                mem[addr0_reg][39:32] <= din0_reg[39:32];
        if (wmask0_reg[5])
                mem[addr0_reg][47:40] <= din0_reg[47:40];
        if (wmask0_reg[6])
                mem[addr0_reg][55:48] <= din0_reg[55:48];
        if (wmask0_reg[7])
                mem[addr0_reg][63:56] <= din0_reg[63:56];
        if (wmask0_reg[8])
                mem[addr0_reg][71:64] <= din0_reg[71:64];
        if (wmask0_reg[9])
                mem[addr0_reg][79:72] <= din0_reg[79:72];
        if (wmask0_reg[10])
                mem[addr0_reg][87:80] <= din0_reg[87:80];
        if (wmask0_reg[11])
                mem[addr0_reg][95:88] <= din0_reg[95:88];
        if (wmask0_reg[12])
                mem[addr0_reg][103:96] <= din0_reg[103:96];
        if (wmask0_reg[13])
                mem[addr0_reg][111:104] <= din0_reg[111:104];
        if (wmask0_reg[14])
                mem[addr0_reg][119:112] <= din0_reg[119:112];
        if (wmask0_reg[15])
                mem[addr0_reg][127:120] <= din0_reg[127:120];
    end
  end

  always @ (*)
  begin : MEM_READ0
    dout0 = mem[addr0_reg];
  end

endmodule
