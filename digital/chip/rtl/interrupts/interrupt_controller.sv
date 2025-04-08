module interrupt_controller #(
 //# of intterupt connections
    parameter  INTERRUPT_LINES = 16,
    parameter  INTERRUPT_BITS  = $clog2(INTERRUPT_LINES) 
)(// Interrupt priority given by ID with 0 at highest and 15 lowest
  input  logic                        clk,
  input  logic                        rst,

  //EXTERNAL DEVICE SIDE CONNECTIONS
  input  logic [INTERRUPT_LINES-1:0] interrupt_id,
  output logic                       in_service,

  //MEM_BUS SIDE CONNECTIONS
  //read/write signals for intterupt mask
  input  logic                       read_mask,
  input  logic                       update_int_mask,
  input  logic [INTERRUPT_LINES-1:0] wdata_int_mask,
  output logic [INTERRUPT_LINES-1:0] int_mask_val,

  //read/write signals for interrupt vector table
  input  logic                      read_vec_table,
  input  logic [INTERRUPT_BITS-1:0] table_entry_id,
  input  logic [31:0]               wdata_vec_table,
  input  logic                      update_int_vec_table,
  output logic [31:0]               int_vec_table_pc,

  //CORE SIDE CONNECTIONS
  //service/signal interrupt signals
  input  logic                      interrupt_serviced,
  output logic [31:0]               interrupt_PC,
  output logic                      signal_interrupt,
  input  logic                      int_accepted 
);

  //FSM names
  enum logic [1:0]  {idle_data, servicing_int, wait_for_accept, finish_int} curr_state, next_state;

  //storage for out interrupt vector table, mask, and latches to store interrupts
  logic      [31:0]                Interrupt_Vector_Table [INTERRUPT_LINES];
  logic      [INTERRUPT_LINES-1:0] interrupt_mask;
  logic      [INTERRUPT_LINES-1:0] latch_interrupt, detect_edge_trigger;

  // signals to start a new interrupt and which id
  logic       [INTERRUPT_BITS-1:0] signal_int_id, signal_new_int_id;
  logic                            latch_id, remove_int;

  //simple next_state FSM
  always_ff @ (posedge clk, posedge rst) begin: STATE_FSM
    if(rst) begin
        curr_state <= idle_data;
    end else begin
        curr_state <= next_state;
    end
  end

  // 1 Synchronous Write Port
  always_ff @(posedge clk, posedge rst) begin : STORE_INTERRUPTS
    if (rst) begin
      latch_interrupt     <= '0;
      detect_edge_trigger <= '0;
      signal_int_id       <= '0;
    end else begin
      detect_edge_trigger <= interrupt_id;
      signal_int_id       <= (latch_id ? signal_new_int_id : signal_int_id);

      if(remove_int) begin //remove our interrupt once its been handled
        latch_interrupt[signal_int_id] <= 1'b0;
      end

      for (int i = 0; i < INTERRUPT_LINES; i++) begin
        //if any of our interrupt ID's have a positive edge then register it
        //mkare sure to only register if mask is set
        if (interrupt_id[i] && ~detect_edge_trigger[i] && interrupt_mask[i]) begin 
          latch_interrupt[i] <= 1'b1;
        end 
      end

    end
  end

  // 1 Synchronous Write Port
  always_ff @(posedge clk, posedge rst) begin : INT_VECTOR_TABLE
    if (rst) begin

      for (int i = 0; i < INTERRUPT_LINES; i++) begin
        Interrupt_Vector_Table[i] <= 32'b0;
      end

      interrupt_mask <= '0;
    end else begin

      //if mem_bus signals update, then populate entry data
      if(update_int_vec_table) begin
        Interrupt_Vector_Table[table_entry_id] <= wdata_vec_table;
      end

      //if mem bus signals update, then update mask
      if(update_int_mask) begin
        interrupt_mask <= wdata_int_mask;
      end

    end
  end

  //when mem_bus sends read signals, send over the mask or vector entry
  always_comb begin
    int_mask_val = (read_mask ? interrupt_mask : '0);
    int_vec_table_pc = (read_vec_table ? Interrupt_Vector_Table[table_entry_id] : '0);

  end

  always_comb begin
    next_state        = curr_state;

    // signals to start a new interrupt handling
    interrupt_PC      = 'x;
    signal_new_int_id = 'x;
    latch_id          = '0;
    signal_interrupt  = '0;

    //signal to denote interrupt being serviced
    in_service        = '0;

    //signal to clear out interrupt from latch
    remove_int        = '0;

    unique case(curr_state)
      idle_data: begin

          //loop through all our lines to check if any devices signal an interrupt
        for (int unsigned i = 0; i < INTERRUPT_LINES; i++) begin 
          //on the first interrupt signaled high, break and signal a new interrupt
          if(latch_interrupt[i] && interrupt_mask[i]) begin
            latch_id          = '1;
            signal_new_int_id = i;
            next_state        = servicing_int;
            break;
          end

        end
      end
      servicing_int: begin 
        next_state       = wait_for_accept;
        signal_interrupt = 1'b1;
        interrupt_PC     = Interrupt_Vector_Table[signal_int_id];
        in_service       = 1'b1;

      end
      wait_for_accept: begin
        interrupt_PC     = Interrupt_Vector_Table[signal_int_id];
        in_service       = 1'b1;
        unique case(int_accepted)
          default: next_state = wait_for_accept;
          1:       next_state = finish_int;
        endcase

      end
      finish_int: begin
        unique case(interrupt_serviced)
          default: begin
            in_service = 1'b1;
          end
          1: begin
             next_state = idle_data;
             remove_int = 1'b1;
          end
        endcase

      end
      default: begin
        next_state = idle_data;
      end
    endcase
  end
 

  `ifdef ACADIA_ASSERTIONS
   //Int_Vec_Table assertion verification
  property verify_vector;
  //when update_int_vec_table high, check if entry was property registered
  @(posedge clk) update_int_vec_table |-> ##1 (Interrupt_Vector_Table[$past(table_entry_id, 1)] == $past(wdata_vec_table, 1));
  endproperty

  Vector_Assert: assert property (verify_vector) $display("[INFO] %m Property verify_vector paseed at t = %0t", $time );
    else $error("[ERROR] %m Property verify_vector failed at t = %0t", $time);


  //Int_MASK assertion verification
  property verify_mask;
  @(posedge clk) //when update_int_vec_table high, check if entry was property registered
    update_int_mask |-> ##1 interrupt_mask == $past(wdata_int_mask, 1);
  endproperty

  Mask_Assert: assert property (verify_mask) $display("[INFO] %m Property verify_vector paseed at t = %0t", $time );
    else $error("[ERROR] %m Property verify_vector failed at t = %0t", $time);

  //Signal New Int assertion verification
  property verify_new_int;
  @(posedge clk) //`
    latch_id |-> ##1 interrupt_PC == Interrupt_Vector_Table[$past(signal_new_int_id, 1)];
  endproperty

  New_INT_Assert: assert property (verify_new_int) $display("[INFO] %m Property verify_new_int paseed at t = %0t", $time );
    else $error("[ERROR] %m Property verify_new_int failed at t = %0t", $time);
  `endif

endmodule
