module ROR(
    input [15:0] rotate_val,
    input [3:0] amt,
    output reg [15:0] data_out
);

always @(*) begin
    case(amt)
        4'b0000: data_out = rotate_val;
        4'b0001: data_out = {rotate_val[0], rotate_val[15:1]};
        4'b0010: data_out = {rotate_val[1:0], rotate_val[15:2]};
        4'b0011: data_out = {rotate_val[2:0], rotate_val[15:3]};
        4'b0100: data_out = {rotate_val[3:0], rotate_val[15:4]};
        4'b0101: data_out = {rotate_val[4:0], rotate_val[15:5]};
        4'b0110: data_out = {rotate_val[5:0], rotate_val[15:6]};
        4'b0111: data_out = {rotate_val[6:0], rotate_val[15:7]};
        4'b1000: data_out = {rotate_val[7:0], rotate_val[15:8]};
        4'b1001: data_out = {rotate_val[8:0], rotate_val[15:9]};
        4'b1010: data_out = {rotate_val[9:0], rotate_val[15:10]};
        4'b1011: data_out = {rotate_val[10:0], rotate_val[15:11]};
        4'b1100: data_out = {rotate_val[11:0], rotate_val[15:12]};
        4'b1101: data_out = {rotate_val[12:0], rotate_val[15:13]};
        4'b1110: data_out = {rotate_val[13:0], rotate_val[15:14]};
        4'b1111: data_out = {rotate_val[14:0], rotate_val[15]};
        default: data_out = rotate_val; 
    endcase
end

endmodule

