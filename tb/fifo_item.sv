`ifndef FIFO_ITEM_SV
`define FIFO_ITEM_SV

class fifo_item #(int DATA_WIDTH = 8) extends uvm_sequence_item;

    `uvm_object_param_utils(fifo_item #(DATA_WIDTH))

    rand bit                  wr_en;
    rand bit                  rd_en;
    rand bit [DATA_WIDTH-1:0] wr_data;

    bit [DATA_WIDTH-1:0] rd_data;
    bit                  full;
    bit                  empty;
    bit                  almost_full;
    bit                  almost_empty;
    bit                  overflow;
    bit                  underflow;

    constraint c_wr_rd {
        wr_en dist {1'b1 := 50, 1'b0 := 50};
        rd_en dist {1'b1 := 50, 1'b0 := 50};
    }

    function new(string name = "fifo_item");
        super.new(name);
    endfunction

    virtual function string convert2string();
        return $sformatf("wr_en=%0b rd_en=%0b wr_data=0x%0h | rd_data=0x%0h full=%0b empty=%0b almost_full=%0b almost_empty=%0b overflow=%0b underflow=%0b",
            wr_en, rd_en, wr_data, rd_data, full, empty, almost_full, almost_empty, overflow, underflow);
    endfunction

endclass

`endif // FIFO_ITEM_SV
