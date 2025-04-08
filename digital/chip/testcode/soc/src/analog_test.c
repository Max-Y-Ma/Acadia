/***
  Analog Control Register Test
  bmn4 10/23/2024
 */

#include "acadia.h"

#define ADC_VALUE 0x6900
#define DAC_VALUE 0x42

int main () {
  int time_out;
  int buf;

  // Initialize Acadia Library variables
  init_acaida_addrs();

  // Read and Write to ADC Register
  for(int i = 0; i < 5; ++i) {
    *ADC_REG = 0;
    *ADC_REG = ADC_VALUE & (~0b100000000000); // Dont' touch EXT_OPT
  }

  *ADC_REG = ADC_VALUE;

  if ((*ADC_REG & 0xff00) != (ADC_VALUE & 0xff00)) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Read and Write to DAC Register
  *DAC_REG = DAC_VALUE;
  buf = *DAC_REG;
  if ((buf & 0xff) != DAC_VALUE) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Check DAC busy
  if(buf >= 0) {
    if(*DAC_REG >= 0) { // Refresh busy if not yet busy
      asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
      return -1;
    }
  }


  // Check DAC goes free after a while
  time_out = 300;
  while( (*DAC_REG >> 31) && (time_out > 0) ) {
    time_out--;
  }

  if(time_out == 0) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  for(int i = 0; i < 8; ++i) {
    *DAC_REG = i;
    while((*DAC_REG >> 31)); // Wait until free
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
