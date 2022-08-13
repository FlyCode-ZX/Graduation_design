module frequency_counter(
	input       clk,
	input      REF_clk,
    input             rst_n,
    output reg [2:0]  seg_sel,
    output[7:0]seg_data
);
//计数时间1S
reg [25:0] Time;
reg count_clear;
reg [19:0]  Value;
reg input_low;
reg [18:0] count;
reg [19:0]  Value_count;

always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0) begin
    Time <=26'd0;
	Value <= 20'd0;
  end
  else begin
    if(Time < 26'd49_999_999)begin
    	Time <= Time+26'd1;
		count_clear <= 1'b0;
	end
	else begin
	  Time <=26'd0;
	  count_clear <= 1'b1;
	end
	
	if(Time==26'd49_999_999) Value <= Value_count;
  end
  
//输入分频
always@(posedge REF_clk)
  if(count<19'd499_999) count<=count+5'd1;
  else begin 
    count<=19'd0;
	input_low<=~input_low;
  end

//输入计数
always@(posedge input_low or negedge rst_n or posedge count_clear)
  if(rst_n == 1'b0)begin
    Value_count<=20'd0;
	end
  else if(count_clear)begin
    Value_count <= 20'd0;
  end
  else begin
	 Value_count <= Value_count +1'b1;
  end


reg [ 3:0]  seg_data_bin;
reg [ 6:0]  Array [0:10] ;
reg [31:0]  scan_timer;
reg [ 3:0]  scan_sel;
parameter SCAN_FREQ = 200;     //scan frequency
parameter CLK_FREQ = 50000000; //clock frequency
parameter SCAN_COUNT = CLK_FREQ /(SCAN_FREQ * 6) - 1;
assign      seg_data = ~Array[seg_data_bin];
always@(clk) begin
 // Value <= 199912;
  Array[0] <= 7'd63;
  Array[1] <= 7'd6;
  Array[2] <= 7'd91;
  Array[3] <= 7'd79;
  Array[4] <= 7'd102;
  Array[5] <= 7'd109;
  Array[6] <= 7'd125;
  Array[7] <= 7'd7;
  Array[8] <= 7'd127;
  Array[9] <= 7'd111;
end
//扫描索引
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		scan_timer <= 32'd0;
		scan_sel <= 4'd0;
	end
	else if(scan_timer >= SCAN_COUNT)
	begin
		scan_timer <= 32'd0;
		if(scan_sel == 4'd2)
			scan_sel <= 4'd0;
		else
			scan_sel <= scan_sel + 4'd1;
	end
	else
		begin
			scan_timer <= scan_timer + 32'd1;
		end
end
//数据装载
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		seg_sel <= 3'b000;
		seg_data_bin <= 4'd10;
	end
	else
	begin
		case(scan_sel)
			//first digital led
			4'd0:
			begin
				seg_sel <= 3'b001;
				seg_data_bin <= Value%10'd1000/7'd100;
			end
			//second digital led
			4'd1:
			begin
				seg_sel <= 3'b010;
				seg_data_bin <= Value%10'd1000%7'd100/4'd10;
			end
			//...
			4'd2:
			begin
				seg_sel <= 3'b100;
				seg_data_bin <= Value%10'd1000%7'd100%4'd10;
			end
			default:
			begin
				seg_sel <= 3'b000;
				seg_data_bin <= 4'hf;
			end
		endcase
	end
end 
endmodule