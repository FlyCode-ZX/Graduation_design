module uart_tx
#(
	parameter CLK_FRE = 50,      //clock frequency(Mhz)
	parameter BAUD_RATE = 115200 //serial baud rate
)
(
	input                        clk,              //clock input
	input                        rst_n,            //asynchronous reset input, low active 
	input[7:0]                   tx_data,          //data to send
	input                        tx_data_valid,    //data to be sent is valid
	output reg                   tx_data_ready,    //send ready
	output                       tx_pin            //serial data output
);
//calculates the clock cycle for baud rate 
localparam                       CYCLE = CLK_FRE * 1000000 / BAUD_RATE;//434.027
//state machine code
localparam                       S_IDLE       = 1;
localparam                       S_START      = 2;//start bit
localparam                       S_SEND_BYTE  = 3;//data bits
localparam                       S_STOP       = 4;//stop bit
reg[2:0]                         state;
reg[2:0]                         next_state;
reg[15:0]                        cycle_cnt; //baud counter
reg[2:0]                         bit_cnt;//bit counter
reg[7:0]                         tx_data_latch; //latch data to send
reg                              tx_reg; //serial data output
assign tx_pin = tx_reg;
//状态装载
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		state <= S_IDLE;
	else
		state <= next_state;
end
//发送状态机
always@(*)
begin
	case(state)
		S_IDLE:
			if(tx_data_valid == 1'b1)
				next_state <= S_START;
			else
				next_state <= S_IDLE;
		S_START:
			if(cycle_cnt == CYCLE - 1)
				next_state <= S_SEND_BYTE;
			else
				next_state <= S_START;
		S_SEND_BYTE:
			if(cycle_cnt == CYCLE - 1  && bit_cnt == 3'd7)
				next_state <= S_STOP;
			else
				next_state <= S_SEND_BYTE;
		S_STOP:
			if(cycle_cnt == CYCLE - 1)
				next_state <= S_IDLE;
			else
				next_state <= S_STOP;
		default:
			next_state <= S_IDLE;
	endcase
end
//标志信号
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		begin
			tx_data_ready <= 1'b0;
		end
	else if(state == S_IDLE)
		if(tx_data_valid == 1'b1)//有数据有效
			tx_data_ready <= 1'b0;//发送数据没有准备好
		else
			tx_data_ready <= 1'b1;
	else if(state == S_STOP && cycle_cnt == CYCLE - 1)
			tx_data_ready <= 1'b1;
end

//数据锁存
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		begin
			tx_data_latch <= 8'd0;
		end
	else if(state == S_IDLE && tx_data_valid == 1'b1)//发送状态空闲且数据有效 进行数据装载
			tx_data_latch <= tx_data;
		
end
//发送个数计数
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		begin
			bit_cnt <= 3'd0;
		end
	else if(state == S_SEND_BYTE)
		if(cycle_cnt == CYCLE - 1)//到达每位所占用的时间
			bit_cnt <= bit_cnt + 3'd1;
		else
			bit_cnt <= bit_cnt;
	else
		bit_cnt <= 3'd0;
end

//位发送所需时间索引
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		cycle_cnt <= 16'd0;
	else if((state == S_SEND_BYTE && cycle_cnt == CYCLE - 1) || next_state != state)
		cycle_cnt <= 16'd0;
	else
		cycle_cnt <= cycle_cnt + 16'd1;	
end

//数据输出
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
		tx_reg <= 1'b1;
	else
		case(state)
			S_IDLE,S_STOP:
				tx_reg <= 1'b1;//空闲释放总线 
			S_START:
				tx_reg <= 1'b0; 
			S_SEND_BYTE:
				tx_reg <= tx_data_latch[bit_cnt];//数据装载
			default:
				tx_reg <= 1'b1; //释放总线
		endcase
end

endmodule 