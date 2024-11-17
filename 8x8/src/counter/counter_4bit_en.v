module counter_4bit_en (
    input wire clk, rstn, enable,
    output reg [3:0] count
);
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            count <= 4'b1111; // Reset 시 count를 0으로 초기화
        end
        else if (!enable) begin
            count <= 4'b1111; // Enable이 꺼져있을 때 count를 0으로 유지
        end
        else begin
            count <= count + 1'b1; // Enable이 켜져있을 때만 카운트를 증가
        end
    end
endmodule
