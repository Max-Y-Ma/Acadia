/**
 acadia.h

 Defintions for basic MCU functions
 */

#define MMAP_START_BASE_ADDR (0x38000 << 13)
#define DATA_SRAM_BASE_ADDR  (0x38000 << 13)
#define GPIO_BASE_ADDR       (0x38001 << 13)
#define PRESCALER_BASE_ADDR  (0x38002 << 13)
#define INT_BASE_ADDR        (0x38003 << 13)
#define RSA_BASE_ADDR        (0x38004 << 13)
#define MMAP_END_BASE_ADDR   (0x78000 << 13)
#define UART1_BASE_ADDR      (0x38005 << 13)
#define UART2_BASE_ADDR      (0x38006 << 13)
#define I2C1_BASE_ADDR       (0x38007 << 13)
#define I2C2_BASE_ADDR       (0x38008 << 13)
#define SPI1_BASE_ADDR       (0x38009 << 13)
#define ANALOG_BASE_ADDR     (0x3800A << 13)

volatile int * PRESCALER_ANALOG;
volatile int * PRESCALER_TIMER;

volatile int * GPIO_A_INPUT;
volatile int * GPIO_A_OUTPUT;
volatile int * GPIO_A_TRISTATE;

volatile int * UART1_RX_BUFFER;   // R : {{24{rx_buf_empty}}, rx_buf_rdata}
volatile int * UART1_TX_BUFFER;   //  W: Writes lowest byte to TX buffer
volatile int * UART1_BAUD_FREQ;   // RW: Lower 12bit clk div increment
volatile int * UART1_BAUD_LIMIT;  // RW: Lower 16bit clk div threshold

volatile int * UART2_RX_BUFFER;
volatile int * UART2_TX_BUFFER;
volatile int * UART2_BAUD_FREQ;
volatile int * UART2_BAUD_LIMIT;

volatile int * I2C1_CONFIG;
volatile int * I2C1_OUTPUT;
volatile int * I2C1_BAUD_FREQ;
volatile int * I2C1_BAUD_LIMIT;

volatile int * I2C2_CONFIG;
volatile int * I2C2_OUTPUT;
volatile int * I2C2_BAUD_FREQ;
volatile int * I2C2_BAUD_LIMIT;

volatile int * SPI1_WRITE_BUF;
volatile int * SPI1_BUF_PTR;
volatile int * SPI1_BAUD_FREQ;
volatile int * SPI1_BAUD_LIMIT;

volatile int * INT_MASK;
volatile int * INT_IVT;

volatile int * ADC_REG;
volatile int * DAC_REG;

void init_acaida_addrs() {
  // Initialize Pointers
  // At time of writing, linker does not do initailized values section yet
  PRESCALER_ANALOG  = (int *) PRESCALER_BASE_ADDR + 0;
  PRESCALER_TIMER   = (int *) PRESCALER_BASE_ADDR + 1;

  GPIO_A_INPUT    = (int *) GPIO_BASE_ADDR + 0;
  GPIO_A_OUTPUT   = (int *) GPIO_BASE_ADDR + 1;
  GPIO_A_TRISTATE = (int *) GPIO_BASE_ADDR + 2;

  UART1_RX_BUFFER   = (int *) UART1_BASE_ADDR + 0;
  UART1_TX_BUFFER   = (int *) UART1_BASE_ADDR + 1;
  UART1_BAUD_FREQ   = (int *) UART1_BASE_ADDR + 2;
  UART1_BAUD_LIMIT  = (int *) UART1_BASE_ADDR + 3;

  UART2_RX_BUFFER   = (int *) UART2_BASE_ADDR + 0;
  UART2_TX_BUFFER   = (int *) UART2_BASE_ADDR + 1;
  UART2_BAUD_FREQ   = (int *) UART2_BASE_ADDR + 2;
  UART2_BAUD_LIMIT  = (int *) UART2_BASE_ADDR + 3;

  I2C1_CONFIG     = (int *) I2C1_BASE_ADDR + 0;
  I2C1_OUTPUT     = (int *) I2C1_BASE_ADDR + 1;
  I2C1_BAUD_FREQ  = (int *) I2C1_BASE_ADDR + 2;
  I2C1_BAUD_LIMIT = (int *) I2C1_BASE_ADDR + 3;

  I2C2_CONFIG     = (int *) I2C2_BASE_ADDR + 0;
  I2C2_OUTPUT     = (int *) I2C2_BASE_ADDR + 1;
  I2C2_BAUD_FREQ  = (int *) I2C2_BASE_ADDR + 2;
  I2C2_BAUD_LIMIT = (int *) I2C2_BASE_ADDR + 3;

  SPI1_WRITE_BUF  = (int *) SPI1_BASE_ADDR + 0;
  SPI1_BUF_PTR    = (int *) SPI1_BASE_ADDR + 1;
  SPI1_BAUD_FREQ  = (int *) SPI1_BASE_ADDR + 2;
  SPI1_BAUD_LIMIT = (int *) SPI1_BASE_ADDR + 3;

  INT_MASK        = (int *) INT_BASE_ADDR + 0;
  INT_IVT         = (int *) INT_BASE_ADDR + 1;

  ADC_REG         = (int *) ANALOG_BASE_ADDR + 0;
  DAC_REG         = (int *) ANALOG_BASE_ADDR + 1;
}

