//****************************************Copyright (c)***********************************//
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取FPGA & STM32资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           sdram_fifo_ctrl
// Last modified Date:  2018/3/18 8:41:06
// Last Version:        V1.0
// Descriptions:        SDRAM 读写端口FIFO控制模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2018/3/18 8:41:06
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module sdram_fifo_ctrl(
	input             clk_ref,		     //SDRAM控制器时钟
	input             rst_n,			 //系统复位 
                                         
    //用户写端口                         
	input             clk_write,		 //写端口FIFO: 写时钟 
	input             wrf_wrreq,		 //写端口FIFO: 写请求 
	input      [39:0] wrf_din,		     //写端口FIFO: 写数据	 
                                         
    //用户读端口                         
	input             clk_read,		     //读端口FIFO: 读时钟
	input             rdf_rdreq,		 //读端口FIFO: 读请求 
	output     [15:0] rdf_dout,		     //读端口FIFO: 读数据
	input      [23:0] rd_min_addr,	     //读SDRAM的起始地址
	input      [23:0] rd_max_addr,	     //读SDRAM的结束地址
	input      [ 9:0] rd_length,		 //从SDRAM中读数据时的突发长度 
	input             rd_load,		     //读端口复位: 复位读地址,清空读FIFO
	                                     
	//用户控制端口	                     
	input             sdram_read_valid,  //SDRAM 读使能
	input             sdram_init_done,   //SDRAM 初始化完成标志
                                         
    //SDRAM 控制器写端口 
	output    		  sdram_wr_req,	     //sdram 写请求
	input             sdram_wr_ack,	     //sdram 写响应
	output     [23:0] sdram_wr_addr,	 //sdram 写地址
	output	   [15:0] sdram_din,		 //写入SDRAM中的数据 
                                         
    //SDRAM 控制器读端口                 
	output reg        sdram_rd_req,	     //sdram 读请求
	input             sdram_rd_ack,	     //sdram 读响应
	output reg [23:0] sdram_rd_addr,	 //sdram 读地址 
	input      [15:0] sdram_dout ,	 //从SDRAM中读出的数据 
	output     [15:0] vector_fifo_rdusedw,
	output     [15:0] vga_fifo_rdusedw
    );

//reg define
reg	       wr_ack_r1;                    //sdram写响应寄存器      
reg	       wr_ack_r2;                    
reg        rd_ack_r1;                    //sdram读响应寄存器      
reg	       rd_ack_r2;                    
reg	       rd_load_r1;                   //读端口复位寄存器      
reg        rd_load_r2;                   
reg        read_valid_r1;                //sdram读使能寄存器      
reg        read_valid_r2;                
                                         
//wire define                            
wire       write_done_flag;              //sdram_wr_ack 下降沿标志位      
wire       read_done_flag;               //sdram_rd_ack 下降沿标志位      
wire       wr_load_flag;                 //wr_load      上升沿标志位      
wire       rd_load_flag;                 //rd_load      上升沿标志位      

wire [9:0] rdf_use;                      //读端口FIFO中的数据量
wire       wrf_rdempty;
//*****************************************************
//**                    main code
//***************************************************** 

//检测下降沿
assign read_done_flag  = rd_ack_r2   & ~rd_ack_r1;

//检测上升沿
//assign wr_load_flag    = ~wr_load_r2 & wr_load_r1;
assign rd_load_flag    = ~rd_load_r2 & rd_load_r1;

//寄存sdram写响应信号,用于捕获sdram_wr_ack下降沿
always @(posedge clk_ref or negedge rst_n) begin
	if(!rst_n) begin
		wr_ack_r1 <= 1'b0;
		wr_ack_r2 <= 1'b0;
    end
	else begin
		wr_ack_r1 <= sdram_wr_ack;
		wr_ack_r2 <= wr_ack_r1;		
    end
end	

//寄存sdram读响应信号,用于捕获sdram_rd_ack下降沿
always @(posedge clk_ref or negedge rst_n) begin
	if(!rst_n) begin
		rd_ack_r1 <= 1'b0;
		rd_ack_r2 <= 1'b0;
    end
	else begin
		rd_ack_r1 <= sdram_rd_ack;
		rd_ack_r2 <= rd_ack_r1;
    end
end	

//同步读端口复位信号，同时用于捕获rd_load上升沿
always @(posedge clk_ref or negedge rst_n) begin
	if(!rst_n) begin
		rd_load_r1 <= 1'b0;
		rd_load_r2 <= 1'b0;
    end
	else begin
		rd_load_r1 <= rd_load;
		rd_load_r2 <= rd_load_r1;
    end
end

//同步sdram读使能信号
always @(posedge clk_ref or negedge rst_n) begin
	if(!rst_n) begin
		read_valid_r1 <= 1'b0;
		read_valid_r2 <= 1'b0;
    end
	else begin
		read_valid_r1 <= sdram_read_valid;
		read_valid_r2 <= read_valid_r1;
    end
end

//sdram读地址产生模块
always @(posedge clk_ref or negedge rst_n) begin
	if(!rst_n)
		sdram_rd_addr <= 24'd0;
	else if(rd_load_flag)				 //检测到读端口复位信号时，读地址复位
		sdram_rd_addr <= rd_min_addr;
	else if(read_done_flag) begin        //突发读SDRAM结束，更改读地址
                                         //若未到达读SDRAM的结束地址，则读地址累加
		if(sdram_rd_addr < rd_max_addr - rd_length)
			sdram_rd_addr <= sdram_rd_addr + rd_length;
		else                             //若已到达读SDRAM的结束地址，则回到读起始地址
            sdram_rd_addr <= rd_min_addr;
	end
end

//sdram 读写请求信号产生模块
always@(posedge clk_ref or negedge rst_n) begin
	if(!rst_n) begin
		sdram_rd_req <= 0;
	end
	else if(sdram_init_done) begin       //SDRAM初始化完成后才能响应读写请求
		if((rdf_use < rd_length) && read_valid_r2) begin //同时sdram读使能信号为高		     
			sdram_rd_req <= 1;		     //发出读sdarm请求
		end
		else begin
			sdram_rd_req <= 0;
		end
	end
	else begin
		sdram_rd_req <= 0;
	end
end

//例化写端口FIFO	
afifo_40_1024	wr_fifo (
	.aclr    ( ~rst_n ),
	//wire
	.wrclk   ( clk_write    ),
	.wrreq   ( wrf_wrreq    ),
	.data    ( wrf_din      ),
	//read
	.rdclk   ( ~clk_ref      ),
	.rdreq   ( sdram_wr_ack ),
	.q       ( {sdram_wr_addr[23:0],sdram_din[15:0]}),
	//
	.rdempty ( wrf_rdempty  ),
	.rdusedw ( vector_fifo_rdusedw  ),
	.wrfull  (    ),
	.wrusedw (    )
);
assign  sdram_wr_req = ~wrf_rdempty;
//例化读端口FIFO
afifo_16_1024	rd_fifo (
	.aclr    ( ~rst_n | rd_load_flag ),
    //wire
	.wrclk   ( clk_ref      ),
	.wrreq   ( sdram_rd_ack ),
	.data    ( sdram_dout   ),
	//read
	.rdclk   ( clk_read  ),
	.rdreq   ( rdf_rdreq ),
	.q       ( rdf_dout  ),
	//
	.rdempty (  ),
	.rdusedw (vga_fifo_rdusedw  ),
	.wrfull  (  ),
	.wrusedw ( rdf_use )
);
endmodule 