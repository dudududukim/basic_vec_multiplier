/*
TOP tpu module composition

1) Unified Buffer
2) Weight FIFO
3) Systolic Array
4) Controllers

*/

module TOP_vec_mul_synthesis #(
    parameter ADDRESSSIZE = 10,
    parameter WORDSIZE = 64,
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 8,
    parameter MATRIX_SIZE = 8,
    parameter PARTIAL_SUM_BW = 20,
    parameter DATA_BW = 8,
    parameter WORDSIZE_Result = 20*8

) (
    input wire clk, rstn, start, weight_reload,
    output wire end_,

    // UB pins
    input wire sram_write_enable,
    input wire [ADDRESSSIZE-1:0] sram_address,
    input wire [WORDSIZE-1:0] sram_data_in,
    // output wire [WORDSIZE-1:0] sram_data_out,

    // FIFO pins
    input wire fifo_write_enable,
    input wire fifo_read_enable,
    input wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in,
    // output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out,
    output wire fifo_empty,
    output wire fifo_full,

    //
    input wire valid_address, addr_ctrl_en,
    // input wire [ADDRESSSIZE-1 : 0] sram_result_address,
    output wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out
);

    wire signed [PARTIAL_SUM_BW*NUM_PE_ROWS-1:0] result;
    wire [3:0] count4;                  // for sensing the results timing
    wire [6*8 -1 : 0] w_addr;
    wire [DATA_BW*MATRIX_SIZE -1 : 0] data_set;
    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] result_sync, result_sync_rev;
    wire [4:0] state_count;             // checking the cycle

    SRAM_UnifiedBuffer #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE)
    ) SRAM_UB (
        .clk(clk),
        .write_enable(sram_write_enable),
        .address(sram_address),
        .data_in(sram_data_in),
        .data_out(sram_data_out)
    );

    SRAM_Results #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE_Result)
    ) SRAM_Results(
        .clk(clk),
        .write_enable(sram_write_enable),
        .address(sram_address),
        .data_in(result),
        .data_out(sram_result_data_out)
    );

    Weight_FIFO #(
        .WEIGHT_BW(WEIGHT_BW),
        .FIFO_DEPTH(4)
    ) weight_fifo (
        .clk(clk),
        .rstn(rstn),
        .write_enable(fifo_write_enable),
        .read_enable(fifo_read_enable),
        .data_in(fifo_data_in),
        .data_out(fifo_data_out),
        .empty(fifo_empty),
        .full(fifo_full)
    );

    vec_mul_1x64 #(
        .WEIGHT_BW(WEIGHT_BW),
        .DATA_BW(DATA_BW),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) vec_mul_1x64 (
        .clk(clk),
        .rstn(rstn),
        .weight_reload(weight_reload),
        .data_in(sram_data_out),
        .weights(fifo_data_out),
        .data_out(result)
    );
    
endmodule