/***
  Test reading and writing to GPIO pins
  bmn4 10/23/2024
 */

#include "acadia.h"
#include "stdint.h"

void init() {
  init_acaida_addrs();
}


// inline void save_regs() {
//   asm volatile ("lui x1, 0x70001"); //save all registers

//   asm volatile ("sw x3, 0(x1)");
//   asm volatile ("sw x4, 4(x1)");
//   asm volatile ("sw x5, 8(x1)");
//   asm volatile ("sw x6, 12(x1)");

//   asm volatile ("sw x7, 16(x1)");
//   asm volatile ("sw x8, 20(x1)");
//   asm volatile ("sw x9, 24(x1)");
//   asm volatile ("sw x10, 28(x1)");
  
//   asm volatile ("sw x11, 32(x1)");
//   asm volatile ("sw x12, 36(x1)");
//   asm volatile ("sw x13, 40(x1)");
//   asm volatile ("sw x14, 44(x1)");
  
//   asm volatile ("sw x15, 48(x1)");
//   asm volatile ("sw x16, 52(x1)");
//   asm volatile ("sw x17, 56(x1)");
//   asm volatile ("sw x18, 60(x1)");

//   asm volatile ("sw x19, 64(x1)");
//   asm volatile ("sw x20, 68(x1)");
//   asm volatile ("sw x21, 72(x1)");
//   asm volatile ("sw x22, 76(x1)");

//   asm volatile ("sw x23, 80(x1)");
//   asm volatile ("sw x24, 84(x1)");
//   asm volatile ("sw x25, 88(x1)");
//   asm volatile ("sw x26, 92(x1)");

//   asm volatile ("sw x27, 96(x1)");
//   asm volatile ("sw x28, 100(x1)");
//   asm volatile ("sw x29, 104(x1)");
//   asm volatile ("sw x30, 108(x1)");
  
//   asm volatile ("sw x31, 112(x1)");
// }

// inline void restore_regs() {
//   asm volatile ("lui x1, 0x70001"); //save all registers

//   asm volatile ("lw x3, 0(x1)");
//   asm volatile ("lw x4, 4(x1)");
//   asm volatile ("lw x5, 8(x1)");
//   asm volatile ("lw x6, 12(x1)");

//   asm volatile ("lw x7, 16(x1)");
//   asm volatile ("lw x8, 20(x1)");
//   asm volatile ("lw x9, 24(x1)");
//   asm volatile ("lw x10, 28(x1)");
  
//   asm volatile ("lw x11, 32(x1)");
//   asm volatile ("lw x12, 36(x1)");
//   asm volatile ("lw x13, 40(x1)");
//   asm volatile ("lw x14, 44(x1)");
  
//   asm volatile ("lw x15, 48(x1)");
//   asm volatile ("lw x16, 52(x1)");
//   asm volatile ("lw x17, 56(x1)");
//   asm volatile ("lw x18, 60(x1)");

//   asm volatile ("lw x19, 64(x1)");
//   asm volatile ("lw x20, 68(x1)");
//   asm volatile ("lw x21, 72(x1)");
//   asm volatile ("lw x22, 76(x1)");

//   asm volatile ("lw x23, 80(x1)");
//   asm volatile ("lw x24, 84(x1)");
//   asm volatile ("lw x25, 88(x1)");
//   asm volatile ("lw x26, 92(x1)");

//   asm volatile ("lw x27, 96(x1)");
//   asm volatile ("lw x28, 100(x1)");
//   asm volatile ("lw x29, 104(x1)");
//   asm volatile ("lw x30, 108(x1)");
  
//   asm volatile ("lw x31, 112(x1)");
// }

void Interrupt_1(){
  save_regs();

  int x, y;
  x = 5;
  y = 5;

  x = x + y;

  restore_regs();
  asm volatile ("mret");
}

void Interrupt_2(){
  save_regs();

  int x, y;
  x = 5;
  y = 5;

  x = x + y;

  restore_regs();
  asm volatile ("mret");
}

int gpio_test () {
  int gpio_read;

  // Test read no drive, just pullups
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0xff ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Test output without tristate keeps pullups
  *GPIO_A_OUTPUT = 0x00;
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0xff ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Drive IO Pins and read
  *GPIO_A_TRISTATE = 0xff;
  asm volatile ("addi x0, x0, 0"); // Give time for input to make it thru synchronizer
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0x00 ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  for(int i = 0; i <= 0xff; ++i) {
    *GPIO_A_OUTPUT = i;
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    gpio_read = *GPIO_A_INPUT;
    if( (gpio_read & 0xff) != i ) {
      asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
      return -1;
    }
  }

  // Test drive some pins
  *GPIO_A_OUTPUT = 0x00;
  *GPIO_A_TRISTATE = 0xA5;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0x5A ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  return gpio_read;
}

int main () {

  init();

  INT_IVT[0] = (int) &Interrupt_1;
  INT_IVT[1] = (int) &Interrupt_2;

  uint16_t mask_val = *INT_MASK;
  INT_MASK[0]       = (mask_val || 1);

  int curr_mask; 

  for(int i = 0; i < 256; i++){
    curr_mask = INT_MASK[0];
  }

  gpio_test();

  // Dump Core
  *GPIO_A_OUTPUT = 0x69;
  *GPIO_A_TRISTATE = 0xFF;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  
  return 0;
}

