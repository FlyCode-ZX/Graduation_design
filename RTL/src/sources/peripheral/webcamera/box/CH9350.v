module CH9350(
    //-----Sys----------
	input  wire         CLK_50M,
	input  wire         rst_n,
	input  wire         CH9350_TXD,
	output reg  [ 2:0]  Mouse_key , //左键，中键，右键，速度切换键
	output wire         L_up    ,
	output wire         L_down  ,
	output wire         M_up    ,
	output wire         M_down  ,
	output wire         R_up    ,
	output wire         R_down  ,
	output reg  [15:0]  Mouse_x,
	output reg  [15:0]  Mouse_y,
	output reg  [15:0]  Cursor_x,
	output reg  [15:0]  Cursor_y,
	output reg  [15:0]  Mouse_wheel
);
parameter     CLK_FRE = 50;//Mhz
reg    [2:0]  Mouse_key_d0;
//串口
wire       rx_data_valid;
wire[7:0]  rx_data;
wire       rx_data_ready;
wire       new_frame;
reg [3:0]  rx_index;
reg [7:0]  rx_data_d0;
reg [7:0]  rx_data_d1;
reg [7:0]  rx_data_d2;

reg  [15:0]  Mouse_x_reg;
reg  [15:0]  Mouse_y_reg;
//===================================================
//串口控制
//===================================================
assign rx_data_ready = 1'b1;//永远准备好接受数据
uart_rx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(115200)
) uart_rx_inst
(
	.clk                        (CLK_50M                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (CH9350_TXD                  )
);
always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		rx_data_d0 <= 8'd0;
		rx_data_d1 <= 8'd0;
		rx_data_d2 <= 8'd0;
	end 
	else begin
		if(rx_data_valid)begin
			rx_data_d0 <= rx_data;
			rx_data_d1 <= rx_data_d0;
		    rx_data_d2 <= rx_data_d1;
		end
		 
	end
end
assign  new_frame = (rx_data_d1==8'h57) &&  (rx_data_d0==8'hAB) &&  (rx_data==8'h88);

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		rx_index <= 4'd0;
	end 
	else begin
		if(new_frame)begin
			rx_index <= 4'd0;
		end
		else if(rx_data_valid)begin
			rx_index <= rx_index + 4'd1;
		end
	end
end

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		Mouse_x_reg <= 16'd0;
		Mouse_y_reg <= 16'd0;
	end
	else begin
		if(rx_data_valid)begin
		
			if(     rx_index==4'd3) Mouse_x_reg[ 7:0] <= rx_data;
			else if(rx_index==4'd4) Mouse_x_reg[15:8] <= rx_data;
			//-----------
			if(     rx_index==4'd5) Mouse_y_reg[ 7:0] <= rx_data;
			else if(rx_index==4'd6) Mouse_y_reg[15:8] <= rx_data;
			//------------
			if(     rx_index==4'd7 && rx_data==8'hff) Mouse_wheel <= 2'b11;
			else if(rx_index==4'd7 && rx_data==8'h01) Mouse_wheel <= 2'b01;
		end
	end
end

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		Mouse_x <= 16'd0;
		Mouse_y <= 16'd0;
	end 
	else begin
		if(rx_index == 4'd8 && rx_data_valid)begin
			Mouse_x <= Mouse_x_reg;
			Mouse_y <= Mouse_y_reg;
		end
		else begin
			Mouse_x <= 16'd0;
			Mouse_y <= 16'd0;
		end
	end
end

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		Cursor_x <= 16'd0;
	end else begin
		Cursor_x = Cursor_x + Mouse_x;
		if(Cursor_x > 16'd1024 - 1'b1) Cursor_x = 16'd1023;
		else if(Cursor_x < 0)          Cursor_x = 16'd0;
	end
end
//-----------------------------------------------------
//光标绝对坐标
//-----------------------------------------------------
always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		Cursor_y <= 16'd0;
	end else begin
		Cursor_y = Cursor_y + Mouse_y;
		if(Cursor_y > 16'd768 - 1'b1) Cursor_y = 16'd767;
		else if(Cursor_y < 0)          Cursor_y = 16'd0;
	end
end

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		//Mouse_key <= 3'd0;
	end 
	else begin
		if((rx_index == 4'd2)&&(rx_data_valid==1))begin
			Mouse_key <= {rx_data[1], //右键
		                  rx_data[2], //中键
						  rx_data[0]};//左键
		end 
		else begin
			Mouse_key <= Mouse_key ;
		end
	end
end

always@(posedge CLK_50M or negedge rst_n)begin
	if(~rst_n)begin
		 Mouse_key_d0 <= 3'd0;
	end 
	else Mouse_key_d0 <= Mouse_key;
end
//-----------------------------------------------------
//按键检测
//-----------------------------------------------------
assign L_up   = (Mouse_key_d0[0]==1'b1)&&(Mouse_key[0]==1'b0);
assign L_down = (Mouse_key_d0[0]==1'b0)&&(Mouse_key[0]==1'b1);
assign M_up   = (Mouse_key_d0[1]==1'b1)&&(Mouse_key[1]==1'b0);
assign M_down = (Mouse_key_d0[1]==1'b0)&&(Mouse_key[1]==1'b1);
assign R_up   = (Mouse_key_d0[2]==1'b1)&&(Mouse_key[2]==1'b0);
assign R_down = (Mouse_key_d0[2]==1'b0)&&(Mouse_key[2]==1'b1);


endmodule
