`timescale 1ns/1ps

interface fifo_if #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16,
    parameter int ALMOST_FULL_THRESHOLD  = 12,
    parameter int ALMOST_EMPTY_THRESHOLD = 4
)(
    input logic clk
);

    logic                  rst_n;
    logic                  wr_en;
    logic                  rd_en;
    logic [DATA_WIDTH-1:0] wr_data;
    logic [DATA_WIDTH-1:0] rd_data;

    logic                  full;
    logic                  empty;
    logic                  almost_full;
    logic                  almost_empty;
    logic                  overflow;
    logic                  underflow;

    clocking drv_cb @(posedge clk);
        default input #1ns output #1ns;
        output wr_en;
        output rd_en;
        output wr_data;
        input  full;
        input  empty;
        input  almost_full;
        input  almost_empty;
        input  overflow;
        input  underflow;
        input  rd_data;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1ns;
        input wr_en;
        input rd_en;
        input wr_data;
        input rd_data;
        input full;
        input empty;
        input almost_full;
        input almost_empty;
        input overflow;
        input underflow;
    endclocking

    modport driver_mp  (clocking drv_cb, input clk, input rst_n);
    modport monitor_mp (clocking mon_cb, input clk, input rst_n);

    assert_reset_state: assert property (
        @(posedge clk) !rst_n |-> (empty === 1'b1 && full === 1'b0 && almost_empty === 1'b1 && almost_full === 1'b0 && overflow === 1'b0 && underflow === 1'b0)
    ) else $error("SVA_ERROR: Reset state invalid");

    assert_overflow: assert property (
        @(posedge clk) disable iff (!rst_n) (full && wr_en && !rd_en) |=> overflow
    ) else $error("SVA_ERROR: Write on full did not assert overflow");

    assert_underflow: assert property (
        @(posedge clk) disable iff (!rst_n) (empty && rd_en) |=> underflow
    ) else $error("SVA_ERROR: Read on empty did not assert underflow");

    assert_overflow_cause: assert property (
        @(posedge clk) disable iff (!rst_n) overflow |-> $past(full && wr_en && !rd_en)
    ) else $error("SVA_ERROR: Spurious overflow detected");

    assert_underflow_cause: assert property (
        @(posedge clk) disable iff (!rst_n) underflow |-> $past(empty && rd_en)
    ) else $error("SVA_ERROR: Spurious underflow detected");

    assert_full_empty_mutex: assert property (
        @(posedge clk) disable iff (!rst_n) !(full && empty)
    ) else $error("SVA_ERROR: FIFO cannot be full and empty simultaneously");

    assert_rd_data_stable: assert property (
        @(posedge clk) disable iff (!rst_n) (!rd_en || (rd_en && empty)) |=> $stable(rd_data)
    ) else $error("SVA_ERROR: rd_data changed without a valid read operation");

endinterface
