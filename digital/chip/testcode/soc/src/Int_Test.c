/***
  Test reading and writing to GPIO pins
  bmn4 10/23/2024
 */

#include "acadia.h"
#include "stdint.h"

void init() {
  init_acaida_addrs();
}

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
  
  return 0;
}

