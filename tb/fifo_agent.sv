`ifndef FIFO_AGENT_SV
`define FIFO_AGENT_SV

class fifo_agent #(int DATA_WIDTH = 8) extends uvm_agent;

    `uvm_component_param_utils(fifo_agent #(DATA_WIDTH))

    fifo_driver    #(DATA_WIDTH) driver;
    fifo_monitor   #(DATA_WIDTH) monitor;
    fifo_sequencer #(DATA_WIDTH) sequencer;

    function new(string name = "fifo_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        monitor = fifo_monitor#(DATA_WIDTH)::type_id::create("monitor", this);

        if (get_is_active() == UVM_ACTIVE) begin
            driver    = fifo_driver#(DATA_WIDTH)::type_id::create("driver", this);
            sequencer = fifo_sequencer#(DATA_WIDTH)::type_id::create("sequencer", this);
        end
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass

`endif // FIFO_AGENT_SV
