//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2023 06:25:47 PM
// Design Name: 
// Module Name: I2C_transceiver
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module I2C_transceiver (
    input  logic SDA_in,
    output logic SDA, 
    output logic SCL,

    input [7:0] Dout,
    input [6:0] slaveAddress,
    input RW, EN,
    
    output logic [15:0] Din,
    output wire Busy,
    output logic ACK_bit,

    input ce,
    input clk,
    input rst
);
    
    localparam STATE_IDLE           = 8'd0;
    localparam STATE_START_WRITE    = 8'd40;
    localparam STATE_START_READ     = 8'd80;
    localparam STATE_EPILOGUE       = 8'd253; 

    logic [7:0] State;

    logic error_bit;
    
    // Assign busy output, FSM is busy if not idle
    assign Busy = (State != STATE_IDLE);

    logic EN_reg;

    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            EN_reg <= '0;
        end else begin
            if(State != STATE_IDLE) begin
                EN_reg <= 1'b0;
            end else if( (State == STATE_IDLE) && EN) begin
                EN_reg <= 1'b1;
            end
        end
    end
    
    always_ff @(posedge clk, posedge rst) begin
      if(rst) begin
            SCL     <= 1'b1;
            SDA     <= 1'b1;
            ACK_bit <= 1'b1;  
            State   <= STATE_IDLE;
            error_bit <= 1'b0;

            `ifdef ACADIA_SIM
                Din <= '0;
            `else
                Din <= 'x;
            `endif
      end else if(ce) begin                               
        case (State)
            // Press Button[3] to start the state machine. Otherwise, stay in the STATE_INIT state        
            STATE_IDLE : begin
                 if (EN_reg == 1'b1) State <= 8'd1;                    
                 else begin                 
                      SCL <= 1'b1;
                      SDA <= 1'b1; // "Pull" high for IDLE
                      State <= STATE_IDLE;
                  end
            end            
            
            // This is the Start sequence            
            8'd1 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                                
            end   
            
            8'd2 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;
                  State <= State + 1'b1;                 
            end   

            // transmit bit 7   
            8'd3 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[6];
                  State <= State + 1'b1;                 
            end   
            8'd4 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd5 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd6 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd7 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[5];  
                  State <= State + 1'b1;               
            end   
            8'd8 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd9 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd10 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd11 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[4]; 
                  State <= State + 1'b1;                
            end   
            8'd12 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd13 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd14 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd15 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[3]; 
                  State <= State + 1'b1;                
            end   
            8'd16 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd17 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd18 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd19 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[2]; 
                  State <= State + 1'b1;                
            end   
            8'd20 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd21 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd22 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd23 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[1]; 
                  State <= State + 1'b1;                
            end   
            8'd24 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd25 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd26 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd27 : begin
                  SCL <= 1'b0;
                  SDA <= slaveAddress[0];  
                  State <= State + 1'b1;               
            end   
            8'd28 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd29 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd30 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd31 : begin
                  SCL <= 1'b0;
                  SDA <= RW;      
                  State <= State + 1'b1;           
            end   
            8'd32 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd33 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd34 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd35 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1; //* == 1'bz, float for input
                  State <= State + 1'b1;                 
            end   
            8'd36 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   
            8'd37 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA_in;                 
                  State <= State + 1'b1;
            end   
            8'd38 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1; //* == 1'bz, float for input
                  
                  // Check for acknowledge
                  if(ACK_bit) begin
                    State <= STATE_EPILOGUE; // NACK, stop then return to IDLE
                    error_bit <= 1'b1;
                  end
                  
                  // Go to Read/write state chain depending on mode
                  else if(RW == 0) State <= STATE_START_WRITE;
                  else State <= STATE_START_READ;
            end  
            
   //////////// START WRITE PASTE
   // transmit bit 7   
            STATE_START_WRITE : begin
                  SCL <= 1'b0;
                  SDA <= Dout[7];
                  State <= State + 1'b1;                 
            end   

            8'd41 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd42 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd43 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 6
            8'd44 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[6];  
                  State <= State + 1'b1;               
            end   

            8'd45 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd46 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd47 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 5
            8'd48 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[5]; 
                  State <= State + 1'b1;                
            end   

            8'd49 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd50 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd51 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 4
            8'd52 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[4]; 
                  State <= State + 1'b1;                
            end   

            8'd53 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd54 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd55 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // transmit bit 3
            8'd56 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[3]; 
                  State <= State + 1'b1;                
            end   

            8'd57 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd58 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd59 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
            
            // transmit bit 2
            8'd60 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[2]; 
                  State <= State + 1'b1;                
            end   

            8'd61 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd62 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd63 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end  
 
            // transmit bit 1
            8'd64 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[1];  
                  State <= State + 1'b1;               
            end   

            8'd65 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd66 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd67 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // transmit bit 0
            8'd68 : begin
                  SCL <= 1'b0;
                  SDA <= Dout[0];      
                  State <= State + 1'b1;           
            end   

            8'd69 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd70 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd71 : begin
                  SCL <= 1'b0;                  
                  State <= State + 1'b1;
            end  
                        
            // read the ACK bit from the sensor and display it on LED[7]
            8'd72 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1; //* == 1'bz, float for input
                  State <= State + 1'b1;                 
            end   

            8'd73 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd74 : begin
                  SCL <= 1'b1;
                  ACK_bit <= SDA_in;                 
                  State <= State + 1'b1;
            end   

            8'd75 : begin
                  SCL <= 1'b0;
                  State <= STATE_EPILOGUE;
            end
            
            
   
   //////////// END WRITE PASTE
   
   /////////// Begin READ
            STATE_START_READ : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1; //* == 1'bz, float for input
                  State <= State + 1'b1;                 
            end   

            // Read bit 15   
            8'd81 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd82 : begin
                  SCL <= 1'b1;
                  Din[15] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd83 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Read bit 14
            8'd84 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd85 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd86 : begin
                  SCL <= 1'b1;
                  Din[14] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd87 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 13
            8'd88 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd89 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd90 : begin
                  SCL <= 1'b1;
                  Din[13] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd91 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 12
            8'd92 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd93 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd94 : begin
                  SCL <= 1'b1;
                  Din[12] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd95 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 11
            8'd96 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd97 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd98 : begin
                  SCL <= 1'b1;
                  Din[11] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd99 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 10
            8'd100 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd101 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd102 : begin
                  SCL <= 1'b1;
                  Din[10] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd103 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
 
            // Read bit 9
            8'd104 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd105 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd106 : begin
                  SCL <= 1'b1;
                  Din[9] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd107 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Read bit 8
            8'd108 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd109 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd110 : begin
                  SCL <= 1'b1;
                  Din[8] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd111 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
                         
            // Transmit acknowledge
            8'd112 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;  // Pull SDA low for acknowledge
                  State <= State + 1'b1;                 
            end   

            8'd113 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd114 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd115 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // Read bit 7
            8'd116 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1; //* == 1'bz, float for input // Let go of SDA again to let slave drive it
                  State <= State + 1'b1;                 
            end
               
            8'd117 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd118 : begin
                  SCL <= 1'b1;
                  Din[7] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd119 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Read bit 6
            8'd120 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd121 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd122 : begin
                  SCL <= 1'b1;
                  Din[6] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd123 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 5
            8'd124 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd125 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd126 : begin
                  SCL <= 1'b1;
                  Din[5] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd127 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 4
            8'd128 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd129 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd130 : begin
                  SCL <= 1'b1;
                  Din[4] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd131 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 3
            8'd132 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd133 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd134 : begin
                  SCL <= 1'b1;
                  Din[3] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd135 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
            
            // Read bit 2
            8'd136 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd137 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd138 : begin
                  SCL <= 1'b1;
                  Din[2] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd139 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   
 
            // Read bit 1
            8'd140 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd141 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd142 : begin
                  SCL <= 1'b1;
                  Din[1] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd143 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end   

            // Read bit 0
            8'd144 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;               
            end   

            8'd145 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd146 : begin
                  SCL <= 1'b1;
                  Din[0] <= SDA_in;
                  State <= State + 1'b1;
            end   

            8'd147 : begin
                  SCL <= 1'b0;
                  State <= State + 1'b1;
            end
            
            // Transmit No-ACK
            8'd148 : begin
                  SCL <= 1'b0;
                  SDA <= 1'b1;  // "Pull" SDA high for NACK
                  State <= State + 1'b1;                 
            end   

            8'd149 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd150 : begin
                  SCL <= 1'b1;
                  State <= State + 1'b1;
            end   

            8'd151 : begin
                  SCL <= 1'b0;
                  State <= STATE_EPILOGUE;
            end
            
  /////////////stop bit sequence and go back to STATE_IDLE           
            STATE_EPILOGUE : begin
                  SCL <= 1'b0;
                  SDA <= 1'b0;                
                  State <= State + 1'b1;
            end   

            8'd254 : begin
                  SCL <= 1'b1;
                  SDA <= 1'b0;
                  State <= State + 1'b1;
            end                                    

            8'd255 : begin
                 SCL <= 1'b1;
                 SDA <= 1'b1; // "Pull" high for IDLE
                 State <= 8'd255;
                 
                 if(!EN_reg) State <= STATE_IDLE;                  
            end              
            
            //If the FSM ends up in this state, there was an error in teh FSM code
            //LED[6] will be turned on (signal is active low) in that case.
            default : begin
                  State <= STATE_IDLE;
            end                              
        endcase
      end             
    end      
    
    
endmodule
