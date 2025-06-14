// Code your design here
// CORDIC-based Izhikevich Neuron Implementation in Verilog

module izhikevich_neuron #(parameter DT = 16'h0100) // dt = 1.0 in Q8.8
(
    input wire clk,
    input wire rst,
    input wire [15:0] I,          // Input current (Q8.8)
    output reg spike              // Spike flag
);

    // Internal state variables (Q8.8)
    reg signed [15:0] v, u;

    // Parameters for regular spiking neuron
    wire signed [15:0] a = 16'h0051;   // a = 0.02
    wire signed [15:0] b = 16'h0200;   // b = 0.2
    wire signed [15:0] c = -16'sd16640; // c = -65 -> -65 * 256
    wire signed [15:0] d = 16'h0800;   // d = 8

    wire signed [15:0] v_sq;
    wire signed [15:0] term1, term2, term3, dv_raw, du_raw;
    wire signed [15:0] bv;

    // Threshold
    localparam signed [15:0] V_THRESH = 16'd7680; // 30 * 256

    // Squaring v using multiplier (CORDIC-based or simplified)
    cordic_mult sq_v (.x(v), .y(v), .out(v_sq));

    // term1 = 0.04 * v^2
    cordic_mult mul_004 (.x(16'h0148), .y(v_sq), .out(term1));
    // term2 = 5 * v
    cordic_mult mul_5v (.x(16'h0500), .y(v), .out(term2));
    // term3 = 140
    assign term3 = 16'd35840; // 140 * 256

    assign dv_raw = term1 + term2 + term3 - u + I;

    cordic_mult mul_bv (.x(b), .y(v), .out(bv));
    assign du_raw = (bv - u);

    wire signed [15:0] du;
    cordic_mult mul_a (.x(a), .y(du_raw), .out(du));

    // Euler integration step
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            v <= c;
            u <= 0;
            spike <= 0;
        end else begin
            if (v >= V_THRESH) begin
                v <= c;
                u <= u + d;
                spike <= 1;
            end else begin
                v <= v + ((dv_raw * DT) >>> 8); // Q8.8 multiply with dt, shift to maintain scale
                u <= u + ((du * DT) >>> 8);
                spike <= 0;
            end
        end
    end

endmodule

// Simplified CORDIC Multiplier Module (Shift-Add for Q8.8)
module cordic_mult(
    input signed [15:0] x,
    input signed [15:0] y,
    output signed [15:0] out
);
    wire signed [31:0] temp;
    assign temp = x * y;
    assign out = temp[23:8]; // Q8.8 result
endmodule