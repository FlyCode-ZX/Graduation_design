`timescale 1ns / 1ps
/****************************************/
//      GMII UDP数据包发送模块　　　　　　　//
/****************************************/
module iprecieve(
					 input               clk,                    //GMII接收时钟
					 input      [  3:0]  datain,                  //GMII接收数据
					 input               e_rxdv,                 //GMII接收数据有效信号
					 input               clr,                    //清除/复位信号
					 output reg [ 47:0]  board_mac,               //开发板端的MAC
					 output reg [ 47:0]  pc_mac,	               //PC端的MAC 
					 output reg [ 15:0]  IP_Prtcl,                //IP 类型
					 output reg          valid_ip_P,					 
					 output reg [159:0]  IP_layer,                //IP包头数据 
					 output reg [159:0]  TCP_layer,               //TCP包头	 

					 output reg [  7:0]  data_o,                  //UDP接收的数据            
					 output reg          data_o_valid,            //UDP数据有效信号
					 output reg [ 15:0]  rx_data_length,          //接收的UDP数据包的长度
					 //output reg [  8:0]  ram_wr_addr,             //ram的写地址
					 output reg          data_receive            //接收到UDP包标志
);
//数据报解析
//中间内容
reg [  3:0]  rx_state;
reg [ 15:0] myIP_Prtcl;
reg [159:0] myIP_layer;
reg [159:0] myTCP_layer;
reg [  7:0] mydata; 
reg [  2:0] byte_counter;
reg [  7:0] state_counter;
reg [ 95:0] mymac;
reg [ 15:0] data_counter;
	 
parameter idle=4'd0,
          six_55=4'd1,
		  spd_d5=4'd2,
		  rx_mac=4'd3,
		  rx_IP_Protocol=4'd4,
		  rx_IP_layer=4'd5,
		  rx_TCP_layer=4'd6,
		  rx_data=4'd7,
		  rx_finish=4'd8;
	 
initial begin
	 rx_state<=idle;
	 data_receive<=1'b0;
end

//UDP数据接收程序	 	
always@(posedge clk or negedge clr)
	begin
	   if(!clr) begin
		    rx_state    <=idle;
			data_receive<=1'b0;
			IP_Prtcl    <= 0;
			TCP_layer   <= 0;
		end
		else
		case(rx_state)
		  idle: begin 
			valid_ip_P<=1'b0;
			byte_counter<=3'd0;
            data_counter<=16'd0;
		    mydata<=8'd0;
			state_counter<=8'd0;	
		    data_o_valid<=1'b0;           //RAM禁止写
		    data_receive<=1'b0;           //数据无效
		    if(e_rxdv==1'b1) begin        //接收数据有效为高，开始接收数据
				if(datain==4'h5) begin    //接收到第一个5,还有13个
					rx_state<=six_55;
				end
				else rx_state<=idle;
		    end
		  end		
		  six_55: begin                   //接收6个0x55//
			    if ((datain==4'h5)&&(e_rxdv==1'b1)) begin
                    if(state_counter==12) begin //最后一个前导码5
					    state_counter<=0;       //索引清零
					    rx_state<=spd_d5;
                    end
					else state_counter<=state_counter+1'b1;
				end
				else rx_state<=idle;//重新开始
		  end
		  spd_d5: begin     //接收1个0xd5
			    if(((datain==4'hd)||(datain==4'h5))&&e_rxdv==1'b1)begin//先接受5，后接受D
				    if(datain==4'hd) rx_state<=rx_mac;	
                end				  		
				else rx_state<=idle;
		  end	
		  rx_mac: begin                    //接收目标mac address和源mac address 
				if(e_rxdv==1'b1)begin
					if(state_counter<8'd23)	begin
						mymac<={mymac[91:0],datain};
						state_counter<=state_counter+1'b1;
					end
				    else begin                      //接受最后4位MAC地址  11
					    board_mac<={mymac[87:84],mymac[91:88],
						            mymac[79:76],mymac[83:80],
									mymac[71:68],mymac[75:72],
									mymac[63:60],mymac[67:64],
									mymac[55:52],mymac[59:56],
									mymac[47:44],mymac[51:48]};
					    pc_mac   <={
						            mymac[39:36],mymac[43:40],
									mymac[31:28],mymac[35:32],
									mymac[23:20],mymac[27:24],
									mymac[15:12],mymac[19:16],
									mymac[ 7: 4],mymac[11: 8],
									datain      ,mymac[ 3:0]};
					    state_counter<=8'd0;
						if((mymac[91:76]==16'h00a0)&&(mymac[75:60]==16'h5310)&&(mymac[59:44]==16'hef0c))begin   //判断目标MAC Address是否为本FPGA
						   rx_state<=rx_IP_Protocol;
                        end						   
						else
						   rx_state<=idle;
				   end
				end
				else
				   rx_state<=idle;				
		  end
		  rx_IP_Protocol: begin          //接收2个字节的IP TYPE
			    if(e_rxdv==1'b1) begin
					if(state_counter<8'd3) begin
						myIP_Prtcl<={datain,myIP_Prtcl[15:4]};
						state_counter<=state_counter+1'b1;
					end
					else begin
						IP_Prtcl<={datain,myIP_Prtcl[15:4]};
						valid_ip_P<=1'b1;
                        state_counter<=8'd0;
						rx_state<=rx_IP_layer;
					end
				end
			    else 
				    rx_state<=idle;
		  end		  
		  rx_IP_layer: begin               //接收20字节的IP包头,ip address
				valid_ip_P<=1'b0;           //信号复位
				if(e_rxdv==1'b1) begin
					if(state_counter<8'd39)	begin  //4*5*2-1
						myIP_layer<={datain,myIP_layer[159:4]};//先发送低位 
						state_counter<=state_counter+1'b1;
					end
					else begin
						IP_layer  <={datain,myIP_layer[159:4]};//信息在下一个周期提取
						state_counter<=8'd0;
						rx_state<=rx_TCP_layer;
					end
				end
				else 
				   rx_state<=idle;
			end 					
		  rx_TCP_layer: begin                //接受20字节TCP的端口号及TCP数据包长	
                //解析IP首部信息		  
		        //rx_data_length  <={IP_layer[23:16],IP_layer[31:24]}-40;//IP长度
				//-----------------------
				if(e_rxdv==1'b1) begin
					if(state_counter<8'd39)	begin
						myTCP_layer<={datain,myTCP_layer[159:4]};
						state_counter<=state_counter+1'b1;
						if(state_counter==25)begin
							rx_data_length  <={IP_layer[23:16],IP_layer[31:24]}
				                            -IP_layer[3:0]*4     //IP首部
								            -datain  [3:0]*4;    //TCP首部
						end
					end
					else begin
						TCP_layer  <={datain,myTCP_layer[159:4]};
						state_counter<=8'd0;
						if(rx_data_length==0)rx_state<=rx_finish;//没有数据字段
						else rx_state<=rx_data;
					end
				end
				else 
				   rx_state<=idle;
			end  
  		  rx_data: begin             //接收TCP的数据 
				if(e_rxdv==1'b1) begin
				   if (data_counter == (rx_data_length<<1)-1) begin //存最后的数据,真正的UDP数据需要减去8字节的UDP包头
						data_counter<=0;
						rx_state<=rx_finish;	
						data_o_valid<=1'b1;							//写RAM有效 		
						if(byte_counter==3'd1) begin
							  data_o<={datain[3:0],mydata[7:4]};     //不满32bit,补0
							  byte_counter<=0;
						end
						else if(byte_counter==3'd0) begin
							  data_o<={4'h0,datain[3:0]};              //不满32bit,补0
							  byte_counter<=0;
						end
					end
					else begin
						data_counter<=data_counter+1'b1;
						if(byte_counter<3'd1)	begin      
							mydata<={datain,mydata[7:4]};
							byte_counter<=byte_counter+1'b1;
							data_o_valid<=1'b0;            //数据不够32bit，取消写请求
						end
						else begin                          //接受32bit，地址增加
						    byte_counter<=3'd0;
							data_o_valid<=1'b1;            //接受4byes数据,写ram请求		
							data_o<={datain,mydata[7:4]};									
				        end	
			        end							 
		        end
				else rx_state<=idle;
		  end 
		  rx_finish: begin
   			    data_o_valid<=1'b0;      //取消写请求       
			    data_receive<=1'b1;      //存在一个接收周期
                rx_state<=idle;
          end		
		  default:rx_state<=idle;    
		endcase
		end
endmodule
