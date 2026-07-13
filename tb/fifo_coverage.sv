`ifndef FIFO_COVERAGE_SV
`define FIFO_COVERAGE_SV

class fifo_coverage #(
    int DATA_WIDTH = 8,
    int DEPTH      = 16,
    int ALMOST_FULL_THRESHOLD  = 12,
    int ALMOST_EMPTY_THRESHOLD = 4
) extends uvm_subscriber #(fifo_item #(DATA_WIDTH));

    `uvm_component_param_utils(fifo_coverage #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD))

    virtual fifo_if #(DATA_WIDTH) vif;

    fifo_item #(DATA_WIDTH) cov_item;
    int                     cov_count;
    int                     shadow_count = 0;

    covergroup fifo_cg;
        option.per_instance = 1;

        occupancy_cp: coverpoint cov_count {
            bins empty        = {0};
            bins almost_empty = {[1:ALMOST_EMPTY_THRESHOLD]};
            bins mid_levels   = {[ALMOST_EMPTY_THRESHOLD+1:ALMOST_FULL_THRESHOLD-1]};
            bins almost_full  = {[ALMOST_FULL_THRESHOLD:DEPTH-1]};
            bins full         = {DEPTH};
        }

        wr_en_cp: coverpoint cov_item.wr_en {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        rd_en_cp: coverpoint cov_item.rd_en {
            bins active   = {1'b1};
            bins inactive = {1'b0};
        }

        full_transition_cp: coverpoint cov_item.full {
            bins full_to_not_full = (1'b1 => 1'b0);
            bins not_full_to_full = (1'b0 => 1'b1);
        }

        empty_transition_cp: coverpoint cov_item.empty {
            bins empty_to_not_empty = (1'b1 => 1'b0);
            bins not_empty_to_empty = (1'b0 => 1'b1);
        }

        simultaneous_rw_cp: cross wr_en_cp, rd_en_cp {
            bins simultaneous_rw = binsof(wr_en_cp.active) && binsof(rd_en_cp.active);
        }

        occupancy_x_cmds: cross occupancy_cp, wr_en_cp, rd_en_cp;
    endgroup

    function new(string name = "fifo_coverage", uvm_component parent = null);
        super.new(name, parent);
        fifo_cg = new();
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("COV_VIF_ERR", "vif not found in config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(negedge vif.rst_n);
            shadow_count = 0;
        end
    endtask

    virtual function void write(fifo_item #(DATA_WIDTH) t);
        if (!vif.rst_n) begin
            shadow_count = 0;
            return;
        end

        case ({t.wr_en, t.rd_en})
            2'b10: begin
                if (shadow_count < DEPTH) begin
                    shadow_count++;
                end
            end
            2'b01: begin
                if (shadow_count > 0) begin
                    shadow_count--;
                end
            end
            2'b11: begin
                if (shadow_count == 0) begin
                    shadow_count++;
                end else if (shadow_count == DEPTH) begin
                    // Stays full
                end else begin
                    // Unchanged
                end
            end
            default: ;
        endcase

        cov_item  = t;
        cov_count = shadow_count;

        fifo_cg.sample();
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COV_REPORT", $sformatf("Coverage: %0.2f%%", fifo_cg.get_inst_coverage()), UVM_LOW)
    endfunction

endclass

`endif // FIFO_COVERAGE_SV
