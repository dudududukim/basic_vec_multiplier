module counter_5bit_en (
    input wire clk, rstn, enable,
    output reg [4:0] count
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 5'b1_1111; // Reset 시 count를 0으로 초기화
        end
        else if (!enable) begin
            count <= 5'b1_1111; // Enable이 꺼져있을 때 count를 0으로 유지
        end
        else begin
            count <= count + 1'b1; // Enable이 켜져있을 때만 카운트를 증가
        end
    end
endmodule
