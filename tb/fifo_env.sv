`ifndef FIFO_ENV_SV
`define FIFO_ENV_SV

class fifo_env #(
    int DATA_WIDTH = 8,
    int DEPTH      = 16,
    int ALMOST_FULL_THRESHOLD  = 12,
    int ALMOST_EMPTY_THRESHOLD = 4
) extends uvm_env;

    `uvm_component_param_utils(fifo_env #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD))

    fifo_agent      #(DATA_WIDTH) agent;
    fifo_scoreboard #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD) scoreboard;
    fifo_coverage   #(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD) coverage;

    function new(string name = "fifo_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = fifo_agent#(DATA_WIDTH)::type_id::create("agent", this);
        scoreboard = fifo_scoreboard#(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD)::type_id::create("scoreboard", this);
        coverage   = fifo_coverage#(DATA_WIDTH, DEPTH, ALMOST_FULL_THRESHOLD, ALMOST_EMPTY_THRESHOLD)::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.ap.connect(scoreboard.ap_imp);
        agent.monitor.ap.connect(coverage.analysis_export);
    endfunction

endclass

`endif // FIFO_ENV_SV
