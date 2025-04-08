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

  // ///// TEST: Check UART Buffers are empty on startup
  // if(*UART1_RX_BUFFER >= 0) {
  //   asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  // }

  // if(*UART2_RX_BUFFER >= 0) {
  //   asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  // }

  // ///// TEST: Check basic TX/RX
  // // Transmit 0x55
  // *UART1_TX_BUFFER = 0x55;
  
  // // Wait for item on RX
  // timeout = 0;
  // while( (buf = *UART1_RX_BUFFER) < 0 ) {
  //   // Check for timeout 300000 should be > 2 seconds

  //   if(++timeout > 300000) {
  //     asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch

  //     // Exit test
  //     return -1;
  //   }
  // }

  // // Check recieved value
  // if(buf != 0x55) {
  //   asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  // }

  // // Check RX buffer now empty
  // if(*UART1_RX_BUFFER >= 0) {
  //   asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  // }

  ///// TEST: Check TX stall works, doesn't drop packets
  // TX 70 bits, will fill TX buffer (64 items)
  // Each bit takes very long to transmit, so after finishing this loop
  // RX buffer should not be full yet
  for(int i = 0; i < 70; ++i) {
    *UART1_TX_BUFFER = i;
  }

  // Read out RX buffer to make sure nothing dropped
  timeout = 0;
  for (int i = 0; i < 70; ++i) {
    while( (buf = *UART1_RX_BUFFER) < 0 ) {}

    if(buf != i){
      asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
      return -1;
    }
  }

  // Check RX buffer now empty
  if(*UART1_RX_BUFFER >= 0) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  }


  ///// TEST: Check RX drops packets
  // Tx 2 buffers worth, the last 64 items should be dropped
  for(int i = 128; i < 256; ++i) {
    *UART1_TX_BUFFER = i;
  }

  for (int i = 128; i < 128+64; ++i) {
    while( (buf = *UART1_RX_BUFFER) < 0 ) {}

    if(buf != i){
      asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
      return -1;
    }
  }

  // Check RX buffer now empty
  if(*UART1_RX_BUFFER >= 0) {
    asm volatile ("slti x0, x0, -10"); // Throw monitor mismatch
  }

  return 0;
}