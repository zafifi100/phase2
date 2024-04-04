module forwardunit (
    input EX_MEM_Regwrite, MEM_WB_Regwrite;
    input [3:0] EX_MEM_RegisterRd, ID_EX_RegisterRs,  ID_EX_RegisterRt, MEM_WB_RegisterRd, EX_MEM_RegisterRt; 
    output [1:0] ForwardA;
    output [1:0] ForwardB;
    output ForwardMem;
);

//Wires
wire EX_EX_S1, MEM_EX_S1;
wire EX_EX_S2, MEM_EX_S2;

/// EX-EX Forwarding
assign EX_EX_S1 = (EX_MEM_Regwrite) && (EX_MEM_RegisterRd != 4'b0000) && (EX_MEM_RegisterRd == ID_EX_RegisterRs);
assign EX_EX_S2 = (EX_MEM_Regwrite) && (EX_MEM_RegisterRd != 4'b0000) && (EX_MEM_RegisterRd == ID_EX_RegisterRt);

/// MEM-EX Forwarding
assign MEM_EX_S1 = (MEM_WB_Regwrite) && (EX_EX_S1 != 1'b1) && (MEM_WB_RegisterRd != 4'b0000) && (MEM_WB_RegisterRd == ID_EX_RegisterRs);
assign MEM_EX_S2 = (MEM_WB_Regwrite) && (EX_EX_S2 != 1'b1) && (MEM_WB_RegisterRd != 4'b0000) && (MEM_WB_RegisterRd == ID_EX_RegisterRt);

//Assigning ForwardA and B
assign ForwardA = (EX_EX_S1) ? 2'b10 : (MEM_EX_S1) ? 2'b01 : 2'b00;
assign ForwardB = (EX_oEX_S2) ? 2'b10 : (MEM_EX_S2) ? 2'b01 : 2'b00;

/// MEM-MEM Forwarding
assign ForwardMem = MEM_WB_Regwrite && (MEM_WB_RegisterRd != 4'b0000) && (MEM_WB_RegisterRd == EX_MEM_RegisterRt);

endmodule