`ifndef FIFO_DRIVER_SV
`define FIFO_DRIVER_SV

class fifo_driver #(int DATA_WIDTH = 8) extends uvm_driver #(fifo_item #(DATA_WIDTH));

    `uvm_component_param_utils(fifo_driver #(DATA_WIDTH))

    virtual fifo_if #(DATA_WIDTH) vif;

    function new(string name = "fifo_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV_VIF_ERR", "vif not found in config_db")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);
        vif.drv_cb.wr_en   <= 1'b0;
        vif.drv_cb.rd_en   <= 1'b0;
        vif.drv_cb.wr_data <= '0;

        @(posedge vif.rst_n);

        forever begin
            fifo_item #(DATA_WIDTH) req;
            seq_item_port.get_next_item(req);

            @(vif.drv_cb);

            if (!vif.rst_n) begin
                vif.drv_cb.wr_en   <= 1'b0;
                vif.drv_cb.rd_en   <= 1'b0;
                vif.drv_cb.wr_data <= '0;
                @(posedge vif.rst_n);
            end else begin
                vif.drv_cb.wr_en   <= req.wr_en;
                vif.drv_cb.rd_en   <= req.rd_en;
                vif.drv_cb.wr_data <= req.wr_data;
            end

            seq_item_port.item_done();
        end
    endtask

endclass

`endif // FIFO_DRIVER_SV
