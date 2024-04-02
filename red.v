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

module red_16bit(A, B, Output);
    input [15:0] A;
    input [15:0] B;
    output [15:0] Output;

    wire [8:0] sumab; 
    wire [8:0] sumcd;
    wire [8:0] result;

    wire [3:0] sum_ab_low, sum_ab_high, sum_cd_low, sum_cd_high;
    wire cout_ab_low, cout_ab_high, cout_cd_low, cout_cd_high;

    cla_4bit cla_ab_low(.A(A[3:0]), .B(B[3:0]), .cin(1'b0), .Sum(sum_ab_low), .cout(cout_ab_low));

    cla_4bit cla_ab_high(.A(A[7:4]), .B(B[7:4]), .cin(cout_ab_low), .Sum(sum_ab_high), .cout(cout_ab_high));

    assign sumab = {cout_ab_high, sum_ab_high, sum_ab_low}; 

    cla_4bit cla_cd_low(.A(A[11:8]), .B(B[11:8]), .cin(1'b0), .Sum(sum_cd_low), .cout(cout_cd_low));

    cla_4bit cla_cd_high(.A(A[15:12]), .B(B[15:12]), .cin(cout_cd_low), .Sum(sum_cd_high), .cout(cout_cd_high));

    assign sumcd = {cout_cd_high, sum_cd_high, sum_cd_low};

    wire [3:0] sum_final_low, sum_final_mid, sum_final_high;
    wire cout_final_low, cout_final_mid;

    cla_4bit cla_final_low(.A(sumab[3:0]), .B(sumcd[3:0]), .cin(1'b0), .Sum(sum_final_low), .cout(cout_final_low));

    cla_4bit cla_final_mid(.A(sumab[7:4]), .B(sumcd[7:4]), .cin(cout_final_low), .Sum(sum_final_mid), .cout(cout_final_mid));

    cla_4bit cla_final_high(.A({4{sumab[8]}}), .B({4{sumcd[8]}}), .cin(cout_final_mid),.Sum({sum_final_high[2:0], result[8]}), .cout());

    assign result[7:4] = sum_final_mid;
    assign result[3:0] = sum_final_low;

    assign Output = {result[8], result[7:0]};

endmodule