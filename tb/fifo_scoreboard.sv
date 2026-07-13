`ifndef FIFO_SCOREBOARD_SV
`define FIFO_SCOREBOARD_SV

class fifo_scoreboard #(
    int DATA_WIDTH = 8,
    int DEPTH      = 16,
    int ALMOST_FULL_THRESHOLD  = 12,
    int ALMOST_EMPTY_THRESHOLD = 4
) extends uvm_scoreboard;

    `uvm_component_param_utils(fifo_scoreboard #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD))

    uvm_analysis_imp #(fifo_item #(DATA_WIDTH), fifo_scoreboard #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD)) ap_imp;

    virtual fifo_if #(DATA_WIDTH) vif;

    bit [DATA_WIDTH-1:0] ref_queue[$];

    int match_count    = 0;
    int mismatch_count = 0;

    function new(string name = "fifo_scoreboard", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("SB_VIF_ERR", "vif not found in config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge vif.rst_n);
            ref_queue.delete();
        end
    endtask

    virtual function void write(fifo_item #(DATA_WIDTH) item);
        bit expected_full;
        bit expected_empty;
        bit expected_almost_full;
        bit expected_almost_empty;

        case ({item.wr_en, item.rd_en})
            2'b10: begin
                if (ref_queue.size() == DEPTH) begin
                    if (item.overflow !== 1'b1) begin
                        `uvm_error("SB_ERR", "Expected overflow on write to full FIFO")
                        mismatch_count++;
                    end
                end else begin
                    ref_queue.push_back(item.wr_data);
                end
            end

            2'b01: begin
                if (ref_queue.size() == 0) begin
                    if (item.underflow !== 1'b1) begin
                        `uvm_error("SB_ERR", "Expected underflow on read from empty FIFO")
                        mismatch_count++;
                    end
                end else begin
                    bit [DATA_WIDTH-1:0] expected_data = ref_queue.pop_front();
                    if (item.rd_data !== expected_data) begin
                        `uvm_error("SB_DATA_MISMATCH", $sformatf("Mismatch: expected=0x%0h, got=0x%0h", expected_data, item.rd_data))
                        mismatch_count++;
                    end else begin
                        match_count++;
                    end
                end
            end

            2'b11: begin
                if (ref_queue.size() == 0) begin
                    if (item.underflow !== 1'b1) begin
                        `uvm_error("SB_ERR", "Expected underflow on read from empty FIFO")
                        mismatch_count++;
                    end
                    ref_queue.push_back(item.wr_data);
                end else if (ref_queue.size() == DEPTH) begin
                    bit [DATA_WIDTH-1:0] expected_data = ref_queue.pop_front();
                    if (item.rd_data !== expected_data) begin
                        `uvm_error("SB_DATA_MISMATCH", $sformatf("Mismatch: expected=0x%0h, got=0x%0h", expected_data, item.rd_data))
                        mismatch_count++;
                    end else begin
                        match_count++;
                    end
                    ref_queue.push_back(item.wr_data);
                end else begin
                    bit [DATA_WIDTH-1:0] expected_data = ref_queue.pop_front();
                    if (item.rd_data !== expected_data) begin
                        `uvm_error("SB_DATA_MISMATCH", $sformatf("Mismatch: expected=0x%0h, got=0x%0h", expected_data, item.rd_data))
                        mismatch_count++;
                    end else begin
                        match_count++;
                    end
                    ref_queue.push_back(item.wr_data);
                end
            end
            default: ;
        endcase

        expected_empty        = (ref_queue.size() == 0);
        expected_full         = (ref_queue.size() == DEPTH);
        expected_almost_full  = (ref_queue.size() >= ALMOST_FULL_THRESHOLD);
        expected_almost_empty = (ref_queue.size() <= ALMOST_EMPTY_THRESHOLD);

        if (item.empty !== expected_empty) begin
            `uvm_error("SB_FLAG_ERR", $sformatf("empty mismatch: expected=%b, got=%b", expected_empty, item.empty))
            mismatch_count++;
        end
        if (item.full !== expected_full) begin
            `uvm_error("SB_FLAG_ERR", $sformatf("full mismatch: expected=%b, got=%b", expected_full, item.full))
            mismatch_count++;
        end
        if (item.almost_full !== expected_almost_full) begin
            `uvm_error("SB_FLAG_ERR", $sformatf("almost_full mismatch: expected=%b, got=%b", expected_almost_full, item.almost_full))
            mismatch_count++;
        end
        if (item.almost_empty !== expected_almost_empty) begin
            `uvm_error("SB_FLAG_ERR", $sformatf("almost_empty mismatch: expected=%b, got=%b", expected_almost_empty, item.almost_empty))
            mismatch_count++;
        end
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_REPORT", $sformatf("Matches: %0d, Mismatches: %0d, Queue size: %0d", match_count, mismatch_count, ref_queue.size()), UVM_LOW)
        if (mismatch_count > 0) begin
            `uvm_error("SB_RESULT", "Test FAILED with errors in scoreboard.")
        end else begin
            `uvm_info("SB_RESULT", "Test PASSED.", UVM_LOW)
        end
    endfunction

endclass

`endif // FIFO_SCOREBOARD_SV
