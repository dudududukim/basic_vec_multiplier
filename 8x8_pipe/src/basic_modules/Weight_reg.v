// weight_reg.v
module weight_reg #(
    parameter WEIGHT_BW = 8
) (
    input wire clk,
    input wire rstn,
    input wire weight_reload,
    input wire signed [WEIGHT_BW-1:0] weight_in,
    output reg signed [WEIGHT_BW-1:0] weight_out
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn)
            weight_out <= 0;
        else if (weight_reload)
            weight_out <= weight_in;
    end
endmodule
