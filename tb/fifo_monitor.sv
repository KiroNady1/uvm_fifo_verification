`ifndef FIFO_MONITOR_SV
`define FIFO_MONITOR_SV

class fifo_monitor #(int DATA_WIDTH = 8) extends uvm_monitor;

    `uvm_component_param_utils(fifo_monitor #(DATA_WIDTH))

    uvm_analysis_port #(fifo_item #(DATA_WIDTH)) ap;
    virtual fifo_if #(DATA_WIDTH) vif;

    function new(string name = "fifo_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON_VIF_ERR", "vif not found in config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        bit pending_op = 1'b0;
        fifo_item #(DATA_WIDTH) active_item;

        forever begin
            @(vif.mon_cb);

            if (vif.rst_n) begin
                // If there was a pending command from the previous cycle,
                // sample the resulting outputs and broadcast it.
                if (pending_op) begin
                    active_item.rd_data      = vif.mon_cb.rd_data;
                    active_item.full         = vif.mon_cb.full;
                    active_item.empty        = vif.mon_cb.empty;
                    active_item.almost_full  = vif.mon_cb.almost_full;
                    active_item.almost_empty = vif.mon_cb.almost_empty;
                    active_item.overflow     = vif.mon_cb.overflow;
                    active_item.underflow    = vif.mon_cb.underflow;
                    
                    ap.write(active_item);
                    pending_op = 1'b0;
                end

                // Sample current command inputs
                if (vif.mon_cb.wr_en || vif.mon_cb.rd_en || vif.mon_cb.overflow || vif.mon_cb.underflow) begin
                    active_item = fifo_item #(DATA_WIDTH)::type_id::create("active_item");
                    active_item.wr_en   = vif.mon_cb.wr_en;
                    active_item.rd_en   = vif.mon_cb.rd_en;
                    active_item.wr_data = vif.mon_cb.wr_data;
                    
                    pending_op = 1'b1;
                end
            end else begin
                pending_op = 1'b0;
            end
        end
    endtask

endclass

`endif // FIFO_MONITOR_SV
