`timescale 1ns / 1ps
/**
 * Copyright (C) 2025  AGH University of Science and Technology
 * 2025  AGH University of Science and Technology
 * MTM UEC2
 * Author: Unknown
 *
 * Description:
 * PS2 Receiver for keyboard.
 * Source:
 * https://digilent.com/reference/programmable-logic/basys-3/demos/keyboard
 */


module ps2_receiver(
    input clk,
    input kclk,
    input kdata,
    output reg [15:0] keycode,
    output reg oflag
    );
    
    wire kclkf, kdataf;
    reg [7:0]datacur=0;
    reg [7:0]dataprev=0;
    reg [3:0]cnt=0;
    reg flag=0;
    
debouncer #(
    .COUNT_MAX(19),
    .COUNT_WIDTH(5)
) db_clk(
    .clk(clk),
    .I(kclk),
    .O(kclkf)
);
debouncer #(
   .COUNT_MAX(19),
   .COUNT_WIDTH(5)
) db_data(
    .clk(clk),
    .I(kdata),
    .O(kdataf)
);
    
always@(negedge(kclkf))begin
    case(cnt)
    4'd0:;//Start bit
    4'd1:datacur[0]<=kdataf;
    4'd2:datacur[1]<=kdataf;
    4'd3:datacur[2]<=kdataf;
    4'd4:datacur[3]<=kdataf;
    4'd5:datacur[4]<=kdataf;
    4'd6:datacur[5]<=kdataf;
    4'd7:datacur[6]<=kdataf;
    4'd8:datacur[7]<=kdataf;
    4'd9:flag<=1'b1;
    4'd10:flag<=1'b0;
    
    endcase
        if(cnt<=9) cnt<=cnt+1;
        else if(cnt==10) cnt<=0;
end

reg pflag;
always@(posedge clk) begin
    if (flag == 1'b1 && pflag == 1'b0) begin
        keycode <= {dataprev, datacur};
        oflag <= 1'b1;
        dataprev <= datacur;
    end else
        oflag <= 'b0;
    pflag <= flag;
end

endmodule
