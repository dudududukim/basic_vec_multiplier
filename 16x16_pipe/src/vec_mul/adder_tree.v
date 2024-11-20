module adder_tree #(
    parameter PARTIAL_SUM_BW = 20,
    parameter PARTIAL_MUL_BW = 16,
    parameter MATRIX_SIZE = 8  // Default to 8
) (
    input wire signed [PARTIAL_MUL_BW*MATRIX_SIZE-1:0] data_in_flat,
    (* use_dsp = "yes" *) output wire signed [PARTIAL_SUM_BW-1:0] final_sum
);

    // Unpack the flattened input into an array
    wire signed [PARTIAL_MUL_BW-1:0] data_in [0:MATRIX_SIZE-1];
    genvar i;
    generate
        for (i = 0; i < MATRIX_SIZE; i = i + 1) begin : unpack_data_in
            assign data_in[i] = data_in_flat[i*PARTIAL_MUL_BW +: PARTIAL_MUL_BW];
        end
    endgenerate

    // Recursive generate block to perform summation
    function integer log2;
        input integer value;
        integer result;
        begin
            result = 0;
            while (value > 1) begin
                value = value >> 1;
                result = result + 1;
            end
            log2 = result;
        end
    endfunction

    localparam LEVELS = log2(MATRIX_SIZE);
    localparam SUM_LEVEL_SIZE = (MATRIX_SIZE >> 1);

    wire signed [PARTIAL_SUM_BW-1:0] sum_levels [0:LEVELS*SUM_LEVEL_SIZE-1];

    // Initial level
    generate
        for (i = 0; i < MATRIX_SIZE/2; i = i + 1) begin : sum_level0_gen
            assign sum_levels[i] = data_in[2*i] + data_in[2*i+1];
        end
    endgenerate

    // Higher levels
    genvar level;
    generate
        for (level = 1; level < LEVELS; level = level + 1) begin : higher_levels_gen
            for (i = 0; i < (MATRIX_SIZE >> (level + 1)); i = i + 1) begin : sum_gen
                assign sum_levels[level * SUM_LEVEL_SIZE + i] = 
                    sum_levels[(level-1) * SUM_LEVEL_SIZE + 2*i] + 
                    sum_levels[(level-1) * SUM_LEVEL_SIZE + 2*i+1];
            end
        end
    endgenerate

    // Final sum
    assign final_sum = sum_levels[(LEVELS-1) * SUM_LEVEL_SIZE];

endmodule
