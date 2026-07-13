`ifndef FIFO_SEQ_LIB_SV
`define FIFO_SEQ_LIB_SV

class fifo_base_seq #(int DATA_WIDTH = 8) extends uvm_sequence #(fifo_item #(DATA_WIDTH));

    `uvm_object_param_utils(fifo_base_seq #(DATA_WIDTH))

    function new(string name = "fifo_base_seq");
        super.new(name);
    endfunction

    task pre_body();
        if (starting_phase != null) begin
            starting_phase.raise_objection(this, get_type_name());
        end
    endtask

    task post_body();
        if (starting_phase != null) begin
            starting_phase.drop_objection(this, get_type_name());
        end
    endtask

endclass

class fifo_rand_wr_rd_seq #(int DATA_WIDTH = 8) extends fifo_base_seq #(DATA_WIDTH);

    `uvm_object_param_utils(fifo_rand_wr_rd_seq #(DATA_WIDTH))

    int num_transactions = 100;

    function new(string name = "fifo_rand_wr_rd_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (num_transactions) begin
            `uvm_do(req)
        end
    endtask

endclass

class fifo_simultaneous_seq #(int DATA_WIDTH = 8) extends fifo_base_seq #(DATA_WIDTH);

    `uvm_object_param_utils(fifo_simultaneous_seq #(DATA_WIDTH))

    int num_transactions = 50;

    function new(string name = "fifo_simultaneous_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (num_transactions) begin
            `uvm_do_with(req, {
                wr_en == 1'b1;
                rd_en == 1'b1;
            })
        end
    endtask

endclass

class fifo_burst_write_seq #(int DATA_WIDTH = 8, int DEPTH = 16) extends fifo_base_seq #(DATA_WIDTH);

    `uvm_object_param_utils(fifo_burst_write_seq #(DATA_WIDTH, DEPTH))

    function new(string name = "fifo_burst_write_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (DEPTH + 2) begin
            `uvm_do_with(req, {
                wr_en == 1'b1;
                rd_en == 1'b0;
            })
        end
    endtask

endclass

class fifo_burst_read_seq #(int DATA_WIDTH = 8, int DEPTH = 16) extends fifo_base_seq #(DATA_WIDTH);

    `uvm_object_param_utils(fifo_burst_read_seq #(DATA_WIDTH, DEPTH))

    function new(string name = "fifo_burst_read_seq");
        super.new(name);
    endfunction

    virtual task body();
        repeat (DEPTH + 2) begin
            `uvm_do_with(req, {
                wr_en == 1'b0;
                rd_en == 1'b1;
            })
        end
    endtask

endclass

class fifo_reset_mid_seq #(int DATA_WIDTH = 8) extends fifo_base_seq #(DATA_WIDTH);

    `uvm_object_param_utils(fifo_reset_mid_seq #(DATA_WIDTH))

    virtual fifo_if #(DATA_WIDTH) vif;

    function new(string name = "fifo_reset_mid_seq");
        super.new(name);
    endfunction

    virtual task body();
        if (!uvm_config_db#(virtual fifo_if #(DATA_WIDTH))::get(m_sequencer, "", "vif", vif)) begin
            `uvm_fatal("SEQ_VIF_ERR", "vif not found in config_db")
        end

        repeat (20) begin
            `uvm_do(req)
        end

        vif.rst_n <= 1'b0;
        #35ns;
        vif.rst_n <= 1'b1;
        #10ns;

        repeat (30) begin
            `uvm_do(req)
        end
    endtask

endclass

`endif // FIFO_SEQ_LIB_SV
