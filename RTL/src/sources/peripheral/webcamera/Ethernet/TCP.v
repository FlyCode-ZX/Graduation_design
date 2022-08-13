//////////////////////////////////////////////////////////////////////////////////
// Module Name:    TCP数据通信模块
//////////////////////////////////////////////////////////////////////////////////

module TCP(
            input   wire           CLK_50M,
			input   wire           reset_n,
			input   wire [31:0]    Src_IP ,
			input   wire [31:0]    Des_IP ,
			input   wire [15:0]    Src_port_,
			input   wire [15:0]    Des_port,
			//------------------------------
			output  wire           e_reset,
			input   wire           e_txc,
			input   wire           TX_EN,
			output  wire           e_gtxc,
			input   wire           e_rxc,
			input   wire [3:0]	   e_rxd, 
			input	wire           e_rxdv,
			input	wire           e_rxer,	
			output  wire	       e_txen,
			output  wire [3:0]     e_txd,                              
			output  wire           e_txer, 
            //------------------------------
			input   wire           Eth_fifo_rdclk,
			input   wire           Eth_fifo_rden,
			output  wire [ 7:0]    Eth_fifo_rddata,
			output  wire           Eth_fifo_rdempty,
			output  wire [15:0]    Eth_fifo_rdusedw, 
            //------------------------------
			input   wire [ 1:0]    Freq_meter_sta,
			output  wire [31:0]    Eth_speed_latch,
			output  wire [31:0]    Valid_data_speed_latch,
	        output  wire [2:0]     seg_sel,
            output  wire [7:0]     seg_data,
			output  reg  [3:0]     TCP_state
);

//reg  [3:0]  TCP_state;
reg  [3:0]  TCP_state_next;
parameter idle              =4'd0,
          //----Connect---------
		  Send_SYN_ready    =4'd1,
          Send_SYN          =4'd2,
		  Wait_SYN_ACK      =4'd3,
		  Send_ACK          =4'd4,
		  //----Send------------
		  Send_PSH          =4'd5,
		  Wait_ACK          =4'd6,
		  //---------------------
		  Send_PSH_ACK      =4'd7,
		  Send_FIN_PSH_ACK  =4'd8,
		  //
		  Send_FIN_ACK      =4'd9,
		  Send_FIN          =4'd10,
		  Wait_FIN_ACK      =4'd11;

reg [31:0] Random_value;
//--------------------------------
//           Send
//--------------------------------
wire	[31:0] crcnext;
wire	[31:0] crc32;
wire	       crcreset;
wire	       crcen;
reg  Send_Task;
wire Sender_valid;
reg  [4:0] i;
//---------
reg [ 15:0] Data_len;
//reg [ 31:0] Src_IP,Des_IP;
reg [ 15:0] Src_port;
reg [ 31:0] Seq_num,Ack_num;
reg [ 3 :0] Head_len;
reg         TCP_URG,TCP_ACK,TCP_PSH,TCP_RST,TCP_SYN,TCP_FIN;       
reg [ 15:0] TCP_window;
//-------
reg  [31:0] TCP_data [4:0];  
reg         RAM_Send_wren;
reg  [ 8:0] RAM_Send_wr_addr;
reg  [31:0] RAM_Send_wr_data;
wire [ 8:0] RAM_Send_rd_addr;
wire [31:0] RAM_Send_rd_data;
//---------------------------------
//            Receive
//---------------------------------
wire [159:0]IP_layer;
wire [159:0]TCP_layer;
wire        data_receive;    
wire        Eth_wr_en;
wire [  7:0]Eth_wr_data;
wire [ 15:0]Eth_fifo_wrusedw;
reg  [ 31:0]Eth_speed;
//-------------------------------
reg  flag_rest;
assign e_reset = 1'b1;
assign e_gtxc=e_rxc;
//assign LED = ~TCP_state[3:0];

initial begin
    Send_Task       <= 1'b0;
	TCP_state       <=idle;
	TCP_state_next  <=idle;
	Seq_num         <=32'd0;
	Ack_num         <=32'd0;
	i               <=5'd0;
	flag_rest       <=1'b0;
	Random_value    <=32'd0;
	Src_port        <= 1025;
end


//随机数
always@(posedge CLK_50M)begin
	Random_value <= Random_value+1'd1;
end

