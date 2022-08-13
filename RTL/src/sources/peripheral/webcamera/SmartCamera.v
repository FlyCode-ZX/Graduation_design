`timescale 1ns/1ps
module SmartCamera(
    input  wire        PCLK,     // Clock
    input  wire        PRESETn,  // Reset
    //地址信息
    input  wire        PSEL,     // Device select
    input  wire [11:2] PADDR,    // Address
  
    input  wire        PENABLE,  // Transfer control
    input  wire        PWRITE,   // Write control
    input  wire [31:0] PWDATA,   // Write data
    output wire [31:0] PRDATA,   // Read data
    output wire        PREADY,   // Device ready

    output wire        PSLVERR,  // Device error response
	//-----Ethernet--------------
	input  wire        e_txc,
	input  wire        e_rxc,
	input  wire        e_rxdv,
	input  wire        e_rxer,
	input  wire [3:0]  e_rxd,
	output wire        e_reset,
	output wire        e_gtxc,
	output wire        e_txen,
	output wire        e_txer,
	output wire [3:0]  e_txd,
	//-----UART-----------------    
	input  wire        uart_rx,
	output wire        uart_tx,
	input  wire        CH9350_TXD,
	//-----BEEP-----------------    
	output wire        BEEP    ,
	//-----SMI-----------------
	output wire        MDC,
	inout  wire        MDIO,
	//------VGA----------------
	output  wire          vga_out_hs,        //vga horizontal synchronization
	output  wire          vga_out_vs,        //vga vertical synchronization
	output  wire  [4:0]   vga_out_r,         //vga red
	output  wire  [5:0]   vga_out_g,         //vga green
	output  wire  [4:0]   vga_out_b,        //vga blue
	//-----SDRAM_port-----------
	output wire        sdram_clk,         //sdram clock
	output wire        sdram_cke,         //sdram clock enable
	output wire        sdram_cs_n,        //sdram chip select
	output wire        sdram_we_n,        //sdram write enable
	output wire        sdram_cas_n,       //sdram column address strobe
	output wire        sdram_ras_n,       //sdram row address strobe
	output wire [ 1:0] sdram_dqm,         //sdram data enable
	output wire [ 1:0] sdram_ba,          //sdram bank address
	output wire [12:0] sdram_addr,        //sdram address
	inout  wire [15:0] sdram_dq ,
	//-----数码管--------------------
	output wire [2:0]  seg_sel, 
	output wire [7:0]  seg_data
);

localparam CLC_IDLE  = 4'd0;
localparam CLC_RUN   = 4'd1;
localparam CLC_END   = 4'd2;


//-----system-------
wire clk;
wire rst_n;
assign clk   = PCLK;


//------reg_config------
wire         read_enable  ;
wire         write_enable ;
wire [31:0]  read_mux_word;
reg  [31:0]  System_reg [15:0];
//------UART-------
parameter   CLK_FRE = 50;//Mhz
reg[3:0]    TX_source;
reg[7:0]    tx_data;
reg         tx_data_valid;
wire        tx_data_ready;
wire[7:0]   rx_data;
wire        rx_data_valid;
wire        rx_data_ready;
reg [7:0]   RAM_UART [0:9];
reg [3:0]   wr_addr;
reg[7:0]    tx_cnt;
//-------------------------
localparam  IDLE     =  0;
localparam  SMC      =  1;   //send HELLO ALINX\r\n
localparam  Eth_FIFO =  2;   //wait 1 second and send uart received data
localparam  P_send   =  3;
//------Eth--------
wire           Eth_fifo_rden;
reg            Eth_fifo_rden_next;
wire [ 7:0]    Eth_fifo_rddata;
wire [15:0]    Eth_fifo_rdusedw;
wire           Eth_fifo_rdvalid;  
wire           Eth_fifo_rdempty; 
wire           Decoder_clk;   
wire [ 3:0]    TCP_state  ;
wire [31:0]    Src_IP     ;
wire [31:0]    Des_IP     ;
wire [15:0]    Src_port   ;
wire [15:0]    Des_port   ; 
wire [31:0]    Valid_data_speed_latch;
//-----MJPEG-------
wire           fifo_data_req;
wire  [15:0]   jpeg_core_pixel_x;
wire  [15:0]   jpeg_core_pixel_y;
wire  [ 7:0]   jpeg_core_pixel_r;
wire  [ 7:0]   jpeg_core_pixel_g;
wire  [ 7:0]   jpeg_core_pixel_b;

wire           sdram_wr_en;
wire  [23:0]   jpeg_core_addr;
wire  [15:0]   jpeg_core_data;
wire           frame_vsync   ;
wire  [ 7:0]   frame_speed_latch;
wire  [ 7:0]   store_speed_latch;
//-----GRB2YCRCB--------------
wire  [23:0]   post_frame_addr ;
wire           post_frame_clken;
wire  [15:0]   cmos_mask_data  ;

//SDRAM
wire           sdram_sys_clk ;
wire           clk_100m_shift;
wire  [39:0]   sdram_wr_data ;
wire           wr_en         ;
wire  [39:0]   wr_data       ;
//VIP
wire           BIT_IMG ;
wire           BIT ;  
wire		   per_frame_vsync	;
wire		   per_frame_href	;
wire		   per_frame_clken ;
wire [ 7:0]	   img1_data ;
wire [ 7:0]	   img2_data ;
wire [10:0]	   hcnt ;
wire [ 9:0]	   vcnt ;
wire           per_frame_vsync_Erosion;
wire           per_frame_href_Erosion;
wire           per_frame_clken_Erosion;
wire           post_frame_clken_Erosion;
wire           vga_bit;
wire           vidon;

reg  [7:0]     GRAY_THRESHOLD   ;
//VGA
wire           vga_clk       ;
wire           vsync_vga     ;
wire           vga_data_req  ;
wire  [15:0]   vga_data      ;      
//----------------------------
reg   [ 3:0] CLC_state;
reg   [23:0] CLC_index;
reg          CLC_ing;
//----------------------------
reg   [27:0] Freq_meter;
reg   [ 1:0] Freq_meter_sta;
wire  [31:0] Eth_speed_latch;

wire  [15:0] vector_fifo_rdusedw;
wire  [15:0] vga_fifo_rdusedw;
wire  sdram_store;
//---------------------------
wire [ 2:0] Mouse_key;
wire [15:0] Cursor_x;
wire [15:0] Cursor_y;
wire [15:0] X      ;
wire [15:0] Y      ;
wire        L_up   ;
wire        L_down ;  
wire        R_down ; 
reg  [15:0] x1     ;
reg  [15:0] y1     ;
reg  [15:0] x2     ;
reg  [15:0] y2     ;
reg         display;
wire        out_en ;


initial begin
	tx_cnt    <=0;
	TX_source <=IDLE;
end

assign rst_n = ~((~PRESETn) | (System_reg[0][0]));

pll_clk u_pll_clk(
    .inclk0    (clk           ),
    .c0        (Decoder_clk   ),//25M
    .c1        (sdram_sys_clk ),
    .c2        (clk_100m_shift) 
);
//===================================================
//Register Config
//===================================================
assign  PREADY  = 1'b1; // Always ready
assign  PSLVERR = 1'b0; // Always okay
assign  PRDATA[31: 0] = (read_enable) ? read_mux_word : {32{1'b0}};
assign  read_enable  = PSEL & (~PWRITE); // assert for whole APB read transfer
assign  write_enable = PSEL & (~PENABLE) & PWRITE; // assert for 1st cycle of write transfer
//写
always@(posedge PCLK or negedge PRESETn)begin
	if(~PRESETn)begin
	
	end
	else begin
		if(write_enable)begin
			System_reg[PADDR] <= PWDATA;
		end
		else begin
			if(System_reg[0][0]) System_reg[0][0] <= 1'b0;
			if(System_reg[0][1]) System_reg[0][1] <= 1'b0;
		end
		System_reg[4][3:0]   <= TCP_state ;//状态机监控
		System_reg[6]        <= Eth_speed_latch;//以太网速度
		System_reg[7]        <= Valid_data_speed_latch;
		System_reg[8]        <= {vga_fifo_rdusedw,store_speed_latch,frame_speed_latch};
		System_reg[9]        <= {vector_fifo_rdusedw,Eth_fifo_rdusedw};
		System_reg[10]       <= 32'haaaaaaaa;//测试
	end
end
//读
assign read_mux_word = System_reg[PADDR];
//----
assign Src_IP   = System_reg[1];
assign Des_IP   = System_reg[2];
assign Src_port = System_reg[3][15: 0];
assign Des_port = System_reg[3][31:16];
//===================================================
always@(posedge PCLK or negedge rst_n)begin
	if(~rst_n)begin
		Freq_meter <=28'd0;
	end
	else begin
		if(Freq_meter < 28'd50_000_001)begin
			Freq_meter <= Freq_meter +1'b1;
		end
		else begin
			Freq_meter <=28'd0;
		end
	end
end

always@(posedge PCLK or negedge rst_n)begin
	if(~rst_n)begin
		Freq_meter_sta <=2'd0;
	end
	else begin
		if(Freq_meter == 28'd50_000_000)begin
			Freq_meter_sta <= 2'd1;
		end
		else if(Freq_meter == 28'd50_000_001)begin
			Freq_meter_sta <= 2'd2;
		end
		else begin
			Freq_meter_sta <= 2'd0;
		end
	end
end
//===================================================
//SMC
//===================================================
reg task_start=0,W_R,IN_data_valid,TX_EN;
reg [ 4:0] Address;
reg [15:0] W_value;
wire [15:0] R_value;
wire OUT_data_valid,SMC_ready,RMII_ready;

SMC SMC_inst(
  .CLK_50M(clk),
  .rst_n(rst_n),
  
  .W_R(W_R),
  .address(Address),
  .IN_data_valid(IN_data_valid),
  
  .W_value(W_value),
  .R_value(R_value),
  .OUT_data_valid(OUT_data_valid),
  
  .SMC_ready(SMC_ready),  
  .MDC(MDC),
  .MDIO(MDIO)
);
//==============================================
//TCP 
//==============================================

TCP TCP_inst(
    .CLK_50M(clk),
	.reset_n(rst_n  ),
	.Src_IP  (Src_IP),
	.Des_IP  (Des_IP),
	.Src_port_(Src_port),
	.Des_port(Des_port),
	.e_reset(e_reset),
	.e_txc  (e_txc),
	.TX_EN  (TX_EN |   System_reg[0][1] ),
	.e_gtxc (e_gtxc), 
	.e_rxc  (e_rxc),
	.e_rxd  (e_rxd),
    .e_rxdv (e_rxdv),
	.e_rxer (e_rxer),
	.e_txen (e_txen),
	.e_txd  (e_txd),
	.e_txer (e_txer),
	//------------------
	.Eth_fifo_rdclk  (~Decoder_clk     ),//50M 下降沿出数据
	.Eth_fifo_rden   (Eth_fifo_rden   ),
	.Eth_fifo_rddata (Eth_fifo_rddata ),
	.Eth_fifo_rdempty(Eth_fifo_rdempty),
	.Eth_fifo_rdusedw(Eth_fifo_rdusedw),
	//---------------------
	.Freq_meter_sta  (Freq_meter_sta  ),
	.Eth_speed_latch (Eth_speed_latch ),
	.Valid_data_speed_latch(Valid_data_speed_latch),
    .seg_sel  (seg_sel   ),
    .seg_data (seg_data  ),	
	.TCP_state(TCP_state )    
);
//Eth_fifo_rden延时
always@(negedge Decoder_clk or negedge rst_n)begin
	if(rst_n== 1'b0)begin
		Eth_fifo_rden_next <=1'b0;
	end
	else begin
		Eth_fifo_rden_next <=Eth_fifo_rden;
	end
end

assign  Eth_fifo_rdvalid =  ~Eth_fifo_rdempty;
assign  Eth_fifo_rden    =  fifo_data_req & Eth_fifo_rdvalid;
//----------------------------------------------------------
//jpeg解码
//----------------------------------------------------------
fre_meter fre_meter_inst02(
	.CLK_50M       (clk               ),
	.reset_n       (rst_n             ),
	.clk           (frame_vsync       ),
	.speed_latch   (frame_speed_latch ),
	.Freq_meter_sta(Freq_meter_sta    ) 
);

jpeg_core jpeg_core_inst(

    .clk_i            (Decoder_clk            ),
	.rst_i            (~rst_n                 ),
	.inport_valid_i   (Eth_fifo_rden_next     ),//输入有效
	.inport_data_i    (Eth_fifo_rddata        ),//输入数据
	.inport_last_i    (1'b0                   ),
	.outport_accept_i (1'b1                   ),
     // Outputs
	.inport_accept_o  (fifo_data_req          ),//请求总线数据
	.outport_valid_o  (sdram_wr_en            ),//解码器输出有效
	.outport_width_o  (                       ),
	.outport_height_o (                       ),
	.outport_pixel_x_o(jpeg_core_pixel_x      ),
	.outport_pixel_y_o(jpeg_core_pixel_y      ),
	.outport_pixel_r_o(jpeg_core_pixel_r      ),
	.outport_pixel_g_o(jpeg_core_pixel_g      ),
	.outport_pixel_b_o(jpeg_core_pixel_b      ),
	.idle_o           (                       ),
    .frame_vsync      (                    )//______
	                                           //      |________
);
//测频
assign frame_vsync = (jpeg_core_pixel_x==5)&&
                     (jpeg_core_pixel_y==5)&&
					 (sdram_wr_en      ==1) ;
assign jpeg_core_addr = jpeg_core_pixel_y*16'd640+jpeg_core_pixel_x;
assign jpeg_core_data = { jpeg_core_pixel_r[7:3],
						  jpeg_core_pixel_g[7:2],
						  jpeg_core_pixel_b[7:3]};
//----------------------------------------------------
//RGB888_YCbCr444
//----------------------------------------------------
VIP_RGB888_YCbCr444 VIP_RGB888_YCbCr444_inst(

	//global clock
	.clk            (Decoder_clk),  				
	.rst_n          (rst_n      ),			

	//CMOS rgb888 data input
	.per_frame_vsync(frame_vsync         ),
	.per_frame_clken(sdram_wr_en         ),	
    .per_frame_addr (jpeg_core_addr[23:0]),
	.per_img_red    (jpeg_core_pixel_r   ),		
	.per_img_green  (jpeg_core_pixel_g   ),		
	.per_img_blue   (jpeg_core_pixel_b   ),	
    .Y_up           (System_reg[4][15: 8]),
    .Y_down			(System_reg[4][23:16]),	
	//CMOS YCbCr444 data output
	.post_frame_vsync(),	
	.post_frame_clken(post_frame_clken),	
	.post_frame_addr (post_frame_addr),
	.cmos_mask_data  (cmos_mask_data),
    .post_img_Y (),			
    .post_img_Cb(),		
    .post_img_Cr()	
);


//清空屏幕
always @ (posedge Decoder_clk or negedge rst_n)begin
	if(~rst_n)begin
		CLC_state <= CLC_IDLE;
		CLC_ing   <= 1'b0;
		CLC_index <= 24'd0;
	end
    else  begin
		case(CLC_state)
			CLC_IDLE:begin
				if(0)begin
					CLC_state <= CLC_RUN;
					CLC_ing   <= 1'b1;
				end
				else begin
					CLC_index <= 24'd0;
				end
			end
			CLC_RUN:begin
				if(CLC_index < 640*480)begin
					CLC_index <= CLC_index +1'b1;
				end
				else begin
					CLC_state <= CLC_END;
				end
			end
			CLC_END:begin
				CLC_ing   <= 1'b0;
				CLC_state <= CLC_IDLE;
				CLC_index <= 24'd0;
			end
			default:begin
				CLC_state <= CLC_IDLE;
			end
		endcase
	end
end 


//assign sdram_wr_data  = {jpeg_core_addr[23:0],jpeg_core_data[15:0]};
assign sdram_wr_data  = {post_frame_addr[23:0],cmos_mask_data[15:0]};


assign wr_data = CLC_ing?{CLC_index,16'hffff}:sdram_wr_data;
assign wr_en   = CLC_ing?{1'b1}:post_frame_clken;// sdram_wr_en
//--------------------------------------------------
//SDRAM
//--------------------------------------------------
sdram_top sdram_top_inst(
	.ref_clk(sdram_sys_clk ),                  //sdram 控制器参考时钟
	.out_clk(clk_100m_shift),                  //用于输出的相位偏移时钟
	.rst_n  (rst_n         ),                  //系统复位
    
    //用户写端口			
	.wr_clk       ( Decoder_clk     ),  
	.wr_en        ( wr_en           ),//sdram_wr_en|CLC_ing; post_frame_clken|CLC_ing
	.wr_data      ( wr_data         ),//40bit 
    
    //用户读端口
	.rd_clk     (vga_clk        ),  //读端口FIFO: 读时钟
	.rd_en      (vga_data_req   ),  //读端口FIFO: 读使能
	.rd_data    (vga_data       ),  //读端口FIFO: 读数据
	.rd_min_addr(24'd0          ),  //读SDRAM的起始地址
	.rd_max_addr(24'd640*24'd480),  //读SDRAM的结束地址
	.rd_len     (10'd512        ),  //从SDRAM中读数据时的突发长度
	.rd_load    (vsync_vga      ),        
    
    //用户控制端口  
	.sdram_read_valid(1'b1),      //SDRAM 读使能
	.sdram_init_done (),          //SDRAM 初始化完成标志
    
	//SDRAM 芯片接口
	.sdram_clk  (sdram_clk  ),               //SDRAM 芯片时钟
	.sdram_cke  (sdram_cke  ),               //SDRAM 时钟有效
	.sdram_cs_n (sdram_cs_n ),               //SDRAM 片选
	.sdram_ras_n(sdram_ras_n),              //SDRAM 行有效
	.sdram_cas_n(sdram_cas_n),              //SDRAM 列有效
	.sdram_we_n (sdram_we_n ),               //SDRAM 写有效
	.sdram_ba   (sdram_ba   ),                 //SDRAM Bank地址
	.sdram_addr (sdram_addr ),               //SDRAM 行/列地址
	.sdram_data (sdram_dq   ),               //SDRAM 数据
	.sdram_dqm  (sdram_dqm  ),                //SDRAM 数据掩码
	.sdram_store(sdram_store),
	.vector_fifo_rdusedw(vector_fifo_rdusedw),
	.vga_fifo_rdusedw   (vga_fifo_rdusedw   )
);

fre_meter fre_meter_inst03(
	.CLK_50M       (clk               ),
	.reset_n       (rst_n             ),
	.clk           (sdram_store       ),
	.speed_latch   (store_speed_latch ),
	.Freq_meter_sta(Freq_meter_sta    ) 
);

video_pll video_pll_m0(
	.inclk0(clk),
	.c0(vga_clk)    //25M
);  
vga_driver	vga_driver_inst(
	.clk		 		(vga_clk			),		//25Mhz
	.rst_n				(rst_n              ),
	.img_data			(vga_data    		),  //从FIFO中读出数据
	.img_data_req		(vga_data_req		),  //读FIFO使能
	
	.read_req           (vsync_vga          ),
	.read_req_ack       ( 1'b1              ),
	
	.Cursor_x           (Cursor_x           ),
	.Cursor_y           (Cursor_y           ),
	.X                  (X                  ) ,
	.Y                  (Y                  ) ,
	.data_vaild			(per_frame_clken	),
	.vcnt				(vcnt				),
	.hcnt				(hcnt				),
	.hsync				(per_frame_href     ),
	.vsync				(per_frame_vsync    ),
	.vga_data       	(img1_data   	    ),
	.vga_data2			(img2_data			)
);
assign 	BIT_IMG = (((img2_data - img1_data+10)>System_reg[4][31:24]))? 1'b1 : 1'b0; 

//腐蚀
VIP_Bit_Erosion_Detector u2_VIP_Bit_Erosion_Detector (
    .clk             (vga_clk         ), 
    .rst_n           (rst_n           ), 
    .per_frame_vsync (per_frame_vsync ), //
    .per_frame_href  (per_frame_href  ), //
    .per_frame_clken (per_frame_clken ), //
    .per_img_Bit     (BIT_IMG         ), //
    .post_frame_vsync(per_frame_vsync_Erosion ), 
    .post_frame_href (per_frame_href_Erosion  ), 
    .post_frame_clken(per_frame_clken_Erosion ), 
    .post_img_Bit    (   BIT                 )//低有效
);
//膨胀
VIP_Bit_Dilation_Detector u_VIP_Bit_Dilation_Detector (
    .clk             (vga_clk        ), 
    .rst_n           (rst_n          ), 
    .per_frame_vsync (per_frame_vsync_Erosion), //per_frame_vsync_Erosion
    .per_frame_href  (per_frame_href_Erosion ), // per_frame_href_Erosion
    .per_frame_clken (per_frame_clken_Erosion), // per_frame_clken_Erosion
    .per_img_Bit     (BIT            ), 
    .post_frame_vsync(), 
    .post_frame_href (), 
    .post_frame_clken(post_frame_clken_Erosion), 
    .post_img_Bit    (   vga_bit    )
);	

position u_position (
    .clk		(vga_clk		    	 ), 
    .rst_n		(rst_n                   ), 
    .ie			(post_frame_clken_Erosion), 
    .hcnt		(hcnt					), 
    .vcnt		(vcnt					), 
    .idat		(vga_bit				), 
	.vidon		(vidon					)
);
//------------------------------------------------------------
//鼠标绘制
//------------------------------------------------------------
CH9350 CH9350_inst(

	.CLK_50M    (clk        ),
	.rst_n      (rst_n      ),
	.CH9350_TXD (CH9350_TXD ),
	.Mouse_key  (Mouse_key  ),
	.L_up       (L_up       ),
	.L_down     (L_down     ),
	.M_up       (        ),
	.M_down     (        ),
	.R_up       (        ),
	.R_down     (R_down  ),
	.Mouse_x    ( ),
	.Mouse_y    ( ),
	.Cursor_x   (Cursor_x),
	.Cursor_y   (Cursor_y),
	.Mouse_wheel()
);
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		display <= 1'b1;
	end
	else begin
		if(L_down)begin
			x1 <= Cursor_x;
			y1 <= Cursor_y;
		end
	
		if(L_up)begin
			x2 <= Cursor_x;
			y2 <= Cursor_y;
		end
		if(R_down)  display <= ~display;
	end
end
box box_inst(
	.CLK       ( clk     ),
	.rst_n     (rst_n    ),
	.display_en(display  ),
	.X         (X        ),
	.Y         (Y        ),
	.x1        (x1       ),
	.y1        (y1       ),
	.x2        (Mouse_key[0]?Cursor_x:x2),
	.y2        (Mouse_key[0]?Cursor_y:y2),
	.out_en    (out_en   )
);

assign vga_out_vs	= per_frame_vsync;
assign vga_out_hs	= per_frame_href ;
assign vga_out_r    = (out_en)?{5'b11111 }:{((vidon)?img1_data[7:3] : 5'b00000 )};
assign vga_out_g    = (out_en)?{6'b000000}:{((vidon)?img1_data[7:2] : 6'b111111)};
assign vga_out_b    = (out_en)?{5'b00000 }:{((vidon)?img1_data[7:3] : 5'b00000 )};

//===================================================
//蜂鸣器控制
//===================================================
reg  [23:0]  Div_content  ;
reg          wire_2Hz;
reg  [15:0]  Beep_time;
reg          Beep_on;
wire         Capture;
assign       Capture  = out_en && (~vidon);
always@(posedge clk or negedge rst_n)begin
	if(~rst_n)begin
		Div_content <= 24'd0;
	end 
	else begin
		if(Div_content < 12500000-1)begin
			Div_content <= Div_content +1'b1;
		end
		else begin
			Div_content <= 24'd0;
			wire_2Hz    <= ~wire_2Hz;
		end
	end
end
//触发鸣叫
always@(posedge vga_clk or negedge rst_n)begin
	if(~rst_n)begin
		Beep_on <= 1'b0;
	end
	else begin
		if(Capture)     Beep_on <= 1'b1;
		else if(Beep_time > System_reg[5][7:0]) Beep_on <= 1'b0;
	end
end

//鸣叫时间
always@(posedge wire_2Hz or negedge rst_n)begin
	if(~rst_n)begin
		Beep_time <= 16'd0;
	end
	else begin
		if(Beep_on) Beep_time <= Beep_time +1'b1;
		else        Beep_time <= 16'd0;
	end
end
assign  BEEP  =  Beep_on;
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
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.rx_data                    (rx_data                  ),
	.rx_data_valid              (rx_data_valid            ),
	.rx_data_ready              (rx_data_ready            ),
	.rx_pin                     (uart_rx                  )
);

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(115200)
) uart_tx_inst
(
	.clk                        (clk                      ),
	.rst_n                      (rst_n                    ),
	.tx_data                    (tx_data                  ),
	.tx_data_valid              (tx_data_valid            ),
	.tx_data_ready              (tx_data_ready            ),
	.tx_pin                     (uart_tx                  )
);

//--------------------------------------------------------
//串口命令解析
//--------------------------------------------------------
always@(posedge clk or negedge rst_n)
  if(rst_n == 1'b0)begin 
    //LED <= 4'b1111;
	IN_data_valid  <=1'b0;
	TX_EN          <= 1'b0;
  end
  else begin
    if(task_start)begin
	   case(RAM_UART[0])
	     8'h52:begin                                          //SMC读
		    W_R     <=   1'b1 ;
			Address <= RAM_UART[2][4:0];
			IN_data_valid <= 1'b1;
		 end
		 8'h57:begin                                          //SMC写
		    W_R           <= 1'b0;
	        Address       <= RAM_UART[2][4:0];
	        W_value       <= {RAM_UART[3],RAM_UART[4]};
	        IN_data_valid <= 1'b1;
		 end
		 8'h53:begin                                          //启动TCP连接                      
		    TX_EN <= 1'b1;
		    //LED   <= ~LED;
		 end
		 8'h4c:begin
		    //LED <= RAM_UART[1][3:0];
		 end
	   endcase 
    end
    else begin //清除标志位
	  IN_data_valid <= 1'b0;
	  TX_EN         <= 1'b0;
	end
  end  
//===========================================
//串口发送 仲裁
//===========================================
always@(posedge clk or negedge rst_n)
begin
	if(rst_n == 1'b0)
	begin
		tx_data <= 8'd0;
		TX_source <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else begin
		case(TX_source)
			IDLE:begin
				tx_cnt        <= 8'd0;
				tx_data_valid <= 1'b0;
				if(OUT_data_valid)begin               //SMC数据输出
					TX_source <= SMC;
				end
				else if(Eth_fifo_rdusedw!=0)begin     //接受的以太网数据		 
					//TX_source <= Eth_FIFO;
					TX_source <= IDLE;
				end
				else begin                            //其他
					TX_source <= IDLE;
				end
			end
			SMC:begin
				if(tx_data_ready==1 && tx_data_valid==0)
					case(tx_cnt)
						8'd0:begin
							tx_data <= R_value[15:8];
							tx_data_valid <= 1'b1;
							tx_cnt <= 8'd1; 
						end
						8'd1:begin
							tx_data <= R_value[7:0];
							tx_data_valid <= 1'b1;
							tx_cnt <= 8'd0;
							TX_source <= IDLE;
						end
						default:begin
							tx_data_valid <= 1'b0;
						end
					endcase
				else if(tx_data_valid)begin
					tx_data_valid <= 1'b0;//复位信号
				end
				else begin
					TX_source <= SMC;
				end
			end
			default:begin
			
			end
		endcase
	end
end
//--------------------------------------------------------
//串口数据存储地址处理
//--------------------------------------------------------
always @ (posedge clk or negedge rst_n)//每次触发间隔8*424个CLK
    if(~rst_n)begin
        wr_addr = 0;  //指针复位
		task_start <= 1'h0;
	end
    else 
	  if(rx_data_valid)begin
		if(rx_data==8'h40)wr_addr <= 0;//@
		else wr_addr<=wr_addr+1'h1 ;  
	  
	    if(rx_data==8'h23)task_start <= 1'h1;//#
	  end 
	  else task_start <= 1'h0;
//------------------------------------------------------------------------------
// RAM_UART
//------------------------------------------------------------------------------
always @ (posedge clk)begin 
    if(rx_data_valid)
	  begin
        RAM_UART[wr_addr] <= rx_data;
	  end 
end

endmodule
