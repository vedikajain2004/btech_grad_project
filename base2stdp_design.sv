// Code your design here
module base2_pstdp (
    input wire clk,
    input wire rst,
    input wire pre_spike,
    input wire post_spike,
    output reg [15:0] weight
);
    parameter A_plus  = 16'd32;    // LTP step
    parameter A_minus = 16'd32;    // LTD step
    parameter TAU_SHIFT = 2;       // Shift = 2 -> divide delta_t by 4

    reg [15:0] pre_time = 0;
    reg [15:0] post_time = 0;
    reg [15:0] delta_t;
    reg [15:0] delta_w;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pre_time  <= 0;
            post_time <= 0;
            weight    <= 16'd100; // Initial weight
        end else begin
            // Time counters increment every clock
            pre_time  <= pre_time + 1;
            post_time <= post_time + 1;

            if (pre_spike)
                pre_time <= 0;

            if (post_spike)
                post_time <= 0;

            if (pre_spike && post_time < 16'd255) begin
                // Post followed by pre → LTD
                delta_t = post_time;
                delta_w = A_minus >> (delta_t >> TAU_SHIFT);
                weight <= (weight > delta_w) ? weight - delta_w : 0;
            end else if (post_spike && pre_time < 16'd255) begin
                // Pre followed by post → LTP
                delta_t = pre_time;
                delta_w = A_plus >> (delta_t >> TAU_SHIFT);
                weight <= (weight + delta_w < 16'hFFFF) ? weight + delta_w : 16'hFFFF;
            end
        end
    end
endmodule