/***
  Test reading and writing to GPIO pins
  bmn4 10/23/2024
 */

#include "acadia.h"

void init() {
  init_acaida_addrs();
}

int main () {
  int gpio_read;

  init();

  // Test read no drive, just pullups
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0xff ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  }

  // Test output without tristate keeps pullups
  *GPIO_A_OUTPUT = 0x00;
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0xff ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  }

  // Drive IO Pins and read
  *GPIO_A_TRISTATE = 0xff;
  asm volatile ("addi x0, x0, 0"); // Give time for input to make it thru synchronizer
  asm volatile ("addi x0, x0, 0");
  gpio_read = *GPIO_A_INPUT;
  if( (gpio_read & 0xff) != 0x00 ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  }

  for(int i = 0; i <= 0xff; ++i) {
    *GPIO_A_OUTPUT = i;
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    gpio_read = *GPIO_A_INPUT;
    if( (gpio_read & 0xff) != i ) {
      asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
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
  }

  // Dump Core
  *GPIO_A_OUTPUT = 0x69;
  *GPIO_A_TRISTATE = 0xFF;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");

  return gpio_read;
}