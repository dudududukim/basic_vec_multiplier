module PE_1row #(
    parameter DATA_BW = 8,
    parameter WEIGHT_BW = 8,
    parameter MATRIX_SIZE = 8,
    parameter PARTIAL_SUM_BW = 20,
    parameter PARTIAL_MUL_BW = 16
) (
    input wire clk, rstn, weight_reload,
    input wire signed [DATA_BW*MATRIX_SIZE -1 : 0] data_in,            // [64-1:0]
    input wire signed [WEIGHT_BW*MATRIX_SIZE -1 : 0] weights,          // [64-1:0]
    output wire signed [PARTIAL_SUM_BW -1 : 0] data_out
);
    wire signed [PARTIAL_MUL_BW*MATRIX_SIZE -1 : 0] mul_out_tmp, q_mul_out_tmp;

    genvar i;

    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : pe_vec_array
            PE_vec #(
                .WEIGHT_BW(WEIGHT_BW),
                .DATA_BW(DATA_BW),
                .PARTIAL_MUL_BW(PARTIAL_MUL_BW)
            ) PE_vec_inst (
                .clk(clk),
                .rstn(rstn),
                .weight_reload(weight_reload),
                .weight(weights[i*WEIGHT_BW +: WEIGHT_BW]),
                .data_in(data_in[i*DATA_BW +: DATA_BW]),
                .partial_mul(mul_out_tmp[i*PARTIAL_MUL_BW +: PARTIAL_MUL_BW])
            );
        end
    endgenerate

    (* DONT_TOUCH = "TRUE" *) dff #(
        .WIDTH(PARTIAL_MUL_BW*MATRIX_SIZE)
    ) partial_mul_dff(
        .clk(clk), .rstn(rstn),
        .d(mul_out_tmp), .q(q_mul_out_tmp)
    );

    adder_tree #(
        .PARTIAL_SUM_BW(PARTIAL_SUM_BW),
        .PARTIAL_MUL_BW(PARTIAL_MUL_BW),
        .MATRIX_SIZE(MATRIX_SIZE)
    ) adder_tree_inst (
        .clk(clk), .rstn(rstn),
        .data_in_flat(q_mul_out_tmp),
        .final_sum(data_out)
    );

endmodule