`timescale 1ns/1ps

module tb_top;

    import uvm_pkg::*;
    import fifo_pkg::*;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 16;
    localparam int ALMOST_FULL_THRESHOLD  = 12;
    localparam int ALMOST_EMPTY_THRESHOLD = 4;

    logic clk;

    always #5ns clk = ~clk;

    fifo_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) vif (
        .clk(clk)
    );

    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH),
        .ALMOST_FULL_THRESHOLD(ALMOST_FULL_THRESHOLD),
        .ALMOST_EMPTY_THRESHOLD(ALMOST_EMPTY_THRESHOLD)
    ) DUT (
        .clk(vif.clk),
        .rst_n(vif.rst_n),
        .wr_en(vif.wr_en),
        .rd_en(vif.rd_en),
        .wr_data(vif.wr_data),
        .rd_data(vif.rd_data),
        .full(vif.full),
        .empty(vif.empty),
        .almost_full(vif.almost_full),
        .almost_empty(vif.almost_empty),
        .overflow(vif.overflow),
        .underflow(vif.underflow)
    );

    initial begin
        clk = 1'b0;
        vif.rst_n = 1'b0;
        #25ns;
        vif.rst_n = 1'b1;
    end

    initial begin
        uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::set(null, "*", "vif", vif);
        run_test();
    end

    initial begin
        if ($test$plusargs("dump")) begin
            $dumpfile("sim_dump.vcd");
            $dumpvars(0, tb_top);
        end
    end

endmodule
