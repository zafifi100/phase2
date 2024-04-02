module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
  input [15:0] Shift_In;  
  input [3:0] Shift_Val;   
  input Mode;              
  output [15:0] Shift_Out; 

  //hold temporarily shifted register 
  wire[15:0] shft_1, shft_2, shft_3;
  wire MSB;

  //determines whether Mode: SLL = 0 or SRA = 1
  assign bit_concat = (Mode) ? Shift_In[15] : 1'b0;

  assign shft_1 = (Shift_Val[0]) ? ((Mode) ? {{1{bit_concat}}, Shift_In[15:1]} : {Shift_In[14:0], {1{bit_concat}}}) : Shift_In[15:0];
  assign shft_2 = (Shift_Val[1]) ? ((Mode) ? {{2{bit_concat}}, shft_1[15:2]} : {shft_1[13:0], {2{bit_concat}}}) : shft_1[15:0];
  assign shft_3 = (Shift_Val[2]) ? ((Mode) ? {{4{bit_concat}}, shft_2[15:4]} : {shft_2[11:0], {4{bit_concat}}}) : shft_2[15:0];
  assign Shift_Out = (Shift_Val[3]) ? ((Mode) ? {{8{bit_concat}}, shft_3[15:8]} : {shft_3[7:0], {8{bit_concat}}}) : shft_3[15:0];

endmodule

