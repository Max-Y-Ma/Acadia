
module RSA_ACCELERATOR
#(
    //size of our public and private keys
    parameter KEY_SIZE_BITS     = 16, 
    //size of our result after a multiplication
    parameter INTERMEDIATE_RES  = KEY_SIZE_BITS * 2,
    //DIVIDER  block Parameters
    parameter DIV_MULT_SIGN     = 0, //multiply/divide unsigned 
    parameter DIV_INPUT_MODE    = 1, //register divider inputs
    parameter DIV_OUTPUT_MODE   = 0,
    parameter DIV_RST_MODE      = 0, //use asynchronous resets
    parameter DIV_CYC_COUNT     = 6, //take 6 clock cycles to calculate result
    parameter DIV_EARLY_START   = 0 //do we start division on clk 1 or 2
)(
    input logic                      clk,
    input logic                      rst_n,
    input logic                      RSA_start,

    input logic [KEY_SIZE_BITS-1:0]  RSA_key,
    input logic [KEY_SIZE_BITS-1:0]  mod_n,
    input logic [KEY_SIZE_BITS-1:0]  msg_block,

    input logic                      update_key_from_mem,
    input logic                      update_mod_n,
    input logic                      update_msg_blk,

    output logic [KEY_SIZE_BITS-1:0] o_output_msg,
    output logic                     o_idle_flag
);

//fsm enumeration start: (Link to block diagram to explain logic/flow)
enum logic [1:0]  {idle_data, loop_data, mult_wait, div_wait} curr_state, next_state;

logic [KEY_SIZE_BITS-1:0]    step_result, next_step_result; //intermediate variable for the next step multiplication
logic [KEY_SIZE_BITS-1:0]    bin_mes, next_bin_mes; //intermediate variable for the binary messagae
logic [KEY_SIZE_BITS-1:0]    stored_key, next_stored_key;
logic [KEY_SIZE_BITS-1:0]    saved_mod_n;
logic                        update_key, update_mes, update_step;

logic [1:0]                  start_mult, start_div;
logic [1:0]                  mult_done, div_done;

logic [KEY_SIZE_BITS-1:0]    mes_multiplier, mes_multiplicant, step_multiplier, step_multiplicant;
logic [INTERMEDIATE_RES-1:0] mes_product, step_product;

logic [KEY_SIZE_BITS-1:0]    mes_modulo_result, step_modulo_result;
logic [KEY_SIZE_BITS-1:0]    output_msg;
logic                        idle_flag, save_msg;


