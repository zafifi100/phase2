module hazarddetection (
    input ID_EX_MemRead,  IF_ID_MemWrite,
    input [3:0] ID_EX_RegisterRd, IF_ID_RegisterRs, IF_ID_RegisterRt,
    output enable_stall
);

assign enable_stall = (ID_EX_MemRead & (ID_EX_RegisterRd != 4'b0000) & ((ID_EX_RegisterRd == IF_ID_RegisterRs) | ((ID_EX_RegisterRd == IF_ID_RegisterRt) & (~IF_ID_MemWrite))));

endmodule