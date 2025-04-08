//---------------------------------------------------------------------------------------
// uart top level module  
// Taken from: https://opencores.org/projects/uart2bus
// Modified 10/7/2024 by bmn4
// Originally uart_top.v
//---------------------------------------------------------------------------------------

module uart_top 
(
	// global signals 
	input 	clock,
	input 	reset,
	// uart serial signals 
	input 	ser_in,
	output 	ser_out,
	// transmit and receive internal interface signals 
	output	[7:0]	rx_data,
	output			new_rx_data, 
	input	[7:0]	tx_data,
	input			new_tx_data,
	output			tx_busy, 
	// baud rate configuration register - see baud_gen.v for details 
	input	[11:0]	baud_freq,
	input	[15:0]	baud_limit, 
	output	baud_clk 
);
//---------------------------------------------------------------------------------------

// internal wires 
wire ce_16;		// clock enable at bit rate 

assign baud_clk = ce_16;
//---------------------------------------------------------------------------------------
// module implementation 
// baud rate generator module 
baud_gen baud_gen_1
(
	.clock(clock), .reset(reset), 
	.ce_16(ce_16), .baud_freq(baud_freq), .baud_limit(baud_limit)
);

// uart receiver 
uart_rx uart_rx_1 
(
	.clock(clock), .reset(reset), 
	.ce_16(ce_16), .ser_in(ser_in), 
	.rx_data(rx_data), .new_rx_data(new_rx_data) 
);

// uart transmitter 
uart_tx  uart_tx_1
(
	.clock(clock), .reset(reset), 
	.ce_16(ce_16), .tx_data(tx_data), .new_tx_data(new_tx_data), 
	.ser_out(ser_out), .tx_busy(tx_busy) 
);

endmodule
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------
