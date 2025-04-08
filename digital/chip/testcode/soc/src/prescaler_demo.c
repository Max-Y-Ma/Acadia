/***
  Test reading and writing to GPIO pins
  bmn4 10/23/2024
 */

#include "acadia.h"
#define NUM_TIMER_THRESH 2
#define NUM_DAC_THRESH 128
#define NUM_ADC_THRESH 2

volatile int num_timer_interrupts;
volatile int num_dac_interrupts;
volatile int num_adc_interrupts;
volatile int next_dac;

void init() {
  init_acaida_addrs();
  num_timer_interrupts = 0;
  num_dac_interrupts   = 0;
  num_adc_interrupts   = 0;
}

void ISR_Timer(){
  save_regs();

  num_timer_interrupts++;

  restore_regs();
  asm volatile ("mret");
}

void ISR_DAC() {
  save_regs();

  num_dac_interrupts++;
  next_dac = 1;

  restore_regs();
  asm volatile ("mret");
}

void ISR_ADC() {
  save_regs();

  num_adc_interrupts++;

  restore_regs();
  asm volatile ("mret");
}


int main () {
  init();

  *PRESCALER_TIMER = 2;
  *PRESCALER_ANALOG = 11;

  for(int i = 0; i < 0xff; ++i) {
    asm volatile ("addi x0, x0, 0");
  }

  *PRESCALER_TIMER = 11;
  *PRESCALER_ANALOG = 6;
  
  for(int i = 0; i < 0xff; ++i) {
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
  }

  *PRESCALER_ANALOG = 0xffff;
  *PRESCALER_TIMER  = 0xff;

  INT_IVT[14] = (int) &ISR_Timer;
  *INT_MASK = 1 << 14;

  // If timeout, error out
  // Should hit a few interrupts and dump
  for(int i = 0; i < 0xffff; ++i) {
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");
    asm volatile ("addi x0, x0, 0");

    if(num_timer_interrupts > NUM_TIMER_THRESH) {
      break;
    }
  }

  *INT_MASK = 0;

  if(num_timer_interrupts <= NUM_TIMER_THRESH) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  *PRESCALER_ANALOG = 6;

  INT_IVT[13] = (int) &ISR_ADC;
  INT_IVT[12] = (int) &ISR_DAC;
  *INT_MASK = (1 << 13) | (1 << 12);

  next_dac = 0;
  *DAC_REG = 0xAA;
  for(int i = 0; i < 7000; ++i) {
    if(next_dac){
      next_dac = 0;
      *DAC_REG = num_dac_interrupts;
    }

    if(num_dac_interrupts > NUM_DAC_THRESH) {
      break;
    }
  }

  if(num_dac_interrupts <= NUM_DAC_THRESH) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  if(num_adc_interrupts < NUM_ADC_THRESH) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Dump Core, end sim
  *GPIO_A_OUTPUT = 0x69;
  *GPIO_A_TRISTATE = 0xFF;
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  asm volatile ("addi x0, x0, 0");
  
  return 0;
}