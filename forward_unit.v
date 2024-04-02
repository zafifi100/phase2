module forwardunit (
    input EX/MEM_Regwrite, MEM/WB_Regwrite;
    input [3:0] EX/MEM_RegisterRd, ID/EX_RegisterRs,  ID/EX_RegisterRt, MEM/WB_RegisterRd, EX/MEM_RegisterRt; 
    output [1:0] ForwardA;
    output [1:0] ForwardB;
    output ForwardMem;
);

//Wires
wire EX/EX_S1, MEM/EX_S1;
wire EX/EX_S2, MEM/EX_S2;

/// EX-EX Forwarding
assign EX/EX_S1 = (EX/MEM_Regwrite) && (EX/MEM_RegisterRd != 4'b0000) && (EX/MEM_RegisterRd == ID/EX_RegisterRs);
assign EX/EX_S2 = (EX/MEM_Regwrite) && (EX/MEM_RegisterRd != 4'b0000) && (EX/MEM_RegisterRd == ID/EX_RegisterRt);

/// MEM-EX Forwarding
assign MEM/EX_S1 = (MEM/WB_Regwrite) && (EX/EX_S1 != 1'b1) && (MEM/WB_RegisterRd != 4'b0000) && (MEM/WB_RegisterRd == ID/EX_RegisterRs);
assign MEM/EX_S2 = (MEM/WB_Regwrite) && (EX/EX_S2 != 1'b1) && (MEM/WB_RegisterRd != 4'b0000) && (MEM/WB_RegisterRd == ID/EX_RegisterRt);

//Assigning ForwardA and B
assign ForwardA = (EX/EX_S1) ? 2'b10 : (MEM/EX_S1) ? 2'b01 : 2'b00;
assign ForwardB = (EX/EX_S2) ? 2'b10 : (MEM/EX_S2) ? 2'b01 : 2'b00;

/// MEM-MEM Forwarding
assign ForwardMem = MEM/WB_Regwrite && (MEM/WB_RegisterRd != 4'b0000) && (MEM/WB_RegisterRd == EX/MEM_RegisterRt);

endmodule