module vec_mul_1x64 #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_SUM_BW = 20,
    parameter MATRIX_SIZE = 8
) (
    input wire clk, rstn, weight_reload,
    input wire [DATA_BW*MATRIX_SIZE -1 : 0] data_in,                            // input 1 row
    input wire [WEIGHT_BW*MATRIX_SIZE*MATRIX_SIZE-1 : 0] weights,               // full 64 weights
    output wire [PARTIAL_SUM_BW*MATRIX_SIZE -1 : 0] data_out                    // output 1 row
);

    genvar  i;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : pe_row

            wire [MATRIX_SIZE*WEIGHT_BW-1 : 0] selected_weights = {      // wanted to make it with only parameters, but it takes inreadable
                    weights[(64 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(56 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(48 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(40 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(32 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(24 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(16 - i) * WEIGHT_BW-1 -: WEIGHT_BW],
                    weights[(8 - i) * WEIGHT_BW-1 -: WEIGHT_BW]
                };

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
                .data_out(data_out[(7-i)*PARTIAL_SUM_BW +: PARTIAL_SUM_BW])
            );

        end
    endgenerate


endmodule