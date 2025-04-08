/***
  Test reading and writing to GPIO pins
  bmn4 10/23/2024
 */

#include "acadia.h"

void init() {
  init_acaida_addrs();
}

int main () {
  init();

  asm volatile ("li x4, 4");
  asm volatile ("li x5, 5");
  asm volatile ("li x6, 6");
  asm volatile ("li x7, 7");
  asm volatile ("li x8, 8");
  asm volatile ("li x9, 9");
  asm volatile ("li x10, 10");
  asm volatile ("li x11, 11");
  asm volatile ("li x12, 12");
  // asm volatile ("li x13, 13");
  // asm volatile ("li x14, 14");
  // asm volatile ("li x15, 15");
  asm volatile ("li x16, 16");
  asm volatile ("li x17, 17");
  asm volatile ("li x18, 18");
  asm volatile ("li x19, 19");
  asm volatile ("li x20, 20");
  asm volatile ("li x21, 21");
  asm volatile ("li x22, 22");
  asm volatile ("li x23, 23");
  asm volatile ("li x24, 24");
  asm volatile ("li x25, 25");
  asm volatile ("li x26, 26");
  asm volatile ("li x27, 27");
  asm volatile ("li x28, 28");
  asm volatile ("li x29, 29");
  asm volatile ("li x30, 30");
  asm volatile ("li x31, 31");

  // Dump Core
  *GPIO_A_OUTPUT = 0x69;
  *GPIO_A_TRISTATE = 0xFF;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");

  return 0;
}