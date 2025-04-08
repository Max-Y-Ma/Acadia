// The following macro's define the supported commands in this
// Simulation
//

`define CMD_WRITE_DISABLE 			      	8'h04
`define CMD_WRITE_ENABLE  			      	8'h06
`define CMD_READ_STATUS				          8'h05
`define CMD_WRITE_STATUS				        8'h01
`define CMD_READ_STATUS2				        8'h35
`define CMD_WRITE_STATUS2          			8'h31
`define CMD_READ_STATUS3           			8'h15
`define CMD_WRITE_STATUS3          			8'h11
`define CMD_READ_DATA				            8'h03
`define CMD_READ_DATA_FAST			      	8'h0b
`define CMD_READ_DATA_FAST_WRAP    			8'h0c
`define CMD_READ_DATA_FAST_DUAL		  		8'h3b
`define CMD_READ_DATA_FAST_DUAL_IO			8'hbb
`define CMD_READ_DATA_FAST_QUAD		  		8'h6b
`define CMD_READ_DATA_FAST_QUAD_IO			8'heb
`define CMD_READ_OCTAL_FAST_QUAD_IO 		8'he3
`define CMD_READ_WORD_FAST_QUAD_IO 			8'he7
`define CMD_PAGE_PROGRAM				        8'h02
`define CMD_PAGE_PROGRAM_QUAD			    	8'h32
`define CMD_BLOCK_ERASE				          8'hD8
`define CMD_HALF_BLOCK_ERASE			    	8'h52
`define CMD_SECTOR_ERASE				        8'h20
`define CMD_BULK_ERASE				          8'hC7
`define CMD_BULK_ERASE2				          8'h60
`define CMD_DEEP_POWERDOWN			      	8'hB9
`define CMD_READ_SIGNATURE			      	8'hAB
`define CMD_READ_ID					            8'h90
`define CMD_READ_ID_DUAL           			8'h92
`define CMD_READ_ID_QUAD           			8'h94
`define CMD_READ_JEDEC_ID			       	  8'h9f
`define CMD_READ_UNIQUE_ID			      	8'h4b
`define CMD_SUSPEND                			8'h75
`define CMD_RESUME                 			8'h7A
`define CMD_SET_BURST_WRAP         			8'h77
`define CMD_MODE_RESET             			8'hff
`define CMD_DISABLE_QPI            			8'hff
`define CMD_ENABLE_QPI             			8'h38
`define CMD_ENABLE_RESET           			8'h66
`define CMD_CHIP_RESET             			8'h99
`define CMD_SET_READ_PARAM         			8'hC0
`define CMD_SREG_PROGRAM           			8'h42
`define CMD_SREG_ERASE             			8'h44
`define CMD_SREG_READ              			8'h48
`define CMD_WRITE_ENABLE_VSR       			8'h50
`define CMD_READ_SFDP              			8'h5A
`define CMD_INDIVIDUAL_LOCK        			8'h36
`define CMD_INDIVIDUAL_UNLOCK      			8'h39
`define CMD_READ_BLOCK_LOCK        			8'h3D
`define CMD_GLOBAL_BLOCK_LOCK      			8'h7E
`define CMD_GLOBAL_BLOCK_UNLOCK    			8'h98


// Status register definitions
//

`define STATUS_HLD_RST   	24'h800000
`define STATUS_DRV1      	24'h400000
`define STATUS_DRV0      	24'h200000
`define STATUS_WPS       	24'h040000
`define STATUS_SUS       	24'h008000
`define STATUS_CMP       	24'h004000
`define STATUS_LB3       	24'h002000
`define STATUS_LB2       	24'h001000
`define STATUS_LB1       	24'h000800
`define STATUS_QE					24'h000200
`define STATUS_SRP1				24'h000100
`define STATUS_SRP0				24'h000080
`define STATUS_SEC 				24'h000040
`define STATUS_TB				  24'h000020
`define STATUS_BP2				24'h000010
`define STATUS_BP1				24'h000008
`define STATUS_BP0	   		24'h000004
`define STATUS_WEL		 		24'h000002
`define STATUS_WIP	 			24'h000001


`define HLD_RST   23
`define DRV1 		  22
`define DRV0 		  21
`define WPS  		  18
`define SUS  		  15
`define CMPB 		  14
`define LB3  		  13
`define LB2  		  12
`define LB1  		  11
`define QE	  	  9
`define SRP1		  8
`define SRP0		  7
`define SEC 	 	  6
`define TB  		  5
`define BP2	 	    4
`define BP1	 	    3
`define BP0	 	    2
`define WEL	 	    1
`define WIP	 	    0
