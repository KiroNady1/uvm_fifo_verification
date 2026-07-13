`timescale 1ns/1ps

module fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16,
    parameter int ALMOST_FULL_THRESHOLD  = 12,
    parameter int ALMOST_EMPTY_THRESHOLD = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,
    input  logic                  wr_en,
    input  logic                  rd_en,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data,
    output logic                  full,
    output logic                  empty,
    output logic                  almost_full,
    output logic                  almost_empty,
    output logic                  overflow,
    output logic                  underflow
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] mem [DEPTH-1:0];
    logic [ADDR_WIDTH-1:0] wr_ptr;
    logic [ADDR_WIDTH-1:0] rd_ptr;
    logic [ADDR_WIDTH:0]   count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr    <= '0;
            rd_ptr    <= '0;
            count     <= '0;
            rd_data   <= '0;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end else begin
            overflow  <= 1'b0;
            underflow <= 1'b0;

            case ({wr_en, rd_en})
                2'b10: begin
                    if (full) begin
                        overflow <= 1'b1;
                    end else begin
                        mem[wr_ptr] <= wr_data;
                        wr_ptr      <= wr_ptr + 1'b1;
                        count       <= count + 1'b1;
                    end
                end

                2'b01: begin
                    if (empty) begin
                        underflow <= 1'b1;
                    end else begin
                        rd_data <= mem[rd_ptr];
                        rd_ptr  <= rd_ptr + 1'b1;
                        count   <= count - 1'b1;
                    end
                end

                2'b11: begin
                    if (empty) begin
                        mem[wr_ptr] <= wr_data;
                        wr_ptr      <= wr_ptr + 1'b1;
                        count       <= count + 1'b1;
                        underflow   <= 1'b1;
                    end else if (full) begin
                        rd_data     <= mem[rd_ptr];
                        rd_ptr      <= rd_ptr + 1'b1;
                        mem[wr_ptr] <= wr_data;
                        wr_ptr      <= wr_ptr + 1'b1;
                    end else begin
                        mem[wr_ptr] <= wr_data;
                        wr_ptr      <= wr_ptr + 1'b1;
                        rd_data     <= mem[rd_ptr];
                        rd_ptr      <= rd_ptr + 1'b1;
                    end
                end
                default: ;
            endcase
        end
    end

    assign empty        = (count == '0);
    assign full         = (count == DEPTH);
    assign almost_full  = (count >= ALMOST_FULL_THRESHOLD);
    assign almost_empty = (count <= ALMOST_EMPTY_THRESHOLD);

endmodule
