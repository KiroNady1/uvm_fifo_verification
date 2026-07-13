`ifndef FIFO_TEST_LIB_SV
`define FIFO_TEST_LIB_SV

class fifo_base_test #(
    int DATA_WIDTH = 8,
    int DEPTH      = 16,
    int ALMOST_FULL_THRESHOLD  = 12,
    int ALMOST_EMPTY_THRESHOLD = 4
) extends uvm_test;

    `uvm_component_param_utils(fifo_base_test #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD))

    fifo_env #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD) env;
    virtual fifo_if #(DATA_WIDTH) vif;

    function new(string name = "fifo_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(this, "", "vif", vif)) begin
            `uvm_fatal("TEST_NO_VIF", "vif not found in config_db")
        end

        uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::set(this, "*env*", "vif", vif);

        env = fifo_env#(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD)::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

endclass

class fifo_rand_test extends fifo_base_test #(8, 16, 12, 4);

    `uvm_component_utils(fifo_rand_test)

    function new(string name = "fifo_rand_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_rand_wr_rd_seq #(8) seq;
        phase.raise_objection(this);
        
        seq = fifo_rand_wr_rd_seq#(8)::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #100ns;
        phase.drop_objection(this);
    endtask

endclass

class fifo_simultaneous_test extends fifo_base_test #(8, 16, 12, 4);

    `uvm_component_utils(fifo_simultaneous_test)

    function new(string name = "fifo_simultaneous_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_simultaneous_seq #(8) seq;
        phase.raise_objection(this);
        
        seq = fifo_simultaneous_seq#(8)::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #100ns;
        phase.drop_objection(this);
    endtask

endclass

class fifo_burst_test extends fifo_base_test #(8, 16, 12, 4);

    `uvm_component_utils(fifo_burst_test)

    function new(string name = "fifo_burst_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_burst_write_seq #(8, 16) wr_seq;
        fifo_burst_read_seq  #(8, 16) rd_seq;
        
        phase.raise_objection(this);
        
        wr_seq = fifo_burst_write_seq#(8, 16)::type_id::create("wr_seq");
        wr_seq.start(env.agent.sequencer);
        #50ns;

        rd_seq = fifo_burst_read_seq#(8, 16)::type_id::create("rd_seq");
        rd_seq.start(env.agent.sequencer);

        #100ns;
        phase.drop_objection(this);
    endtask

endclass

class fifo_reset_test extends fifo_base_test #(8, 16, 12, 4);

    `uvm_component_utils(fifo_reset_test)

    function new(string name = "fifo_reset_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        fifo_reset_mid_seq #(8) seq;
        phase.raise_objection(this);
        
        seq = fifo_reset_mid_seq#(8)::type_id::create("seq");
        seq.start(env.agent.sequencer);
        
        #100ns;
        phase.drop_objection(this);
    endtask

endclass

`endif // FIFO_TEST_LIB_SV
