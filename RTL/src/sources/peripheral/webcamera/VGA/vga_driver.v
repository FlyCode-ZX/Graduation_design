module	vga_driver(
	input				clk		 	,		//640*480	25Mhz
	input				rst_n		,

	input		[15:0]	img_data	,
	output	reg			img_data_req,
	
	output  reg         read_req,
	input               read_req_ack,
	input wire   [15:0]   Cursor_x,
	input wire   [15:0]   Cursor_y,
	output  wire [15:0]   X      ,
	output  wire [15:0]	  Y      ,
	output				data_vaild	,
	output	reg	[15:0]	hcnt ,
	output	reg	[15:0]	vcnt ,	
	output	reg			hsync		, 
	output	reg			vsync		,
	output	reg	[7:0]	vga_data,
	output	reg	[7:0]  	vga_data2
);

localparam	H_SYNC	=	96		,
			H_BACK	=	48		,
			H_DISP	= 	640		,
			H_FRONT	=	16		,
			H_TOTAL	=	800		;

localparam	V_SYNC	=	2		,
			V_BACK	=	33		,
			V_DISP	= 	480		,
			V_FRONT	=	10		,
			V_TOTAL	=	525		;	
localparam  Cursor_width  = 5;
localparam  Cursor_height = 5;
	
reg			hsync_en;
reg			vsync_en;
reg         video_hs_d0;

wire [15:0] active_x;
wire [15:0] active_y;

//--------------------------------------------------
//VGA场索引信号
//--------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		hcnt <= 'd0 ;
	else if(hcnt == H_TOTAL - 1'b1)
		hcnt <=	'd0 ;
	else
		hcnt <= hcnt + 1'b1 ;
end

//vcnt
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)
		vcnt <= 'd0 ;
	else if((vcnt == V_TOTAL - 1'b1) && (hcnt == H_TOTAL -1'b1) )
		vcnt <=	'd0 ;
	else  if(hcnt == H_TOTAL - 1'b1)
		vcnt <= vcnt + 1'b1 ;
	else
		vcnt <= vcnt ;
end

assign   active_x = data_vaild?(hcnt - (H_SYNC[15:0] + H_BACK[15:0])):0;
assign   active_y = data_vaild?(vcnt - (V_SYNC[15:0] + V_BACK[15:0])):0;
assign   X = active_x;
assign   Y = active_y;

//--------------------------------------------------
//VGA同步信号
//--------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(!rst_n)hsync <= 'd0 ;
	else begin
		if(hcnt < H_SYNC) hsync <= 'd0 ;
		else              hsync <= 1'b1 ;
	end
end
always@(posedge clk  or negedge rst_n)begin
	if(!rst_n) vsync <= 'd0 ;
	else begin 
		if(vcnt < V_SYNC) vsync <= 'd0 ;
		else              vsync <= 1'b1 ;
	end
end
//--------------------------------------------------
//显示区域有效
//--------------------------------------------------
always@(posedge clk  or negedge rst_n)begin
	if(!rst_n)
		hsync_en <= 'd0 ;
	else if(hcnt>=(H_SYNC  + H_BACK  - 1'b1)&&
			hcnt<= (H_TOTAL - H_FRONT - 1'b1 ))
		hsync_en <= 'd1 ;
	else
		hsync_en <= 'd0 ;
end
always@(posedge clk  or negedge rst_n)begin
	if(!rst_n)
		vsync_en <= 'd0 ;
	else if(vcnt>=(V_SYNC  + V_BACK  )&&
			vcnt<=(V_TOTAL - V_FRONT - 1'b1))
		vsync_en <= 'd1 ;
	else 
		vsync_en <= 'd0 ;
end

//data_vaild
assign data_vaild =  hsync_en && vsync_en ;

//--------------------------------------------------
//帧同步
//--------------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0)video_hs_d0 <= 1'b0;
	else             video_hs_d0 <= vsync;	
end
always@(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0)
		read_req <= 1'b0;
	else if(vsync & ~video_hs_d0) //vertical synchronization edge (the rising or falling edges are OK)
		read_req <= 1'b1;
	else if(read_req_ack)
		read_req <= 1'b0;
end

//--------------------------------------------------
//读FIFO使能
//--------------------------------------------------
always@(posedge clk  or negedge rst_n)
begin
	if(!rst_n)
		img_data_req  <= 'd0 ;
	else if(  (hcnt>=(H_SYNC  + H_BACK  - 3)&&
			   hcnt<(H_TOTAL  - H_FRONT - 3))&&
			  (vcnt>=(V_SYNC  + V_BACK )&&
			   vcnt<=(V_TOTAL  - V_FRONT - 1'b1)))
		img_data_req <= 1'b1 ;
	else
		img_data_req <= 'd0 ;
end
//-----------------------------------------------
//光标显示
//-----------------------------------------------
always@(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0)begin
		vga_data  <= 8'd0;
		vga_data2 <= 8'd0;
	end	  
	else begin
		if(data_vaild)begin
			if(active_x >= Cursor_x && active_y>=Cursor_y  &&
			   active_x <= Cursor_x+Cursor_width           &&
			   active_y <= Cursor_y+Cursor_height      )begin
			   
				vga_data   <= 255;
				vga_data2  <= 255;
			end
			else begin
				vga_data   <= img_data[ 7:0];
				vga_data2  <= img_data[15:8];
			end
		end 
		else begin
			vga_data   <= 0;
			vga_data2  <= 0;
		end
	end
end

endmodule 