inline void save_regs() {
  asm volatile ("lui x1, 0x70001"); //save all registers

  asm volatile ("sw x3, 0(x1)");
  asm volatile ("sw x4, 4(x1)");
  asm volatile ("sw x5, 8(x1)");
  asm volatile ("sw x6, 12(x1)");

  asm volatile ("sw x7, 16(x1)");
  asm volatile ("sw x8, 20(x1)");
  asm volatile ("sw x9, 24(x1)");
  asm volatile ("sw x10, 28(x1)");
  
  asm volatile ("sw x11, 32(x1)");
  asm volatile ("sw x12, 36(x1)");
  asm volatile ("sw x13, 40(x1)");
  asm volatile ("sw x14, 44(x1)");
  
  asm volatile ("sw x15, 48(x1)");
  asm volatile ("sw x16, 52(x1)");
  asm volatile ("sw x17, 56(x1)");
  asm volatile ("sw x18, 60(x1)");

  asm volatile ("sw x19, 64(x1)");
  asm volatile ("sw x20, 68(x1)");
  asm volatile ("sw x21, 72(x1)");
  asm volatile ("sw x22, 76(x1)");

  asm volatile ("sw x23, 80(x1)");
  asm volatile ("sw x24, 84(x1)");
  asm volatile ("sw x25, 88(x1)");
  asm volatile ("sw x26, 92(x1)");

  asm volatile ("sw x27, 96(x1)");
  asm volatile ("sw x28, 100(x1)");
  asm volatile ("sw x29, 104(x1)");
  asm volatile ("sw x30, 108(x1)");
  
  asm volatile ("sw x31, 112(x1)");
}

inline void restore_regs() {
  asm volatile ("lui x1, 0x70001"); //save all registers

  asm volatile ("lw x3, 0(x1)");
  asm volatile ("lw x4, 4(x1)");
  asm volatile ("lw x5, 8(x1)");
  asm volatile ("lw x6, 12(x1)");

  asm volatile ("lw x7, 16(x1)");
  asm volatile ("lw x8, 20(x1)");
  asm volatile ("lw x9, 24(x1)");
  asm volatile ("lw x10, 28(x1)");
  
  asm volatile ("lw x11, 32(x1)");
  asm volatile ("lw x12, 36(x1)");
  asm volatile ("lw x13, 40(x1)");
  asm volatile ("lw x14, 44(x1)");
  
  asm volatile ("lw x15, 48(x1)");
  asm volatile ("lw x16, 52(x1)");
  asm volatile ("lw x17, 56(x1)");
  asm volatile ("lw x18, 60(x1)");

  asm volatile ("lw x19, 64(x1)");
  asm volatile ("lw x20, 68(x1)");
  asm volatile ("lw x21, 72(x1)");
  asm volatile ("lw x22, 76(x1)");

  asm volatile ("lw x23, 80(x1)");
  asm volatile ("lw x24, 84(x1)");
  asm volatile ("lw x25, 88(x1)");
  asm volatile ("lw x26, 92(x1)");

  asm volatile ("lw x27, 96(x1)");
  asm volatile ("lw x28, 100(x1)");
  asm volatile ("lw x29, 104(x1)");
  asm volatile ("lw x30, 108(x1)");
  
  asm volatile ("lw x31, 112(x1)");
}