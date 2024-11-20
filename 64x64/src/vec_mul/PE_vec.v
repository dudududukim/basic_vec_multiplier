/*
    This moudle performs the W11 x X11 operation.
    It returns the weight x input (partial multiplication)
*/

module PE_vec #(
    parameter WEIGHT_BW = 8,
    parameter DATA_BW = 8,
    parameter PARTIAL_MUL_BW = 16
) (
    input wire clk, rstn, weight_reload,
    input wire signed [WEIGHT_BW-1 : 0] weight,
    input wire signed [DATA_BW-1 : 0] data_in,
    
    (* use_dsp = "yes" *) output wire signed [PARTIAL_MUL_BW-1 : 0] partial_mul
);
    wire signed [WEIGHT_BW-1 : 0] PE_weight;

    (* DONT_TOUCH = "TRUE" *) weight_reg #(
        .WEIGHT_BW(WEIGHT_BW)
    ) weight_register (
        .clk(clk), .rstn(rstn), .weight_reload(weight_reload),
        .weight_in(weight), .weight_out(PE_weight)
    );

    assign partial_mul = PE_weight * data_in;

endmodule