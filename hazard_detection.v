module hazarddetection (
    input ID/EX_MemRead,  IF/ID_MemWrite;
    input [3:0] ID/EX_RegisterRd, IF/ID_RegisterRs, IF/ID_RegisterRt;
    output enable_stall;
);

assign enable_stall = (ID/EX_MemRead & (ID/EX_RegisterRd != 4'b0000) & ((ID/EX_RegisterRd == IF/ID_RegisterRs) | ((ID/EX_RegisterRd == IF/ID_RegisterRt) & (!IF/ID_MemWrite))));

endmodule