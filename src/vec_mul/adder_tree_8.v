module adder_tree_8 #(
    parameter PARTIAL_SUM_BW = 20,
    parameter PARTIAL_MUL_BW = 16,
    parameter MATRIX_SIZE = 8
) (
    input wire signed [PARTIAL_MUL_BW*MATRIX_SIZE-1:0] data_in_flat,
    output wire signed [PARTIAL_SUM_BW-1 :0] final_sum
);

    wire signed [PARTIAL_MUL_BW-1:0] data_in [0:MATRIX_SIZE-1];
    
    genvar i;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : unpack_data_in
            assign data_in[i] = data_in_flat[i*PARTIAL_MUL_BW +: PARTIAL_MUL_BW];
        end
    endgenerate

    wire signed [PARTIAL_SUM_BW-1 :0] sum_level1 [0:3];
    assign sum_level1[0] = data_in[0] + data_in[1];
    assign sum_level1[1] = data_in[2] + data_in[3];
    assign sum_level1[2] = data_in[4] + data_in[5];
    assign sum_level1[3] = data_in[6] + data_in[7];

    wire signed [PARTIAL_SUM_BW-1:0] sum_level2 [0:1];
    assign sum_level2[0] = sum_level1[0] + sum_level1[1];
    assign sum_level2[1] = sum_level1[2] + sum_level1[3];

    assign final_sum = sum_level2[0] + sum_level2[1];

endmodule