DW_mult_seq #(  KEY_SIZE_BITS, KEY_SIZE_BITS, DIV_MULT_SIGN, DIV_CYC_COUNT, DIV_RST_MODE, DIV_INPUT_MODE, DIV_OUTPUT_MODE, DIV_EARLY_START)
message_multiplier (.clk(clk), .rst_n(rst_n), .start(start_mult[0]), .hold('0),
    .a(mes_multiplier), .b(mes_multiplicant),
    .complete(mult_done[0]), .product(mes_product) 
);

DW_mult_seq #(  KEY_SIZE_BITS, KEY_SIZE_BITS, DIV_MULT_SIGN, DIV_CYC_COUNT, DIV_RST_MODE, DIV_INPUT_MODE, DIV_OUTPUT_MODE, DIV_EARLY_START)
step_result_multiplier (.clk(clk), .rst_n(rst_n), .start(start_mult[1]), .hold('0),
    .a(step_multiplier), .b(step_multiplicant),
    .complete(mult_done[1]), .product(step_product) 
);


DW_div_seq #(INTERMEDIATE_RES, KEY_SIZE_BITS, DIV_MULT_SIGN, DIV_CYC_COUNT, DIV_RST_MODE, DIV_INPUT_MODE, DIV_OUTPUT_MODE, DIV_EARLY_START)
message_divider (.clk(clk), .rst_n(rst_n), .start(start_div[0]), .hold('0),
    .a(mes_product), .b(saved_mod_n),
    .complete(div_done[0]), .remainder(mes_modulo_result) 
);

DW_div_seq #(INTERMEDIATE_RES, KEY_SIZE_BITS, DIV_MULT_SIGN, DIV_CYC_COUNT, DIV_RST_MODE, DIV_INPUT_MODE, DIV_OUTPUT_MODE, DIV_EARLY_START)
step_result_divider (.clk(clk), .rst_n(rst_n), .start(start_div[1]), .hold('0),
    .a(step_product), .b(saved_mod_n),
    .complete(div_done[1]), .remainder(step_modulo_result) 
);


always_ff @ (posedge clk, negedge rst_n ) begin: RSA_FSM
    if(~rst_n) 
        curr_state <= idle_data;
    else begin
        curr_state <= next_state;
    end
end

always_ff @ (posedge clk, negedge rst_n) begin : RSA_VAR_UPDATER
    if(~rst_n) begin
        step_result  <= '0;
        bin_mes      <= '0;
        stored_key   <= '0;
        saved_mod_n  <= '0;
        o_output_msg <= '0;
        o_idle_flag  <= '0;
    end else begin
        saved_mod_n  <= (update_mod_n ? mod_n : saved_mod_n);
        step_result  <= (update_step ? next_step_result : step_result);
        bin_mes      <= ((update_mes || update_msg_blk) ? next_bin_mes : bin_mes);
        stored_key   <= ((update_key || update_key_from_mem) ? next_stored_key : stored_key);
        o_idle_flag  <= idle_flag;
        o_output_msg <= (save_msg ? output_msg : o_output_msg);
    end
end

always_comb begin :  RSA_FSM_LOGIC
    next_state        = curr_state;

    output_msg        = 'x;
    idle_flag         = '0;
    save_msg          = '0;

    update_step       = '0;
    update_mes        = '0;
    update_key        = '0;

    next_stored_key   = 'x;
    next_bin_mes      = 'x;
    next_step_result  = 'x;

    start_mult[1:0]   = '0;
    mes_multiplier    = 'x;
    mes_multiplicant  = 'x;
    step_multiplier   = 'x;
    step_multiplicant = 'x;

    start_div[1:0]    = '0;

    unique case(curr_state)
        idle_data: begin
            next_stored_key = RSA_key;
            next_bin_mes    = msg_block;
            
            if(RSA_start && saved_mod_n != '0) begin // start multiplication if we have incoming data
                next_step_result = 1'b1;
                update_step      = '1;
                start_mult[0]    = '1; //start multiplication

                next_state       = mult_wait;
                mes_multiplicant = bin_mes;
                mes_multiplier   = bin_mes;

                if(stored_key[0]) begin //if the first bit in the key is 1 then we do (inter * mes)
                    start_mult[1]     = '1;
                    step_multiplicant = next_step_result;
                    step_multiplier   = bin_mes;
                end

            end else begin
                idle_flag = 1'b1; //if idling set idel to reset flag to signal wether we are accepting new inputs
            end
        end
        loop_data: begin
            if(stored_key == '0) begin
                idle_flag     = '1;
                save_msg      = '1;
                output_msg    =  step_result;
                next_state    =  idle_data;
            end else begin
                next_state       = mult_wait;

                start_mult[0]    = '1; //start multiplication
                mes_multiplicant = bin_mes;
                mes_multiplier   = bin_mes;
                
                if(stored_key[0]) begin //if the first bit in the key is 1 then we do (inter * mes)
                    start_mult[1]     = '1;
                    step_multiplicant = step_result;
                    step_multiplier   = bin_mes;
                end
            end
        end
        mult_wait: begin
            if((mult_done[0] && mult_done[1]) || (mult_done[0] && ~stored_key[0])) begin //once both mult are done or our first is complete + our key 1st bit is 0
                start_div[0] = '1;
                start_div[1] = stored_key[0];
                next_state   = div_wait;
            end 
        end
        div_wait: begin
            if((div_done[0] && div_done[1]) || (div_done[0] && ~stored_key[0])) begin //once both divs complete or our first div is done + we don't have a 2nd div
                next_state      =  loop_data;

                update_mes      = '1;
                next_bin_mes    = mes_modulo_result;

                update_key      = '1;
                next_stored_key = stored_key >> 1;

                if(stored_key[0])begin
                    update_step       = '1;
                    next_step_result  = step_modulo_result;
                end 
            end
        end
        default: begin
            next_state = idle_data; //if we ever enter default then return tto idle
        end
    endcase
end

// localparam CALCULATE_DELAY = (KEY_SIZE_BITS*(DIV_CYC_COUNT*2 + 1)) + 1;


// property VERIFY_RSA_OP;
//     @(posedge clk) $rose(idle_flag) |-> ##(1) o_output_msg == (($past(bin_mes, CALCULATE_DELAY)**$past(stored_key, CALCULATE_DELAY)) % saved_mod_n);
// endproperty

// VERIFY_RSA_RESULT : assert property(VERIFY_RSA_OP) 
//     $display("[INFO] %m Property VERIFY_RSA_RESULT passed at t = %0t", $time);
// else  
//     $display("[ERROR] %m Property VERIFY_RSA_RESULT failed at t = %0t", $time);

endmodule