module fre_meter(
        input   wire        CLK_50M        ,
		input   wire        reset_n        ,
	    input   wire        clk            ,                    //GMII接收时钟
	    input      [ 1:0]   Freq_meter_sta ,
		output reg [31:0]   speed_latch
);
reg  [31:0]  speed;

always@(posedge clk or posedge (Freq_meter_sta[1]&(~Freq_meter_sta[0])))begin
	if(Freq_meter_sta[1]&(~Freq_meter_sta[0]))begin
		speed <= 32'd0;
	end
	else begin
		if(Freq_meter_sta == 2'd0 ) speed <= speed +1'b1;
	end
end

always@(posedge CLK_50M or negedge reset_n)begin
	if(~reset_n)begin
		speed_latch <= 32'd0;
	end
	else begin
		if(Freq_meter_sta == 2'd1) speed_latch <= speed ;
	end
end

endmodule