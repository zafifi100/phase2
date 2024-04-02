
module sll (Shift_Out, Shift_In, Shift_Val);
  input [15:0] Shift_In;  
  input [3:0] Shift_Val;          
  output [15:0] Shift_Out; 

  //hold temporarily shifted register 
  wire[15:0] shft_1, shft_2, shft_3;

  assign shft_1 = (Shift_Val[0]) ? {Shift_In[14:0], {1{1'b0}}} : Shift_In[15:0];
  assign shft_2 = (Shift_Val[1]) ? {shft_1[13:0], {2{1'b0}}} : shft_1[15:0];
  assign shft_3 = (Shift_Val[2]) ? {shft_2[11:0], {4{1'b0}}} : shft_2[15:0];
  assign Shift_Out = (Shift_Val[3]) ? {shft_3[7:0], {8{1'b0}}} : shft_3[15:0];

endmodule

