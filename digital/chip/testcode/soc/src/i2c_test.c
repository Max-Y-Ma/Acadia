/***
  Test UART peripherals
  bmn4 10/23/2024
 */

#include "acadia.h"

void init() {
  
}

int main () {
  int buf;
  int timeout;

  // Initialize Acadia Library variables
  init_acaida_addrs();

  // Setup I2C1 to 90KHZ
  *I2C1_BAUD_FREQ  = 9;
  *I2C1_BAUD_LIMIT = 3134;

  ///// TEST: Not busy startup: {7'b0, ACK_bit, 7'b0, Busy, Din};
  buf = *I2C1_OUTPUT;
  if( buf & (0x1 << 16) ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  ///// TEST: NACK on unoccupied address
  // Send out read to unoccupied address
  *I2C1_CONFIG = (0b1100000 << 17) | (1 << 16);
  *I2C1_CONFIG |= 1;

  // Wait for start busy
  while( ! ((buf = *I2C1_OUTPUT) & (1<<16)) ) {}
  // Wait for end busy
  while( (buf = *I2C1_OUTPUT) & (1<<16) ) {}

  // Check for NACK
  if( buf & (0x1 << 24) ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  ///// TEST: Write to Slave
  *I2C1_CONFIG = (0b0100000 << 17) | (0 << 16) | (0x02 << 8);
  *I2C1_CONFIG |= 1;

  // Wait for start busy
  while( ! ((buf = *I2C1_OUTPUT) & (1<<16)) ) {}
  // Wait for end busy
  while( (buf = *I2C1_OUTPUT) & (1<<16) ) {}

  // Check for ACK
  if( !(buf & (0x1 << 24)) ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  ///// TEST: Read from Slave
  *I2C1_CONFIG = (0b0100000 << 17) | (1 << 16);
  *I2C1_CONFIG |= 1;

  // Wait for start busy
  while( ! ((buf = *I2C1_OUTPUT) & (1<<16)) ) {}
  // Wait for end busy
  while( (buf = *I2C1_OUTPUT) & (1<<16) ) {}

  // Check for ACK
  if( !(buf & (0x1 << 24)) ) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  // Check for correct value
  if ((buf & 0xffff) != 0x0203) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
    return -1;
  }

  return 0;
}