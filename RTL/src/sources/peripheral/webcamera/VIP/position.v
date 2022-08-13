module position(
	input 				clk ,
	input 				rst_n,
	input				ie,			//输入使能
	input 		[10:0]	hcnt,
	input 		[9:0]	vcnt,
	input				idat,		//输入二值像素
	
	output reg 			oe,			//输出标志
	output 				vidon,		//输出方框有效信号
	output reg [10:0]	x_max,		//方框位置
	output reg [10:0]	x_min,
	output reg [9:0]	y_max,
	output reg [9:0]	y_min
);
reg [9:0] y_maxr;
reg [10:0] x_maxr;
reg [9:0] y_minr;
reg [10:0] x_minr;

 (* KEEP="TRUE"*)  wire comp_tc ;//获得前一帧数据
assign comp_tc = (hcnt==10 && vcnt ==1)? 1'b1:1'b0;
 (* KEEP="TRUE"*)  wire comp_tc2 ;//开始本帧数据
assign comp_tc2 = (hcnt==20 && vcnt ==1)? 1'b1:1'b0;
//assign comp_tc = (vga_vsync)? 1'b1:1'b0;
/******************************************************/
(*KEEP="TRUE"*) wire debug_xmaxr ;
assign debug_xmaxr = ((idat)&&(x_maxr <= hcnt)&& ie)? 1'b1 :1'b0 ;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		x_maxr <= 0 ;
	else if(comp_tc2)
		x_maxr <= 0 ;
	else if(ie && hcnt < 800 && hcnt >168 && vcnt < 500 && vcnt > 50)begin
		if((idat)&&(x_maxr <= hcnt))
			x_maxr <= hcnt ;	
	end
end
(*KEEP="TRUE"*) wire [10:0] x_maxr2 =  x_maxr ;
(*KEEP="TRUE"*) wire debug_xminr ;
assign debug_xminr = ((idat)&&(x_minr >= hcnt)&& ie)? 1'b1 :1'b0 ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		x_minr <= 800 ;
	else if(comp_tc2)
		x_minr <= 800 ;
	else if(ie && hcnt < 800 && hcnt >168 && vcnt < 500 && vcnt > 50)begin
		if((idat)&&(x_minr >= hcnt))
			x_minr <= hcnt ;	
	end
end
(*KEEP="TRUE"*) wire [10:0] x_minr2 =  x_minr ;
/*****************************************/
(*KEEP="TRUE"*) wire debug_ymaxr ;
assign debug_ymaxr = ((idat)&&(y_maxr <= vcnt)&& ie)? 1'b1 :1'b0 ;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		y_maxr <= 0 ;
	else if(comp_tc2)
		y_maxr <= 0 ;
	else if(ie && hcnt < 800 && hcnt >168 && vcnt < 500 && vcnt > 50)begin
		if((idat)&&(y_maxr <= vcnt))
			y_maxr <= vcnt ;
		else
			y_maxr <= y_maxr ;		
	end
end
(*KEEP="TRUE"*) wire [9:0] y_maxr2 =  y_maxr ;
(*KEEP="TRUE"*) wire debug_yminr ;
assign debug_yminr = ((idat)&&(y_minr >= vcnt)&& ie)? 1'b1 :1'b0 ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		y_minr <= 600 ;
	else if(comp_tc2)
		y_minr <= 600 ;
	else if(ie && hcnt < 800 && hcnt >168 && vcnt < 500 && vcnt > 50)begin
		if((idat)&&(y_minr >= vcnt))
			y_minr <= vcnt ;	
	end
end

 (*KEEP="TRUE"*) wire [9:0] y_minr2 =  y_minr ;
/*****************************************/
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)begin
		x_max <= 0 ;
		y_max <= 0 ;
		x_min <= 0 ;
		y_min <= 0 ;
	end
	else if(comp_tc)begin
		x_max <= x_maxr ;
		x_min <= x_minr ;
		y_max <= y_maxr ;
		y_min <= y_minr ;
	end
	else begin
		x_max <= x_max ;
		x_min <= x_min ;
		y_max <= y_max ;
		y_min <= y_min ;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		oe <= 0 ;
	else
		oe <= comp_tc ;
end

//30为修正量 精确值为算法花费的总周期数
assign vidon = ((vcnt == y_min | vcnt == y_max)&&(((hcnt > x_min - 30))&((hcnt < x_max - 30))) ||
					 (hcnt == (x_min - 30) | hcnt == (x_max - 30))&&((vcnt > y_min)&(vcnt < y_max)) )? 1'b0 : 1'b1;
				 


endmodule
