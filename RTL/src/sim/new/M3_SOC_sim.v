`timescale 1ns / 1ps       
//50M   20ns
//
module M3_SOC_sim();

reg clk;
reg rstn;

CortexM3 m3(
    .CLK50m(clk),
	.RSTn(rstn),
	.RXD(1'b0)
);

initial begin
    clk=1;
	rstn=0;
	#101
	rstn=1;
end

always begin
    #10 clk=~clk;
end 

endmodule
