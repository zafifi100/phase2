//4bit CLA
module cla_4bit(A, B, cin, Sum, cout);
    input [3:0] A;
    input [3:0] B;
    input cin;
    output [3:0] Sum;
    output cout;

    wire [3:0] p, g;
    wire [4:0] c;

    assign p = A ^ B;
    assign g = A & B;

    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & c[1]);
    assign c[3] = g[2] | (p[2] & c[2]);
    assign c[4] = g[3] | (p[3] & c[3]);

    assign Sum = p ^ c[3:0];
    assign cout = c[4];
endmodule

//16bit CLA
module cla_16bit(A, B, cin, sub, Sum, Ovfl);
    input [15:0] A;
    input [15:0] B;
    input cin;
    input sub;
    output [15:0] Sum;
    output Ovfl;

    wire carry_in;
    wire [15:0] B_input;
    wire [3:0] carry_out;
    wire [15:0] tmp_sum;
    wire ovfl_add;
    wire ovfl_sub;
    
    assign carry_in = sub;
    assign B_input = (sub) ? ~B : B;
    
    cla_4bit cla0(.A(A[3:0]), .B(B_input[3:0]), .cin(carry_in), .Sum(tmp_sum[3:0]), .cout(carry_out[0]));
    cla_4bit cla1(.A(A[7:4]), .B(B_input[7:4]), .cin(carry_out[0]), .Sum(tmp_sum[7:4]), .cout(carry_out[1]));
    cla_4bit cla2(.A(A[11:8]), .B(B_input[11:8]), .cin(carry_out[1]), .Sum(tmp_sum[11:8]), .cout(carry_out[2]));
    cla_4bit cla3(.A(A[15:12]), .B(B_input[15:12]), .cin(carry_out[2]), .Sum(tmp_sum[15:12]), .cout(carry_out[3]));

    assign ovfl_add = (~A[15] & ~B_input[15] & tmp_sum[15]);
    assign ovfl_sub = (A[15] & B_input[15] & ~tmp_sum[15]);
    assign Ovfl = ovfl_add | ovfl_sub;
    assign Sum = (ovfl_add) ? 16'h7fff : (ovfl_sub) ? 16'h8000 : tmp_sum;
endmodule
