/***
  Test UART peripherals
  bmn4 10/23/2024
 */

#include "acadia.h"

void init() {
  // Initialize Acadia Library variables
  init_acaida_addrs();
}

int main () {
  int buf;

  int rptr, wptr;
  
  init();
  
  ///// TEST: Send out four bytes, check ptrs
  *SPI1_WRITE_BUF = 0xAA;
  *SPI1_WRITE_BUF = 0x55;
  *SPI1_WRITE_BUF = 0xEC;
  *SPI1_WRITE_BUF = 0xEB;

  buf = *SPI1_BUF_PTR;

  rptr = buf & 0x1f;
  wptr = (buf >> 16) & 0x1f;

  if(rptr == 0x0 || wptr != 0x4) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  while(rptr != wptr) {
    buf = *SPI1_BUF_PTR;

    rptr = buf & 0x1f;
    wptr = (buf >> 16) & 0x1f;
  }

  asm volatile ("addi x0, x0, 0");

  ///// TEST: Send out a lot of bytes to check full
  for(int i = 0; i < 26; ++i) {
    // Visually ensure number increase

    *SPI1_WRITE_BUF = i;
  }

  asm volatile ("addi x0, x0, 0");

  buf = *SPI1_BUF_PTR;
  rptr = buf & 0x1f;
  wptr = (buf >> 16) & 0x1f;

  while(rptr != wptr) {
    buf = *SPI1_BUF_PTR;

    rptr = buf & 0x1f;
    wptr = (buf >> 16) & 0x1f;
  }

  return 0;
}