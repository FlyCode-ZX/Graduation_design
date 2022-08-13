`timescale 1ns / 1ps
/****************************************/
//      GMII UDP数据包发送模块　　　　　　　//
/****************************************/

module ipsend(
				  input              clk,                   //GMII发送的时钟信号
				  input              Task,
				  //---------------------------
				  input  wire[ 15:0] Data_len,
				  input  wire[ 31:0] Src_IP,
				  input  wire[ 31:0] Des_IP,
				  //---------
				  input  wire[ 15:0] Src_port,
				  input  wire[ 15:0] Des_port,
				  input  wire[ 31:0] Seq_num,
				  input  wire[ 31:0] Ack_num,
				  input  wire[ 3 :0] Head_len,
				  input  wire        TCP_URG,
				  input  wire        TCP_ACK,
				  input  wire        TCP_PSH,
				  input  wire        TCP_RST,
				  input  wire        TCP_SYN,
				  input  wire        TCP_FIN,
				  input  wire[ 15:0] TCP_window,
				  //-----------------------------
				  output reg         txen,                  //GMII数据使能信号
				  output reg         txer,                  //GMII发送错误信号
				  output reg [3:0]   dataout,               //GMII发送数据
				  input      [31:0]  crc,                   //CRC32校验码
				  input      [31:0]  datain,                //RAM中的数据	 
				  output reg         crcen,                 //CRC32 校验使能          
				  output reg         crcre,                 //CRC32 校验清除   
				  output reg [8:0]   ram_rd_addr,           //ram读地址
				  output reg         Sender_valid
);

reg [31:0] datain_reg;
reg [31:0] ip_header [9:0];                  //数据段为1K
reg [7:0] preamble [7:0];                    //preamble
reg [7:0] mac_addr [13:0];                   //mac address
reg [4:0] i,j;
reg [31:0] check_buffer_IP;
reg [31:0] check_buffer_TCP;
reg [15:0] tx_data_counter;
reg [15:0] rd_data_counter;
reg [3:0]   tx_state;
parameter idle=4'd0,start=4'd1,make=4'd2,send55=4'd3,sendmac=4'd4,
		  sendheader=4'd5,senddata=4'd6,send_none=4'd7,sendcrc=4'd8;
		  
initial begin
	 tx_state<=idle;
	 //7个前导码55,一个帧开始符d5
	 preamble[0]<=8'h55;preamble[1]<=8'h55;preamble[2]<=8'h55;preamble[3]<=8'h55;
	 preamble[4]<=8'h55;preamble[5]<=8'h55;preamble[6]<=8'h55;preamble[7]<=8'hD5;
	 //98-40-BB-40-45-17
	 mac_addr[0]<=8'h98;mac_addr[1]<=8'h40;mac_addr[2]<=8'hBB;
	 mac_addr[3]<=8'h40;mac_addr[4]<=8'h45;mac_addr[5]<=8'h17;
	 //源MAC地址 00-0A-35-01-FE-C0
	 mac_addr[6]<=8'h00;mac_addr[ 7]<=8'h0A;mac_addr[ 8]<=8'h35;
	 mac_addr[9]<=8'h01;mac_addr[10]<=8'hFE;mac_addr[11]<=8'hC0;
	 //0800: IP包类型
	 mac_addr[12]<=8'h08;mac_addr[13]<=8'h00;
	 //ip_header[1][31:16]<=16'd0;
	 i<=0;
	 txen<=1'b0;
	 tx_data_counter<=16'h00;
	 Sender_valid   <=1'b0;
 end

//-----------------------------------------------------------
//TCP数据发送程序	 
//-----------------------------------------------------------
always@(negedge clk or posedge Task)
if(Task)begin
	tx_state<=start; 
    Sender_valid   <=1'b0;	
	//---------------
	ip_header[0][31:16]<=16'h4500;
	ip_header[0][15:0]<=Data_len+40;
	ip_header[1][31:16]<= ip_header[1][31:16]+1'b1;   //包序列号
	ip_header[1][15:0]<=16'h4000;                    //Fragment offset
	
	ip_header[2]<=32'hff060000;                      //生存时间，协议，校验和
	ip_header[3]<=Src_IP;                 //192.168.0.2源地址
	ip_header[4]<=Des_IP;                 //192.168.0.3目的地址广播地址
	
	ip_header[5]<={Src_port,Des_port};    //2个字节的源端口号和2个字节的目的端口号
	ip_header[6]<=Seq_num;                //32位序号
	ip_header[7]<=Ack_num;                //32位确认号
	ip_header[8]<={Head_len,6'd0,         //首部长度，6位保留，  
				   TCP_URG,TCP_ACK,TCP_PSH,  //URG,ACK,PSH,
				   TCP_RST,TCP_SYN,TCP_FIN,  //RST,SYN,FIN
				   TCP_window};              //16位窗口大小               
	ip_header[9]<={16'd0,16'd0};          //16位校验和，16位紧急指针  */
end
else begin
	case(tx_state)
		idle:begin    ///#0
			txer<=1'b0;
			txen<=1'b0;
			crcen<=1'b0;
			crcre<=1;
			j<=0;
			dataout<=4'h0;
			ram_rd_addr<=1;
			tx_data_counter<=0;//32'h04000000
			rd_data_counter<=0;
            Sender_valid   <=1'b1;			
		end
		start:begin        //IP header  #1
			ram_rd_addr<=ram_rd_addr+1'b1;     		
			tx_state<=make;
		end	
		make:begin            //生成包头的校验和    #2
			if(i==0) begin
				//IP首部校验和
				check_buffer_IP<=ip_header[0][15:0]+ip_header[0][31:16]
							 +ip_header[1][15:0]+ip_header[1][31:16]
							 +ip_header[2][15:0]+ip_header[2][31:16]
							 +ip_header[3][15:0]+ip_header[3][31:16]
							 +ip_header[4][15:0]+ip_header[4][31:16];
				//TCP校验和
				check_buffer_TCP<=//伪首部
								 ip_header[3][15:0]+ip_header[3][31:16]//源地址
								 +ip_header[4][15:0]+ip_header[4][31:16]//目的地址
								 +{8'd0,ip_header[2][23:16]}            //协议TCP
								 +ip_header[0][15:0]-20         //TCP首部长度+数据长度	
								 //TCP首部
								 +ip_header[5][15:0]+ip_header[5][31:16]
								 +ip_header[6][15:0]+ip_header[6][31:16]
								 +ip_header[7][15:0]+ip_header[7][31:16]
								 +ip_header[8][15:0]+ip_header[8][31:16]
								 +ip_header[9][15:0]+ip_header[9][31:16];									 
				
				if(ip_header[0][15:0]==40)begin
					i<=i+2;//无数据发送
					ram_rd_addr<=1;
				end
				else begin
				    i<=i+1'b1;
					ram_rd_addr<=ram_rd_addr+1'b1;  // datain数据输出   ram_rd_addr=3
				end
			end
			else if(i==1)begin//TCP数据部分校验和
				if(rd_data_counter==(ip_header[0][15:0]-40)>>2) begin
					i<=i+1'b1;
					ram_rd_addr<=1;//读地址复位						
				end
				else begin
					check_buffer_TCP <= check_buffer_TCP
										+datain[31:16]  //利用数据
										+datain[15: 0]; //利用数据
					ram_rd_addr<=ram_rd_addr+1'b1; 
					rd_data_counter<=rd_data_counter+1'b1; 
				end
			end
			else if(i==2) begin
				//IP首部校验和
				check_buffer_IP [15:0]<= check_buffer_IP[31:16]+ check_buffer_IP[15:0];
				check_buffer_TCP[15:0]<=check_buffer_TCP[31:16]+check_buffer_TCP[15:0];
				i<=i+1'b1;
			end
			else begin
				ip_header[2][15:0] <= ~check_buffer_IP[15:0]; //IP首部校验和赋值
				ip_header[9][31:16]<=~check_buffer_TCP[15:0]; //TCP校验赋值
				i<=0;
				tx_state<=send55;
			end
		end
		send55: begin     //#3               //发送8个IP前导码:7个55, 1个d5                    
			txen<=1'b1;                             //GMII数据发送有效
			crcre<=1'b1;                            //reset crc  
			if(i==15) begin  //7*2
				dataout<=(i[0]==0)?preamble[i[4:1]][3:0]:preamble[i[4:1]][7:4];
				i<=0;
				tx_state<=sendmac;
			end
			else begin                        
				dataout<=(i[0]==0)?preamble[i[4:1]][3:0]:preamble[i[4:1]][7:4];
				i<=i+1'b1;
			end
		end	
		sendmac: begin      //#4                     //发送目标MAC address和源MAC address和IP包类型  
			crcen<=1'b1;                            //crc校验使能，crc32数据校验从目标MAC开始		
			crcre<=1'b0;                            			
			if(i==27) begin//(12+2)*2
				dataout<=(i[0]==0)?mac_addr[i[4:1]][3:0]:mac_addr[i[4:1]][7:4];
				i<=0;
				tx_state<=sendheader;
			end
			else begin                        
				dataout<=(i[0]==0)?mac_addr[i[4:1]][3:0]:mac_addr[i[4:1]][7:4];
				i<=i+1'b1;
			end
		end
		sendheader: begin          //#5              //发送10个32bit的IP 包头
			datain_reg<=datain;                   //准备需要发送的数据	
			if(j==9) begin                       //IP首部+TCP首部   
				case(i)
					5'd0:begin
						dataout<=ip_header[j][27:24];
						i<=i+1'b1;
					end	
					5'd1:begin
						dataout<=ip_header[j][31:28];
						i<=i+1'b1;
					end	
					5'd2:begin
						dataout<=ip_header[j][19:16];
						i<=i+1'b1;
					end	
					5'd3:begin
						dataout<=ip_header[j][23:20];
						i<=i+1'b1;
					end	
					5'd4:begin
						dataout<=ip_header[j][11:8];
						i<=i+1'b1;
					end	
					5'd5:begin
						dataout<=ip_header[j][15:12];
						i<=i+1'b1;
					end	
					5'd6:begin
						dataout<=ip_header[j][3:0];
						i<=i+1'b1;
					end
					5'd7:begin
						dataout<=ip_header[j][7:4];
						i<=0;
						j<=0;
						if(ip_header[0][15:0]==40) tx_state<= send_none;//无数据发送
						else tx_state<=senddata;
					end	
					default: txer<=1'b1;							
				endcase
			end		 
			else begin                             //先发高位
				case(i)
					5'd0:begin
						dataout<=ip_header[j][27:24];
						i<=i+1'b1;
					end	
					5'd1:begin
						dataout<=ip_header[j][31:28];
						i<=i+1'b1;
					end	
					5'd2:begin
						dataout<=ip_header[j][19:16];
						i<=i+1'b1;
					end	
					5'd3:begin
						dataout<=ip_header[j][23:20];
						i<=i+1'b1;
					end	
					5'd4:begin
						dataout<=ip_header[j][11:8];
						i<=i+1'b1;
					end	
					5'd5:begin
						dataout<=ip_header[j][15:12];
						i<=i+1'b1;
					end
					5'd6:begin
						dataout<=ip_header[j][3:0];
						i<=i+1'b1;
					end
					5'd7:begin
						dataout<=ip_header[j][7:4];
						i<=0;
						j<=j+1'b1;//下一个32位字
					end	
					default: txer<=1'b1;						
				endcase
			end
		 end
		senddata:begin            //#6     //发送UDP数据包  
			if(tx_data_counter==((ip_header[0][15:0]-40)<<1)-1)begin   //发送最后4bit的数据
				if(ip_header[0][15:0]>=46)tx_state<=sendcrc;
				else               tx_state<=send_none;
				
				case(i)
					5'd0:begin
						dataout<=datain_reg[27:24];
						i<=0;
					end		
					5'd1:begin
						dataout<=datain_reg[31:28];
						i<=0;
					end	
					5'd2:begin
						dataout<=datain_reg[19:16];
						i<=0;
					end	
					5'd3:begin
						dataout<=datain_reg[23:20];
						i<=0;
					end	
					5'd4:begin
						dataout<=datain_reg[11:8];
						i<=0;
					end	
					5'd5:begin
						dataout<=datain_reg[15:12];
						i<=0;
					end	
					5'd6:begin
						dataout<=datain_reg[3:0];
						i<=0;
					end	
					5'd7:begin
						dataout<=datain_reg[7:4];							
						i<=0; 		           //开始下一轮									
					end	
				endcase
			end
			else begin                                     //发送其它的数据包
				tx_data_counter<=tx_data_counter+1'b1;
				case(i)
					5'd0:begin
						dataout<=datain_reg[27:24];
						i<=i+1'b1;
						ram_rd_addr<=ram_rd_addr+1'b1;//准备数据
					end		
					5'd1:begin
						dataout<=datain_reg[31:28];
						i<=i+1'b1;
					end	
					5'd2:begin
						dataout<=datain_reg[19:16];
						i<=i+1'b1;
					end	
					5'd3:begin
						dataout<=datain_reg[23:20];
						i<=i+1'b1;
					end	
					5'd4:begin
						dataout<=datain_reg[11:8];
						i<=i+1'b1;
					end	
					5'd5:begin
						dataout<=datain_reg[15:12];
						i<=i+1'b1;
					end	
					5'd6:begin
						dataout<=datain_reg[3:0];
						i<=i+1'b1;
					end	
					5'd7:begin
						dataout<=datain_reg[7:4];
						datain_reg<=datain;    //数据装载				  
						i<=0; 		           //开始下一轮					
					end	
				endcase						
			end
		end	
		send_none:begin
		    if(tx_data_counter==11)begin
				dataout<=0;
				tx_state<=sendcrc;
			end
			else begin
				dataout<=0;
				tx_data_counter<=tx_data_counter+1'b1;
			end
		end
		sendcrc: begin      //#7                       //发送32位的crc校验
			crcen<=1'b0;
			case(i)
				5'd0:begin
					dataout <= {~crc[28], ~crc[29], ~crc[30], ~crc[31]};
					i<=i+1'b1;
				end    
				5'd1:begin
					dataout <= {~crc[24], ~crc[25], ~crc[26], ~crc[27]};
					i<=i+1'b1;
				end
				5'd2:begin
					dataout <= {~crc[20], ~crc[21], ~crc[22], ~crc[23]};
					i<=i+1'b1;
				end   
				5'd3:begin
					dataout <= {~crc[16], ~crc[17], ~crc[18], ~crc[19]};
					i<=i+1'b1;
				end
				5'd4:begin
					dataout <= {~crc[12], ~crc[13], ~crc[14], ~crc[15]};
					i<=i+1'b1;
				end  
				5'd5:begin
					dataout <= {~crc[8], ~crc[9], ~crc[10], ~crc[11]};
					i<=i+1'b1;
				end
				5'd6:begin
					dataout <= {~crc[4], ~crc[5], ~crc[6], ~crc[7]};
					i<=i+1'b1;
				end   
				5'd7:begin
					dataout <= {~crc[0], ~crc[1], ~crc[2], ~crc[3]};
					i<=0;
					tx_state<=idle;
				end
				default: txer<=1'b1;
			endcase
		end					
		default:tx_state<=idle;		
	endcase	  
end
 
endmodule


