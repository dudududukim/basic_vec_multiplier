module CTRL_state_machine (
    input wire clk,
    input wire rstn,
    input wire start,
    output reg [6:0] state_count,
    output reg end_signal
);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            state_count <= 7'b0;     // 초기화 값
            end_signal <= 1'b0;      // end_signal 초기화
        end else if (start && !end_signal) begin
            // end_signal이 Low일 때만 카운팅
            if (state_count == 7'd34) begin         // MARTIX SIZE + 2
                end_signal <= 1'b1;
                state_count <= 7'b111_1111;
            end else begin
                state_count <= state_count + 1'b1;
            end
        end
    end

endmodule
