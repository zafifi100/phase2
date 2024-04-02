
module sra (Shift_Out, Shift_In, Shift_Val);
  input [15:0] Shift_In;  
  input [3:0] Shift_Val;                
  output [15:0] Shift_Out; 

  //hold temporarily shifted register 
  wire[15:0] shft_1, shft_2, shft_3;

  assign shft_1 = (Shift_Val[0]) ? {{1{Shift_In[15]}}, Shift_In[15:1]} : Shift_In[15:0];
  assign shft_2 = (Shift_Val[1]) ? {{2{Shift_In[15]}}, shft_1[15:2]} : shft_1[15:0];
  assign shft_3 = (Shift_Val[2]) ? {{4{Shift_In[15]}}, shft_2[15:4]} : shft_2[15:0];
  assign Shift_Out = (Shift_Val[3]) ? {{8{Shift_In[15]}}, shft_3[15:8]} : shft_3[15:0];

endmodule

