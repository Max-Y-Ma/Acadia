/***
  Analog Control Register Test
  bmn4 10/23/2024
 */

#include "acadia.h"

int main () {
  int time_out;
  int buf;

  // Initialize Acadia Library variables
  init_acaida_addrs();

  // Read and Write to ADC Register
  *ADC_REG |= 1 << 10; // Turn on FIRMWARE_EN_BIT
  *GPIO_A_OUTPUT = 0x00;
  *GPIO_A_TRISTATE = 0xFF;
  *DAC_REG = 0;
  *ADC_REG |= 1 << 9; // Enable ADC  

  for(int i = 0; i < 5000; ++i) {
    buf = *ADC_REG & 0xff;

    if(buf != 0x69) {
      *GPIO_A_OUTPUT = buf;

      if(*DAC_REG >= 0){ // Make sure DAC ready
        *DAC_REG = buf;
      }
    }

    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
  }

  // Dump Core
  *GPIO_A_OUTPUT = 0x69;
  *GPIO_A_TRISTATE = 0xFF;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  
  return 0;
}