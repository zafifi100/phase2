module full_adder_1bit (A, B, cin, cout, sum);

  input A, B, cin;
  output sum, cout;

  assign sum = A ^ B ^ cin;
  assign cout = (A & B) | ((A & cin) | (B & cin));

endmodule
