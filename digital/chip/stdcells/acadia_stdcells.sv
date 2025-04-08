////////////////////////////////////////////////////////////////////////////////
// Wrappers around ARM's 65nm Standard Cells for Simulation and Synthesis
////////////////////////////////////////////////////////////////////////////////

/**
 * Double flip-flop synchronizer for asynchronous clock domain crossing
 *
 * Cell: DFFYQX2
 */
module acadia_double_sync (
  input  logic clk,
  input  logic d,
  output logic q
);

logic conn;
DFFYQX2MA10TR F1 (.Q(conn), .D(d), .CK(clk));
DFFYQX2MA10TR F2 (.Q(q), .D(conn), .CK(clk));

endmodule : acadia_double_sync

/**
 * Triple flip-flop synchronizer for asynchronous clock domain crossing
 *
 * Cell: DFFYQX2
 */
module acadia_triple_sync (
  input  logic clk,
  input  logic d,
  output logic q
);

logic conn1, conn2;
DFFYQX2MA10TR F1 (.Q(conn1), .D(d), .CK(clk));
DFFYQX2MA10TR F2 (.Q(conn2), .D(conn1), .CK(clk));
DFFYQX2MA10TR F3 (.Q(q), .D(conn2), .CK(clk));

endmodule : acadia_triple_sync

/**
 * Reset synchronizer for asynchronous reset assertion and synchronous 
 * reset deassertion. The polarity assume an active-high asynchronous reset.
 * Typical implementations will tie d input to high (1'b1).
 * 
 * Cells: DFFRPQX3MA10TR, INVX16MA10TR
 */
module acadia_rst_sync (
  input  logic clk,
  input  logic rst,
  input  logic d,
  output logic q
);

logic conn1, conn2;
DFFRPQX3MA10TR F1 (.Q(conn1), .D(d), .CK(clk), .R(rst));
DFFRPQX3MA10TR F2 (.Q(conn2), .D(conn1), .CK(clk), .R(rst));
INVX16MA10TR   INV1 (.Y(q), .A(conn2));

endmodule : acadia_rst_sync

/**
 * Clock gate with active high enable and scan enable signals. If enable is high
 * during the low level of the clock, the clock gate will enable during the high
 * level of the clock. The active high scanmode enable essentially disabled the
 * clock gate. This can be tied to 1'b0 to remove the feature. 
 * 
 * Cell: PREICGX4BA10TR
 */
module acadia_clk_gate (
  input  logic clk,
  input  logic en,
  input  logic scanmode,
  output logic gclk
);

PREICGX4BA10TR CG1 (.ECK(gclk), .E(en), .SE(scanmode), .CK(clk));

endmodule : acadia_clk_gate

/**
 * The clock mux implementation garuntees no clock glitches on the mux output.
 * This cell is ideally used to switch between driving logic between two 
 * different clocks. Note that the cell adds a two cycle latency on the
 * selected clock domain from the synchronizers.
 * 
 * Reference Design: https://vlsitutorials.com/wp-content/uploads/2020/01/glitch-free-clock-mux-double-sync.png
 * 
 * Cell: DFFRPQX2MA10TR
 */
module acadia_clk_mux (
  input  logic clk1,
  input  logic clk2,
  input  logic rst,
  input  logic sel,
  output logic out_clk
);
logic sync1, sync2;
logic conn1, conn2, conn3, conn4;

assign conn1 = ~sel & ~sync2;
assign conn2 = sel & ~sync1;

DFFRPQX2MA10TR FF1(.Q(sync1), .D(conn1), .CK(clk1), .R(rst));
DFFRPQX2MA10TR FF2(.Q(sync2), .D(conn2), .CK(clk2), .R(rst));

assign conn3 = clk1 & sync1;

assign conn4 = clk2 & sync2;

assign out_clk = conn3 | conn4;

endmodule : acadia_clk_mux

/**
 * The cell implements a glitch-free 2 to 1 multiplexer design for 
 * asynchronous signal multiplexing that is prone to glitches.
 */
module acadia_async_mux (
  input  logic a,
  input  logic b,
  input  logic s,
  output logic o
);

  logic conn1;
  assign conn1 = ~s & a;

  logic conn2;
  assign conn2 = s & b;

  logic conn3;
  assign conn3 = a & b;

  assign o = conn1 | conn2 | conn3;

endmodule : acadia_async_mux

/**
 * The cell wraps a positive-edge triggered flop with scan input and scan enable
 * using an asynchronous active-high reset. This should be used to mark the
 * start and end of the scan chain for behavior purposes.
 *
 * Cell: SDFFRPQX2MA10TR
 */
module acadia_scan_cell (
  input  logic clk,
  input  logic rst,
  input  logic d,
  output logic q,
  input  logic scan_in,
  input  logic scan_en
);

  SDFFRPQX2MA10TR SFF1 (
    .Q(q), 
    .D(d), 
    .SI(scan_in), 
    .SE(scan_en), 
    .CK(clk), 
    .R(rst)
  );

endmodule : acadia_scan_cell