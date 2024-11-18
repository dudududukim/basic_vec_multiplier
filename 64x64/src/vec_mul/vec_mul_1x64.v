module vec_mul_1x64 #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_SUM_BW = 20,
    parameter MATRIX_SIZE = 8,
    parameter NUM_PE_ROWS = 8
) (
    input wire clk, rstn, weight_reload,
    input wire [DATA_BW*MATRIX_SIZE -1 : 0] data_in,                            // input 1 row
    input wire [WEIGHT_BW*MATRIX_SIZE*MATRIX_SIZE-1 : 0] weights,               // full 64 weights
    output wire [PARTIAL_SUM_BW*MATRIX_SIZE -1 : 0] data_out                    // output 1 row
);

    genvar  i, j;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : pe_row
            wire [MATRIX_SIZE*WEIGHT_BW-1 : 0] selected_weights;

            for (j = 0; j < MATRIX_SIZE; j = j + 1) begin : select_weights_gen
                assign selected_weights[(MATRIX_SIZE-j-1)*WEIGHT_BW +: WEIGHT_BW] =
                    weights[(MATRIX_SIZE*NUM_PE_ROWS - MATRIX_SIZE*j - i -1)*WEIGHT_BW +: WEIGHT_BW];
            end

            PE_1row #(
                .DATA_BW(DATA_BW),
                .WEIGHT_BW(WEIGHT_BW),
                .MATRIX_SIZE(MATRIX_SIZE),
                .PARTIAL_SUM_BW(PARTIAL_SUM_BW)
            ) PE_1row_inst (
                .clk(clk),
                .rstn(rstn),
                .weight_reload(weight_reload),
                .data_in(data_in),                                         // same inputs for all the PE_1row
                .weights(selected_weights),
                .data_out(data_out[(MATRIX_SIZE-1-i)*PARTIAL_SUM_BW +: PARTIAL_SUM_BW])
            );

        end
    endgenerate


endmodule