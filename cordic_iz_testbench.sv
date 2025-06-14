// Code your testbench here
// or browse Examples
module izhikevich_neuron_tb;
    reg clk = 0;
    reg rst = 1;
    reg signed [15:0] I;
    wire spike;

    izhikevich_neuron uut (
        .clk(clk),
        .rst(rst),
        .I(I),
        .spike(spike)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        $dumpfile("izhikevich_neuron.vcd");
        $dumpvars(0, izhikevich_neuron_tb);

        #20 rst = 0;
        I = 16'd5120; // ~20.0 in Q8.8

        repeat (2000) @(posedge clk);

        $finish;
    end
endmodule
