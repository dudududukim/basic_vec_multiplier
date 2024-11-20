/*
TOP tpu module composition

1) Unified Buffer
2) Weight FIFO
3) Systolic Array
4) Controllers

*/

module TOP_vec_mul_synthesis #(
    parameter ADDRESSSIZE = 10,
    parameter ADDRESSSIZE_fifo = 2,
    parameter WORDSIZE = 8*64,
    parameter WEIGHT_BW = 8,
    parameter FIFO_DEPTH = 4,
    parameter NUM_PE_ROWS = 64,
    parameter MATRIX_SIZE = 64,
    parameter PARTIAL_SUM_BW = 24,
    parameter DATA_BW = 8,
    parameter WORDSIZE_Result = 24*64

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
    input wire [1:0] fifo_address,
    // input wire fifo_read_enable,
    // input wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_in,
    // output wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out,

    //
    input wire valid_address,
    // input wire [ADDRESSSIZE-1 : 0] sram_result_address,
    output wire done
    // output wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out
);

    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] sram_result_data_out;
    wire [WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE - 1:0] fifo_data_out;
    wire [WORDSIZE-1:0] sram_data_out;
    wire signed [PARTIAL_SUM_BW*NUM_PE_ROWS-1:0] result;
    wire [6:0] count7;                  // for sensing the results timing (3->count4)
    wire [PARTIAL_SUM_BW*MATRIX_SIZE-1 : 0] result_sync, result_sync_rev;
    wire [7:0] state_count;             // checking the cycle (3->5bit)
    wire delayed_valid_address;

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

    valid_result valid_result_sense(
        .valid_address(valid_address),
        .valid_result(valid_result)
    );

    SRAM_Results #(
        .ADDRESSSIZE(ADDRESSSIZE),
        .WORDSIZE(WORDSIZE_Result)
    ) SRAM_Results(
        .clk(clk),
        .write_enable(delayed_valid_address),
        .address({4'b0,count7[5:0]}),
        .data_in(result),
        .data_out(sram_result_data_out)
    );

    temp_end #(
        .MATRIX_SIZE(MATRIX_SIZE),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW)
    ) result_done(
        .din(sram_result_data_out),
        .dout(done)
    );

    dff #(
        .WIDTH(1)
    ) valid_dff(
        .clk(clk), .rstn(rstn),
        .d(valid_address), .q(delayed_valid_address)
    );

    counter_8bit_en counter_4bit(
        .clk(clk),
        .rstn(rstn),
        .enable(valid_address|end_),
        .count(count7)
    );

    SRAM #(                 //fifo 포기하고 걍 sram으로 해보자
        .ADDRESSSIZE(ADDRESSSIZE_fifo),
        .WORDSIZE(WEIGHT_BW * NUM_PE_ROWS * MATRIX_SIZE)
    ) weight_fifo (
        .clk(clk),
        .write_enable(fifo_write_enable),
        .address(fifo_address),
        .data_in(),
        .data_out(fifo_data_out)
    );

    vec_mul_1x64 #(
        .WEIGHT_BW(WEIGHT_BW),
        .DATA_BW(DATA_BW),
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW),
        .MATRIX_SIZE(MATRIX_SIZE),
        .NUM_PE_ROWS(NUM_PE_ROWS)
    ) vec_mul_1x64 (
        .clk(clk),
        .rstn(rstn),
        .weight_reload(weight_reload),
        .data_in(sram_data_out),
        .weights(fifo_data_out),
        .data_out(result)
    );
    
    CTRL_state_machine state_machine(
        .clk(clk), .rstn(rstn), .start(start),
        .state_count(state_count), .end_signal(end_)
    );

endmodule