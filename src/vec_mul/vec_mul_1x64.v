module moduleName #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_SUM_BW = 20
) (
    input wire [DATA_BW-1 : 0] data_in,
    output wire [PARTIAL_SUM_BW-1 : 0] data_out
);
    
endmodule