////////////////////////////////////////////////////////////////
//TCP状态机
////////////////////////////////////////////////////////////////
always@(posedge CLK_50M or negedge reset_n)
    if(!reset_n) begin
		TCP_state<=idle;
		i        <=5'd0;
	end
	else 
		case(TCP_state)
			idle:begin
			    Send_Task  <= 1'b0;
				flag_rest  <= 1'b0;
				if(TX_EN==1'b1) TCP_state <= Send_SYN_ready;
				else TCP_state  <= idle;
			end
			//----------------握手------------------------------------------
			Send_SYN_ready:begin //4B的TCP首选项
			    RAM_Send_wren    <=1'b1;
			    if(i==0)begin
					RAM_Send_wr_addr <= 9'd1;
					RAM_Send_wr_data <= {8'h02,8'h04,8'h05,8'hB4};
					i <= i+1;
				end
				else if(i==1)begin
					RAM_Send_wr_addr <= 9'd2;
				    RAM_Send_wr_data <= {8'h01,8'h01,8'h01,8'h01};
					i <= 0;
					TCP_state        <= Send_SYN;
					flag_rest        <= 1'b1;
				end
			end
			Send_SYN:begin
			    RAM_Send_wren<=1'b0;
				//IP
			    Data_len   <= 16'd8;      //2*4=8
			    //Src_IP     <= {8'd192,8'd168,8'd2,8'd2};
			    //Des_IP     <= {8'd192,8'd168,8'd2,8'd6};
			    //TCP
			    Src_port   <= Src_port + 1'b1;  //Random_value[15:0];
			    //Des_port   <= 16'd8080;
			    Seq_num    <= Random_value;
			    Ack_num    <= 32'd0;
			    Head_len   <= 4'd7;        //5+2
			    TCP_URG    <= 1'b0;
			    TCP_ACK    <= 1'b0;
			    TCP_PSH    <= 1'b0;
			    TCP_RST    <= 1'b0;
			    TCP_SYN    <= 1'b1;        //Connect
			    TCP_FIN    <= 1'b0;
				TCP_window <= 16'hff10;
				//---------------------------
				Send_Task  <= 1'b1;//预备发送
				TCP_state  <= Wait_SYN_ACK;
				flag_rest  <= 1'b0;
			end
			Wait_SYN_ACK:begin
				Send_Task  <= 1'b0;//数据锁存		
				if(TCP_state_next==Send_ACK) TCP_state <=Send_ACK;//连接第三次握手
				else    TCP_state <=Wait_SYN_ACK;
			end
			Send_ACK:begin
				Send_Task  <= 1'b0;
				if(Sender_valid)begin
					Data_len   <= 16'd0;   
					//TCP				
					Seq_num    <= {TCP_layer[71:64],TCP_layer[79:72],
								   TCP_layer[87:80],TCP_layer[95:88]};//为上次接收包的确认号
					Ack_num    <= {TCP_layer[39:32],TCP_layer[47:40],
								   TCP_layer[55:48],TCP_layer[63:56]}+1;//为上次接收包的序列号+1
					Head_len   <=  4'd5;   
					TCP_URG    <=  1'b0;
					TCP_ACK    <=  1'b1;//ACK
					TCP_PSH    <=  1'b0;
					TCP_RST    <=  1'b0;
					TCP_SYN    <=  1'b0;        
					TCP_FIN    <=  1'b0;
					//------------------
					Send_Task  <= 1'b1;	//预备发送	
					TCP_state  <= Send_PSH;
                end				
			end
			//---------------数据发送------------------------------------------------------------------
			Send_PSH:begin         //发送数据
			    Send_Task  <= 1'b0;//数据锁存
				flag_rest  <= 1'b0;
				//收到FIN，进入	Send_FIN_ACK
                if(TCP_state_next==Send_FIN_ACK)          TCP_state <=Send_FIN_ACK;	
                else if(TCP_state_next==Send_PSH_ACK)     TCP_state <=Send_PSH_ACK;
				else if(TCP_state_next==Send_FIN_PSH_ACK) TCP_state <=Send_FIN_PSH_ACK;
			end
			Wait_ACK:begin
				Send_Task  <= 1'b0;	
                if(TCP_state_next==Send_PSH) TCP_state <=Send_PSH;		
			end
			Send_PSH_ACK:begin//收到数据后发送ACK
				Send_Task  <= 1'b0;
				flag_rest  <= 1'b1;
				if(Sender_valid)begin
					Data_len   <= 16'd0;
					Seq_num    <= {TCP_layer[71:64],TCP_layer[79:72],
								   TCP_layer[87:80],TCP_layer[95:88]};//为上次接收包的确认号
					Ack_num    <= {TCP_layer[39:32],TCP_layer[47:40],
								   TCP_layer[55:48],TCP_layer[63:56]}
								   +{IP_layer[23:16],IP_layer[31:24]}-40;//为上次接收包的序列号+1
					Head_len   <=  4'd5;  
					TCP_URG    <=  1'b0;
					TCP_ACK    <=  1'b1;//ACK
					TCP_PSH    <=  1'b0;
					TCP_RST    <=  1'b0;
					TCP_SYN    <=  1'b0;        
					TCP_FIN    <=  1'b0;
					//流量控制
					TCP_window <= 16'hff11 - Eth_fifo_wrusedw;    
					
					Send_Task  <=  1'b1;	//预备发送
                    TCP_state  <=  Send_PSH;
				end
			
			end
			Send_FIN_PSH_ACK:begin//收到数据后发送ACK
				Send_Task  <= 1'b0;
				flag_rest  <= 1'b1;
				if(Sender_valid)begin
					Data_len   <= 16'd0;
					Seq_num    <= {TCP_layer[71:64],TCP_layer[79:72],
								   TCP_layer[87:80],TCP_layer[95:88]};//为上次接收包的确认号
					Ack_num    <= {TCP_layer[39:32],TCP_layer[47:40],
								   TCP_layer[55:48],TCP_layer[63:56]}
								   +{IP_layer[23:16],IP_layer[31:24]}-40+1;//为上次接收包的序列号+1
					Head_len   <=  4'd5;  
					TCP_URG    <=  1'b0;
					TCP_ACK    <=  1'b1;//ACK
					TCP_PSH    <=  1'b0;
					TCP_RST    <=  1'b0;
					TCP_SYN    <=  1'b0;        
					TCP_FIN    <=  1'b0;
					Send_Task  <=  1'b1;	//预备发送
                    TCP_state  <=  Send_FIN;
				end
			
			end
			//------------------断开--------------------------------------------------------------
			Send_FIN_ACK:begin      //收到FIN后发送ACK
			    Send_Task  <= 1'b0;
				if(Sender_valid)begin
					Data_len   <= 16'd0;
					Seq_num    <= {TCP_layer[71:64],TCP_layer[79:72],
								   TCP_layer[87:80],TCP_layer[95:88]};//为上次接收包的确认号
					Ack_num    <= {TCP_layer[39:32],TCP_layer[47:40],
								   TCP_layer[55:48],TCP_layer[63:56]}+1;//为上次接收包的序列号+1
					Head_len   <=  4'd5;  
					TCP_URG    <=  1'b0;
					TCP_ACK    <=  1'b1;//ACK
					TCP_PSH    <=  1'b0;
					TCP_RST    <=  1'b0;
					TCP_SYN    <=  1'b0;        
					TCP_FIN    <=  1'b0;
					Send_Task  <=  1'b1;	//预备发送
                    TCP_state  <=  Send_FIN;			
				end
			end
			Send_FIN:begin            //FIN ACK,序列号与确认号与上此相同
			    Send_Task  <= 1'b0;
				if(Sender_valid)begin
				    Data_len   <= 16'd0;
				    Head_len   <=  4'd5;  
					TCP_URG    <=  1'b0;
					TCP_ACK    <=  1'b1;//ACK
					TCP_PSH    <=  1'b0;
					TCP_RST    <=  1'b0;
					TCP_SYN    <=  1'b0;        
					TCP_FIN    <=  1'b1;//FIN
					Send_Task  <=  1'b1;//预备发送	
					TCP_state  <=  Wait_FIN_ACK;
				end
			end
			Wait_FIN_ACK:begin
				Send_Task  <= 1'b0;
				if(TCP_state_next==idle)begin
					TCP_state <=idle;	//收到ACK
					flag_rest  <= 1'b1;
				end
			end
			default: TCP_state<=idle;
		endcase
	
//---------------------------------------------------------------
//                  数据发送
//---------------------------------------------------------------
ram RAM_Send(
  .wrclock(CLK_50M),           // input write clock
  .wren(RAM_Send_wren),                // input [0 : 0] ram write enable
  .wraddress(RAM_Send_wr_addr),         // input [8 : 0] ram write address
  .data(RAM_Send_wr_data),               // input [31 : 0] ram write data
  .rdclock(~e_txc),           // input read clock
  .rdaddress(RAM_Send_rd_addr),   // input [8 : 0] ram read address
  .q(RAM_Send_rd_data)            // output [31 : 0] ram read data
);
//crc32校验
crc	crc_inst(
	.clk(e_txc),//发送时钟25M
	.rst(crcreset),
	.crc_en(crcen),
	.data_in(e_txd),
	.crc_out(crc32)
);

//IP frame发送
ipsend ipsend_inst(
	.clk(e_txc),//发送时钟25M
	.Task(Send_Task),
	.Data_len(Data_len),
	.Src_IP(Src_IP),
	.Des_IP(Des_IP),
	.Src_port(Src_port),
	.Des_port(Des_port),
	.Seq_num(Seq_num),
	.Ack_num(Ack_num),
	.Head_len(Head_len),
	.TCP_URG(TCP_URG),
	.TCP_ACK(TCP_ACK),
	.TCP_PSH(TCP_PSH),
	.TCP_RST(TCP_RST),
	.TCP_SYN(TCP_SYN),
	.TCP_FIN(TCP_FIN),
	.TCP_window(TCP_window),
	.txen(e_txen),
	.txer(e_txer),
	.dataout(e_txd),
	.crc(crc32),
	.datain(RAM_Send_rd_data),
	.crcen(crcen),
	.crcre(crcreset),
	.ram_rd_addr(RAM_Send_rd_addr),
	.Sender_valid(Sender_valid)
);
//---------------------------------------------------------------
//                  数据接收
//---------------------------------------------------------------
fre_meter fre_meter_inst00(
	.CLK_50M       (CLK_50M         ),
	.reset_n       (reset_n         ),
	.clk           (e_rxc & e_rxdv  ),
	.speed_latch   (Eth_speed_latch ),
	.Freq_meter_sta(Freq_meter_sta  ) 
);
fre_meter fre_meter_inst01(
	.CLK_50M       (CLK_50M                ),
	.reset_n       (reset_n                ),
	.clk           (Eth_wr_en              ),
	.speed_latch   (Valid_data_speed_latch ),
	.Freq_meter_sta(Freq_meter_sta         )   
);


Eth_RX_FIFO	Eth_RX_FIFO_inst (
    .aclr  ( ~reset_n        ),
	//-------------------------
    .rdclk ( Eth_fifo_rdclk  ),
	.rdreq ( Eth_fifo_rden   ),
	.q     ( Eth_fifo_rddata ),
	//-----------------------------------------
	.wrclk ( ~e_rxc          ),//数据在下降沿锁存
	.wrreq ( Eth_wr_en       ),
	.data  ( Eth_wr_data     ),
	//-----------------------------------------
	.rdempty ( Eth_fifo_rdempty ), 
	.rdusedw ( Eth_fifo_rdusedw ),
	.wrfull  (                  ),
	.wrusedw ( Eth_fifo_wrusedw )
);
//IP frame接收程序
iprecieve iprecieve_inst(
	.clk(e_rxc),
	.datain(e_rxd),
	.e_rxdv(e_rxdv),	
	.clr(reset_n),
    //------------------------
	.board_mac(),   //目标MAC	
	.pc_mac(),      //源MAC
	.IP_Prtcl(),    //协议类型   
	.IP_layer(IP_layer),    //IP首部
	.TCP_layer(TCP_layer),   //TCP首部
	.valid_ip_P(),  //协议类型 有效
	.rx_data_length(),
	//----------------------------
	.data_o(Eth_wr_data),	
	.data_o_valid(Eth_wr_en), //RAM写使能                                      
	//.ram_wr_addr(RAM_Receive_wr_addr),
	.data_receive(data_receive)
);

initial begin
	TCP_state_next <= idle;
end

always@(posedge data_receive or posedge flag_rest)//接受一帧数据
if(flag_rest==1'b1)begin
	TCP_state_next <= idle; 
    	
end
else begin
	if(IP_layer[127: 96]=={8'd6,8'd2,8'd168,8'd192})begin//检查目标IP地址
	
		if(TCP_layer[109:104]==6'b0_1_0_0_1_0)begin                  //收到SYN,ACK
			TCP_state_next <= Send_ACK;  //发送ACK,FIN
		end
		else if(TCP_layer[109:104]==6'b0_1_0_0_0_0)begin              //ACK
	   
			if(TCP_state == Wait_ACK)begin  //ACK,发送数据后的确认
				TCP_state_next <= Send_PSH; //发出的FIN得到确认
			end
			else if(TCP_state == Wait_FIN_ACK)begin //ACK,发送FIN后的确认
			    TCP_state_next <= idle;
			end
		end
		else if(TCP_layer[109:104]==6'b0_1_1_0_0_0)begin              //收到PSH,ACK
			TCP_state_next <= Send_PSH_ACK;
		end
		else if(TCP_layer[109:104]==6'b0_1_0_0_0_1)begin              //收到FIN,ACK
			TCP_state_next <= Send_FIN_ACK;
		end
		else if(TCP_layer[109:104]==6'b0_1_1_0_0_1)begin              //收到FIN,PSH,ACK
			TCP_state_next <= Send_FIN_PSH_ACK;
		end
		
		
	end
end
	
//-----------------
//频率计
//-----------------
frequency_counter frequency_counter_inst(
	.clk(CLK_50M),
	.REF_clk(e_txc),
    .rst_n(reset_n),
    .seg_sel(seg_sel),
    .seg_data(seg_data)
);
endmodule
