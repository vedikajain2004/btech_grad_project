// Code your testbench here
// Testbench
module base2_pstdp_tb;
    reg clk = 0;
    reg rst = 1;
    reg pre_spike = 0;
    reg post_spike = 0;
    wire [15:0] weight;

    base2_pstdp uut (
        .clk(clk),
        .rst(rst),
        .pre_spike(pre_spike),
        .post_spike(post_spike),
        .weight(weight)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        $dumpfile("base2_pstdp.vcd");
        $dumpvars(0, base2_pstdp_tb);

        // Reset pulse
        #20 rst = 0;

        // Test LTP: Pre then Post
        #30 pre_spike = 1; #10 pre_spike = 0;
        #70 post_spike = 1; #10 post_spike = 0;

        // Wait
        #200;

        // Test LTD: Post then Pre
        #30 post_spike = 1; #10 post_spike = 0;
        #50 pre_spike = 1; #10 pre_spike = 0;

        // Wait more
        #200;

        $finish;
    end
endmodule