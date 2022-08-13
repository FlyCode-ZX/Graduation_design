module SMC(
	input  wire CLK_50M,
	input  wire rst_n,
	input  wire W_R,
	
	input  wire [4:0]  address,
	input  wire [15:0] W_value,
	input              IN_data_valid,
	
	output reg  [15:0] R_value,
	output reg         OUT_data_valid,
    
	output reg  SMC_ready,  
	output wire MDC,
	inout  wire MDIO
);
reg In_O;
reg MD_O;
wire MD_I;
reg  MDC_on;
assign MDIO = In_O?MD_O:1'bz;
assign MD_I = MDIO;
reg [4:0]  PHY_address;
reg [15:0] PHY_W_value;
reg        PHY_W_R;
reg[2:0]   state;
reg[6:0]   bit_count;
//分频
reg clk_1M=0;
reg [4:0] count;
always@(posedge CLK_50M)
  if(count<5'd24) count<=count+5'd1;
  else begin 
    count<=5'd0;
	clk_1M<=~clk_1M;
  end
//发送计数
assign MDC =MDC_on&clk_1M;
always@(posedge clk_1M or negedge rst_n or posedge IN_data_valid)
  if(rst_n == 1'b0)begin
		MDC_on <= 1'd0;
		bit_count <= 7'h01;
    end
  else begin
	  if(IN_data_valid) bit_count<=7'd0;
	  else if(state==1'd1)begin MDC_on <=1'd1;bit_count<=bit_count+7'd1;end
	  else if(state==1'd0) MDC_on <=1'b0; 
  end
//==================================
//SMC状态机
//==================================
always@(posedge CLK_50M or negedge rst_n)
  if(rst_n == 1'b0)begin
		MD_O <= 1'd1;
		In_O <= 1'd1;
		state <= 3'd0;
		SMC_ready  <= 1'b0;
  end
  else  begin
	case(state)
	  3'd0:begin
	        if(IN_data_valid)begin
			 state <= 3'd1;//数据有效进入发送
			 SMC_ready  <= 1'b0;//SMC不空闲
			end
			else begin MD_O <= 1'b1;end
			OUT_data_valid <= 1'd0;
		   end
	  3'd1:begin
		  if(bit_count<7'd32)begin
			In_O <= 1'b1;
			MD_O <= 1'b1;
			end
		  //开始
		  else if(bit_count==7'd32) MD_O <= 1'b0;
		  else if(bit_count==7'd33) MD_O <= 1'b1;
		  //读写
		  else if(bit_count==7'd34) MD_O <=  PHY_W_R;
		  else if(bit_count==7'd35) MD_O <= ~PHY_W_R;
		  //PHYAD
		  else if(bit_count<7'd40)  MD_O <= 1'b0;
		  else if(bit_count==7'd40) MD_O <= 1'b1;
		  //REG
		  else if(bit_count<7'd46)  MD_O <= PHY_address[7'd4-(bit_count-7'd41)];
		  //Turn
		  else if(bit_count<7'd48)begin  In_O <= ~PHY_W_R;MD_O <=1'b1; end
		  //Data
		  else if(bit_count<7'd64)begin
			if(In_O) MD_O <= PHY_W_value[7'd15-(bit_count-7'd48)];
			else R_value[7'd15-(bit_count-7'd48)] <= MD_I; end
		  else begin
      		  state <= 3'd0;
			  if(PHY_W_R) OUT_data_valid <= 1'd1;
			  SMC_ready  <= 1'b1;
		  end
		end
	endcase 
  end
always@(posedge CLK_50M)
  if(IN_data_valid)begin
    PHY_address <= address;
    PHY_W_value <= W_value;
	PHY_W_R     <= W_R;
	end
endmodule
