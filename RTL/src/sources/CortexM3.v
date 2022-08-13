//ITCM 65536 * 32bit
//     64KB  * 32bit
module CortexM3 (
    input       wire            CLK50m,
    input       wire            RSTn,

    // SWD
    inout       wire            SWDIO,
    input       wire            SWCLK,
	
    // UART
    output      wire            TXD,
    input       wire            RXD,
	//BEEP
	output      wire            BEEP    ,
	//GPIO
	inout       wire [15:0]     L2_AHB_GPIO,
	//-----------------------------------------
	//Ethernet
	input       wire            e_txc,
	input       wire            e_rxc,
	input       wire            e_rxdv,
	input       wire            e_rxer,
	input       wire [3:0]      e_rxd,
	output      wire            e_reset,
	output      wire            e_gtxc,
	output      wire            e_txen,
	output      wire            e_txer,
	output      wire [3:0]      e_txd,
	//UART  
	input       wire            uart_rx,
	output      wire            uart_tx,
	input       wire            CH9350_TXD,
	output      wire            CH9350_RXD,
	//SMI
	output      wire            MDC,
	inout       wire            MDIO,
	//VGA
	output      wire            vga_out_hs,        //vga horizontal synchronization
	output      wire            vga_out_vs,        //vga vertical synchronization
	output      wire [4:0]      vga_out_r,         //vga red
	output      wire [5:0]      vga_out_g,         //vga green
	output      wire [4:0]      vga_out_b,        //vga blue
	//SDRAM_port
	output      wire            sdram_clk,         //sdram clock
	output      wire            sdram_cke,         //sdram clock enable
	output      wire            sdram_cs_n,        //sdram chip select
	output      wire            sdram_we_n,        //sdram write enable
	output      wire            sdram_cas_n,       //sdram column address strobe
	output      wire            sdram_ras_n,       //sdram row address strobe
	output      wire [ 1:0]     sdram_dqm,         //sdram data enable
	output      wire [ 1:0]     sdram_ba,          //sdram bank address
	output      wire [12:0]     sdram_addr,        //sdram address
	inout       wire [15:0]     sdram_dq ,
	//数码管
	output      wire [2:0]      seg_sel, 
	output      wire [7:0]      seg_data     
);
//------------------------------------------------------------------------------
// SYSTEM
//------------------------------------------------------------------------------
//wire [15:0]     L2_AHB_GPIO;
wire    clk;
assign  clk=CLK50m;   //没有分频直接给系统时钟
wire    gpio_int;
//assign  gpio_int  =  ~(PORTIN[2] && PORTIN[3] && PORTIN[4] && PORTIN[5] && PORTIN[6] );
//------------------------------------------------------------------------------
// DEBUG IOBUF 
//------------------------------------------------------------------------------
wire            SWDO;
wire            SWDOEN;
wire            SWDI;
assign SWDI =   SWDIO;
assign SWDIO = (SWDOEN) ?  SWDO : 1'bz;

//------------------------------------------------------------------------------
// RESET
//------------------------------------------------------------------------------
wire            SYSRESETREQ;
reg             cpuresetn;

always @(posedge clk or negedge RSTn)begin    //复位引脚下降沿
    if (~RSTn)               //如果手动按下复位按键
        cpuresetn <= 1'b0;   //寄存器记录 复位标识
    else if (SYSRESETREQ)    //系统请求服务
        cpuresetn <= 1'b0;   //寄存器记录 复位标识
    else 
        cpuresetn <= 1'b1;   //没有复位发生
end

//------------------------------------------------------------------------------
// DEBUG CONFIG
//------------------------------------------------------------------------------
wire            CDBGPWRUPREQ;
reg             CDBGPWRUPACK;

always @(posedge clk or negedge RSTn)begin
    if (~RSTn)                     //如果手动按下复位按键
        CDBGPWRUPACK <= 1'b0;
    else 
        CDBGPWRUPACK <= CDBGPWRUPREQ;
end

//------------------------------------------------------------------------------
// INTERRUPT 
//------------------------------------------------------------------------------

wire    [239:0] IRQ;

//------------------------------------------------------------------------------
// CORE BUS
//------------------------------------------------------------------------------

// CPU I-Code 
wire    [31:0]  HADDRI;//取指令地址总线
wire    [31:0]  HRDATAI;//数据传输线
wire    [1:0]   HTRANSI;//传输类型
wire    [2:0]   HSIZEI;//传输大小
wire    [2:0]   HBURSTI;//脉冲长度
wire    [3:0]   HPROTI;//传输保护
wire            HREADYI;//准备好
wire    [1:0]   HRESPI;//传输响应

// CPU D-Code 
wire    [31:0]  HADDRD;//读写地址
wire    [31:0]  HRDATAD;//读取数据到内核
wire    [31:0]  HWDATAD;//写数据到SRAM
wire    [1:0]   HTRANSD;//传输类型
wire    [2:0]   HSIZED;//传输大小
wire    [2:0]   HBURSTD;//脉冲长度
wire    [3:0]   HPROTD;//传输保护
wire            HWRITED;//控制信号线-写数据
wire            HREADYD;//准备好
wire    [1:0]   HRESPD; //传输响应
wire    [1:0]   HMASTERD;//总线主机

// CPU System bus 
wire    [31:0]  HADDRS;
wire    [31:0]  HWDATAS;
wire    [31:0]  HRDATAS;
wire    [1:0]   HTRANSS;
wire            HWRITES;
wire    [2:0]   HSIZES;
wire    [2:0]   HBURSTS;
wire    [3:0]   HPROTS;
wire            HREADYS;
wire    [1:0]   HRESPS;
wire    [1:0]   HMASTERS;
wire            HMASTERLOCKS;//主机锁


//------------------------------------------------------------------------------
// Instantiate Cortex-M3 processor 
//------------------------------------------------------------------------------

cortexm3ds_logic ulogic(
    // PMU
    .ISOLATEn                           (1'b1),//隔离内核电源域
    .RETAINn                            (1'b1),//在掉电时保持内核状态

    // RESETS
    .PORESETn                           (RSTn),     //手动复位引脚，低电平有效
    .SYSRESETn                          (cpuresetn),//寄存器类型，低电平有效
    .SYSRESETREQ                        (SYSRESETREQ),//系统请求复位，高电平有效

    .RSTBYPASS                          (1'b0),      //正常CPU时钟停止工作
    .CGBYPASS                           (1'b0),      //选择调试时钟给CPU
    .SE                                 (1'b0),

    // CLOCKS
    .FCLK                               (clk),  // Free running clock - NVIC, SysTick, debug
    .HCLK                               (clk),  // System clock - AHB, processor
    .TRACECLKIN                         (1'b0),

    // SYSTICK
    .STCLK                              (1'b0),  //系统定时器时钟
    .STCALIB                            (26'b0),  //系统定时器校准时钟
    .AUXFAULT                           (32'b0),  // Auxiliary Fault Status Register inputs (1 cycle pulse)

    // CONFIG - SYSTEM
    .BIGEND                             (1'b0),   // Big Endian - select when exiting system reset
    .DNOTITRANS                         (1'b1),
    
    // SWJDAP
    .nTRST                              (1'b1),   // JTAG TAP Reset
    .SWDITMS                            (SWDI),  // SW Debug Data In / JTAG Test Mode Select
    .SWCLKTCK                           (SWCLK),  // SW/JTAG Clock
    .TDI                                (1'b0),  // JTAG TAP Data In / Alternative input function
    .CDBGPWRUPACK                       (CDBGPWRUPACK),  // Debug Power Domain up acknowledge
    .CDBGPWRUPREQ                       (CDBGPWRUPREQ),
    .SWDO                               (SWDO),
    .SWDOEN                             (SWDOEN),

    // IRQS
    .INTISR                             (IRQ),  //中断线 [239:0]
    .INTNMI                             (1'b0), // Non-maskable Interrupt 
    
    // I-CODE BUS
    .HREADYI                            (HREADYI),
    .HRDATAI                            (HRDATAI),
    .HRESPI                             (HRESPI),
    .IFLUSH                             (1'b0),  //缓冲区刷新  buffer flush
    .HADDRI                             (HADDRI),
    .HTRANSI                            (HTRANSI),//传输类型
    .HSIZEI                             (HSIZEI),
    .HBURSTI                            (HBURSTI),
    .HPROTI                             (HPROTI),

    // D-CODE BUS
    .HREADYD                            (HREADYD),
    .HRDATAD                            (HRDATAD),
    .HRESPD                             (HRESPD),
    .EXRESPD                            (1'b0),  
    .HADDRD                             (HADDRD),
    .HTRANSD                            (HTRANSD),
    .HSIZED                             (HSIZED),
    .HBURSTD                            (HBURSTD),
    .HPROTD                             (HPROTD),
    .HWDATAD                            (HWDATAD),
    .HWRITED                            (HWRITED),
    .HMASTERD                           (HMASTERD),

    // SYSTEM BUS
    .HREADYS                            (HREADYS),
    .HRDATAS                            (HRDATAS),
    .HRESPS                             (HRESPS),
    .EXRESPS                            (1'b0),
    .HADDRS                             (HADDRS),
    .HTRANSS                            (HTRANSS),
    .HSIZES                             (HSIZES),
    .HBURSTS                            (HBURSTS),
    .HPROTS                             (HPROTS),
    .HWDATAS                            (HWDATAS),
    .HWRITES                            (HWRITES),
    .HMASTERS                           (HMASTERS),
    .HMASTLOCKS                         (HMASTERLOCKS),

    // SLEEP
    .RXEV                               (1'b0),  //接收时间输入
    .SLEEPHOLDREQn                      (1'b1),   // Extend Sleep request
    .SLEEPING                           (    ),  
    
    // EXTERNAL DEBUG REQUEST  外部调试请求
    .EDBGRQ                             (1'b0),
    .DBGRESTART                         (1'b0),
    
    // DAP HMASTER OVERRIDE
    .FIXMASTERTYPE                      (1'b0),//越权访问

    // WIC
    .WICENREQ                           (1'b0), //唤醒中断控制器

    // TIMESTAMP INTERFACE
    .TSVALUEB                           (48'b0),

    // CONFIG - DEBUG
    .DBGEN                              (1'b1),  // Halting Debug Enable
    .NIDEN                              (1'b1),   // Non-invasive debug enable for ETM
    .MPUDISABLE                         (1'b0)    // Disable MPU functionality
);

//------------------------------------------------------------------------------
// AHB L1 BUS MATRIX
//------------------------------------------------------------------------------

// DMA MASTER  DMA主机
wire    [31:0]  HADDRDM;   
wire    [1:0]   HTRANSDM;
wire            HWRITEDM;
wire    [2:0]   HSIZEDM;
wire    [31:0]  HWDATADM;
wire    [2:0]   HBURSTDM;
wire    [3:0]   HPROTDM;
wire            HREADYDM;
wire    [31:0]  HRDATADM;
wire    [1:0]   HRESPDM;
wire    [1:0]   HMASTERDM;
wire            HMASTERLOCKDM;

assign  HADDRDM         =   32'b0;
assign  HTRANSDM        =   2'b0;
assign  HWRITEDM        =   1'b0;
assign  HSIZEDM         =   3'b0;
assign  HWDATADM        =   32'b0;
assign  HBURSTDM        =   3'b0;
assign  HPROTDM         =   4'b0;
assign  HMASTERDM       =   2'b0;
assign  HMASTERLOCKDM   =   1'b0;

// RESERVED MASTER  //保留主机
wire    [31:0]  HADDRR;
wire    [1:0]   HTRANSR;
wire            HWRITER ;
wire            WRITER;
wire    [2:0]   HSIZER;
wire    [31:0]  HWDATAR;
wire    [2:0]   HBURSTR;
wire    [3:0]   HPROTR;
wire            HREADYR;
wire    [31:0]  HRDATAR;
wire    [1:0]   HRESPR;
wire    [1:0]   HMASTERR;
wire            HMASTERLOCKR;

assign  HADDRR          =   32'b0;
assign  HTRANSR         =   2'b0;
assign  HWRITER         =   1'b0;
assign  HSIZER          =   3'b0;
assign  HWDATAR         =   32'b0;
assign  HBURSTR         =   3'b0;
assign  HPROTR          =   4'b0;
assign  HMASTERR        =   2'b0;
assign  HMASTERLOCKR    =   1'b0;

wire    [31:0]  HADDR_AHBL1P0;
wire    [1:0]   HTRANS_AHBL1P0;
wire            HWRITE_AHBL1P0;
wire    [2:0]   HSIZE_AHBL1P0;
wire    [31:0]  HWDATA_AHBL1P0;
wire    [2:0]   HBURST_AHBL1P0;
wire    [3:0]   HPROT_AHBL1P0;
wire            HREADY_AHBL1P0;
wire    [31:0]  HRDATA_AHBL1P0;
wire    [1:0]   HRESP_AHBL1P0;
wire            HREADYOUT_AHBL1P0;
wire            HSEL_AHBL1P0;
wire    [1:0]   HMASTER_AHBL1P0;
wire            HMASTERLOCK_AHBL1P0;

wire    [31:0]  HADDR_AHBL1P1;
wire    [1:0]   HTRANS_AHBL1P1;
wire            HWRITE_AHBL1P1;
wire    [2:0]   HSIZE_AHBL1P1;
wire    [31:0]  HWDATA_AHBL1P1;
wire    [2:0]   HBURST_AHBL1P1;
wire    [3:0]   HPROT_AHBL1P1;
wire            HREADY_AHBL1P1;
wire    [31:0]  HRDATA_AHBL1P1;
wire    [1:0]   HRESP_AHBL1P1;
wire            HREADYOUT_AHBL1P1;
wire            HSEL_AHBL1P1;
wire    [1:0]   HMASTER_AHBL1P1;
wire            HMASTERLOCK_AHBL1P1;

wire    [31:0]  HADDR_AHBL1P2;
wire    [1:0]   HTRANS_AHBL1P2;
wire            HWRITE_AHBL1P2;
wire    [2:0]   HSIZE_AHBL1P2;
wire    [31:0]  HWDATA_AHBL1P2;
wire    [2:0]   HBURST_AHBL1P2;
wire    [3:0]   HPROT_AHBL1P2;
wire            HREADY_AHBL1P2;
wire    [31:0]  HRDATA_AHBL1P2;
wire    [1:0]   HRESP_AHBL1P2;
wire            HREADYOUT_AHBL1P2;
wire            HSEL_AHBL1P2;
wire    [1:0]   HMASTER_AHBL1P2;
wire            HMASTERLOCK_AHBL1P2;

wire    [31:0]  HADDR_AHBL1P3;
wire    [1:0]   HTRANS_AHBL1P3;
wire            HWRITE_AHBL1P3;
wire    [2:0]   HSIZE_AHBL1P3;
wire    [31:0]  HWDATA_AHBL1P3;
wire    [2:0]   HBURST_AHBL1P3;
wire    [3:0]   HPROT_AHBL1P3;
wire            HREADY_AHBL1P3;
wire    [31:0]  HRDATA_AHBL1P3;
wire    [1:0]   HRESP_AHBL1P3;
wire            HREADYOUT_AHBL1P3;
wire            HSEL_AHBL1P3;
wire    [1:0]   HMASTER_AHBL1P3;
wire            HMASTERLOCK_AHBL1P3;

wire    [31:0]  HADDR_AHBL1P4;
wire    [1:0]   HTRANS_AHBL1P4;
wire            HWRITE_AHBL1P4;
wire    [2:0]   HSIZE_AHBL1P4;
wire    [31:0]  HWDATA_AHBL1P4;
wire    [2:0]   HBURST_AHBL1P4;
wire    [3:0]   HPROT_AHBL1P4;
wire            HREADY_AHBL1P4;
wire    [31:0]  HRDATA_AHBL1P4;
wire    [1:0]   HRESP_AHBL1P4;
wire            HREADYOUT_AHBL1P4;
wire            HSEL_AHBL1P4;
wire    [1:0]   HMASTER_AHBL1P4;
wire            HMASTERLOCK_AHBL1P4;

L1AhbMtx    L1AhbMtx(
    .HCLK                               (clk),      //系统时钟
    .HRESETn                            (cpuresetn),//寄存器类型，CPU复位，低电平有效
    .REMAP                              (4'b0),  // System address remapping control

     // I-CODE
    .HSELS1                             (1'b1),//nmeet
    .HADDRS1                            (HADDRI),
    .HTRANSS1                           (HTRANSI),
    .HWRITES1                           (1'b0),  
    .HSIZES1                            (HSIZEI),
    .HBURSTS1                           (HBURSTI),
    .HPROTS1                            (HPROTI),
    .HMASTERS1                          (4'b0),//主机
    .HWDATAS1                           (32'b0),
    .HMASTLOCKS1                        (1'b0),
    .HREADYS1                           (HREADYI),
    .HAUSERS1                           (32'b0),   //nmeet
    .HWUSERS1                           (32'b0),   //nmeet
    .HRDATAS1                           (HRDATAI),
    .HREADYOUTS1                        (HREADYI),  //nmeet
    .HRESPS1                            (HRESPI),
    .HRUSERS1                           (),
     // D-CODE
    .HSELS0                             (1'b1),
    .HADDRS0                            (HADDRD),
    .HTRANSS0                           (HTRANSD),
    .HWRITES0                           (HWRITED),
    .HSIZES0                            (HSIZED),
    .HBURSTS0                           (HBURSTD),
    .HPROTS0                            (HPROTD),
    .HMASTERS0                          ({2'b0,HMASTERD}),
    .HWDATAS0                           (HWDATAD),
    .HMASTLOCKS0                        (1'b0),
    .HREADYS0                           (HREADYD),
    .HAUSERS0                           (32'b0),
    .HWUSERS0                           (32'b0),
    .HREADYOUTS0                        (HREADYD),
    .HRESPS0                            (HRESPD),
    .HRUSERS0                           (),
    .HRDATAS0                           (HRDATAD),
	//SYS-BUS
    .HSELS2                             (1'b1),
    .HADDRS2                            (HADDRS),
    .HTRANSS2                           (HTRANSS),
    .HWRITES2                           (HWRITES),
    .HSIZES2                            (HSIZES),
    .HBURSTS2                           (HBURSTS),
    .HPROTS2                            (HPROTS),
    .HMASTERS2                          ({2'b0,HMASTERS}),
    .HWDATAS2                           (HWDATAS),
    .HMASTLOCKS2                        (HMASTERLOCKS),
    .HREADYS2                           (HREADYS),
    .HAUSERS2                           (32'b0),
    .HWUSERS2                           (32'b0),
    .HREADYOUTS2                        (HREADYS),
    .HRESPS2                            (HRESPS),
    .HRUSERS2                           (),
    .HRDATAS2                           (HRDATAS),    

    .HSELS3                             (1'b1),
    .HADDRS3                            (HADDRDM),
    .HTRANSS3                           (HTRANSDM),
    .HWRITES3                           (HWRITEDM),
    .HSIZES3                            (HSIZEDM),
    .HBURSTS3                           (HBURSTDM),
    .HPROTS3                            (HPROTDM),
    .HMASTERS3                          ({2'b0,HMASTERDM}),
    .HWDATAS3                           (HWDATADM),
    .HMASTLOCKS3                        (HMASTERLOCKDM),
    .HREADYS3                           (1'b1),
    .HAUSERS3                           (32'b0),
    .HWUSERS3                           (32'b0),
    .HREADYOUTS3                        (HREADYDM),
    .HRESPS3                            (HRESPDM),
    .HRUSERS3                           (),
    .HRDATAS3                           (HRDATADM),

    .HSELS4                             (1'b1),
    .HADDRS4                            (HADDRR),
    .HTRANSS4                           (HTRANSR),
    .HWRITES4                           (HWRITER),
    .HSIZES4                            (HSIZER),
    .HBURSTS4                           (HBURSTR),
    .HPROTS4                            (HPROTR),
    .HMASTERS4                          ({2'b0,HMASTERR}),
    .HWDATAS4                           (HWDATAR),
    .HMASTLOCKS4                        (HMASTERLOCKR),
    .HREADYS4                           (1'b0),
    .HAUSERS4                           (32'b0),
    .HWUSERS4                           (32'b0),
    .HREADYOUTS4                        (HREADYR),
    .HRESPS4                            (HRESPR),
    .HRUSERS4                           (),
    .HRDATAS4                           (HRDATAR),
    //====================M=======================================
    .HSELM0                             (HSEL_AHBL1P0),//SRAM-ITCM
    .HADDRM0                            (HADDR_AHBL1P0),
    .HTRANSM0                           (HTRANS_AHBL1P0),
    .HWRITEM0                           (HWRITE_AHBL1P0),
    .HSIZEM0                            (HSIZE_AHBL1P0),
    .HBURSTM0                           (HBURST_AHBL1P0),
    .HPROTM0                            (HPROT_AHBL1P0),
    .HMASTERM0                          (HMASTER_AHBL1P0),
    .HWDATAM0                           (HWDATA_AHBL1P0),
    .HMASTLOCKM0                        (HMASTERLOCK_AHBL1P0),
    .HREADYMUXM0                        (HREADY_AHBL1P0),
    .HAUSERM0                           (),
    .HWUSERM0                           (),
    .HRDATAM0                           (HRDATA_AHBL1P0),
    .HREADYOUTM0                        (HREADYOUT_AHBL1P0),
    .HRESPM0                            (HRESP_AHBL1P0),
    .HRUSERM0                           (32'b0),

    .HSELM1                             (HSEL_AHBL1P1),//SRAM-DTCM
    .HADDRM1                            (HADDR_AHBL1P1),
    .HTRANSM1                           (HTRANS_AHBL1P1),
    .HWRITEM1                           (HWRITE_AHBL1P1),
    .HSIZEM1                            (HSIZE_AHBL1P1),
    .HBURSTM1                           (HBURST_AHBL1P1),
    .HPROTM1                            (HPROT_AHBL1P1),
    .HMASTERM1                          (HMASTER_AHBL1P1),
    .HWDATAM1                           (HWDATA_AHBL1P1),
    .HMASTLOCKM1                        (HMASTERLOCK_AHBL1P1),
    .HREADYMUXM1                        (HREADY_AHBL1P1),
    .HAUSERM1                           (),
    .HWUSERM1                           (),
    .HRDATAM1                           (HRDATA_AHBL1P1),
    .HREADYOUTM1                        (HREADYOUT_AHBL1P1),
    .HRESPM1                            (HRESP_AHBL1P1),
    .HRUSERM1                           (32'b0),
	//====================
    .HSELM2                             (HSEL_AHBL1P2),//TO APB
    .HADDRM2                            (HADDR_AHBL1P2),
    .HTRANSM2                           (HTRANS_AHBL1P2),
    .HWRITEM2                           (HWRITE_AHBL1P2),
    .HSIZEM2                            (HSIZE_AHBL1P2),
    .HBURSTM2                           (HBURST_AHBL1P2),
    .HPROTM2                            (HPROT_AHBL1P2),
    .HMASTERM2                          (HMASTER_AHBL1P2),
    .HWDATAM2                           (HWDATA_AHBL1P2),
    .HMASTLOCKM2                        (HMASTERLOCK_AHBL1P2),
    .HREADYMUXM2                        (HREADY_AHBL1P2),
    .HAUSERM2                           (),
    .HWUSERM2                           (),
    .HRDATAM2                           (HRDATA_AHBL1P2),
    .HREADYOUTM2                        (HREADYOUT_AHBL1P2),
    .HRESPM2                            (HRESP_AHBL1P2),
    .HRUSERM2                           (32'b0),

    .HSELM3                             (HSEL_AHBL1P3),//TO DDR4
    .HADDRM3                            (HADDR_AHBL1P3),
    .HTRANSM3                           (HTRANS_AHBL1P3),
    .HWRITEM3                           (HWRITE_AHBL1P3),
    .HSIZEM3                            (HSIZE_AHBL1P3),
    .HBURSTM3                           (HBURST_AHBL1P3),
    .HPROTM3                            (HPROT_AHBL1P3),
    .HMASTERM3                          (HMASTER_AHBL1P3),
    .HWDATAM3                           (HWDATA_AHBL1P3),
    .HMASTLOCKM3                        (HMASTERLOCK_AHBL1P3),
    .HREADYMUXM3                        (HREADY_AHBL1P3),
    .HAUSERM3                           (),
    .HWUSERM3                           (),
    .HRDATAM3                           (HRDATA_AHBL1P3),
    .HREADYOUTM3                        (HREADYOUT_AHBL1P3),
    .HRESPM3                            (HRESP_AHBL1P3),
    .HRUSERM3                           (32'b0),

    .HSELM4                             (HSEL_AHBL1P4),//TO AHB-AHB
    .HADDRM4                            (HADDR_AHBL1P4),
    .HTRANSM4                           (HTRANS_AHBL1P4),
    .HWRITEM4                           (HWRITE_AHBL1P4),
    .HSIZEM4                            (HSIZE_AHBL1P4),
    .HBURSTM4                           (HBURST_AHBL1P4),
    .HPROTM4                            (HPROT_AHBL1P4),
    .HMASTERM4                          (HMASTER_AHBL1P4),
    .HWDATAM4                           (HWDATA_AHBL1P4),
    .HMASTLOCKM4                        (HMASTERLOCK_AHBL1P4),
    .HREADYMUXM4                        (HREADY_AHBL1P4),
    .HAUSERM4                           (),
    .HWUSERM4                           (),
    .HRDATAM4                           (HRDATA_AHBL1P4),
    .HREADYOUTM4                        (HREADYOUT_AHBL1P4),
    .HRESPM4                            (HRESP_AHBL1P4),
    .HRUSERM4                           (32'b0),

    .SCANENABLE                         (1'b0),
    .SCANINHCLK                         (1'b0),
    .SCANOUTHCLK                        ()
);

//------------------------------------------------------------------------------
// AHB GPIO
//------------------------------------------------------------------------------
wire [15:0] PORTIN;
wire [15:0] PORTEN;
wire [15:0] PORTOUT;

assign PORTIN = L2_AHB_GPIO;
assign L2_AHB_GPIO[0] = (PORTEN[0]) ?  PORTOUT[0] : 1'bz;
assign L2_AHB_GPIO[1] = (PORTEN[1]) ?  PORTOUT[1] : 1'bz;
assign L2_AHB_GPIO[2] = (PORTEN[2]) ?  PORTOUT[2] : 1'bz;
assign L2_AHB_GPIO[3] = (PORTEN[3]) ?  PORTOUT[3] : 1'bz;
assign L2_AHB_GPIO[4] = (PORTEN[4]) ?  PORTOUT[4] : 1'bz;
assign L2_AHB_GPIO[5] = (PORTEN[5]) ?  PORTOUT[5] : 1'bz;
assign L2_AHB_GPIO[6] = (PORTEN[6]) ?  PORTOUT[6] : 1'bz;
assign L2_AHB_GPIO[7] = (PORTEN[7]) ?  PORTOUT[7] : 1'bz;
assign L2_AHB_GPIO[8] = (PORTEN[8]) ?  PORTOUT[8] : 1'bz;
assign L2_AHB_GPIO[9] = (PORTEN[9]) ?  PORTOUT[9] : 1'bz;
assign L2_AHB_GPIO[10] = (PORTEN[10]) ?  PORTOUT[10] : 1'bz;
assign L2_AHB_GPIO[11] = (PORTEN[11]) ?  PORTOUT[11] : 1'bz;
assign L2_AHB_GPIO[12] = (PORTEN[12]) ?  PORTOUT[12] : 1'bz;
assign L2_AHB_GPIO[13] = (PORTEN[13]) ?  PORTOUT[13] : 1'bz;
assign L2_AHB_GPIO[14] = (PORTEN[14]) ?  PORTOUT[14] : 1'bz;
assign L2_AHB_GPIO[15] = (PORTEN[15]) ?  PORTOUT[15] : 1'bz;

cmsdk_ahb_gpio GPIO(
    .HCLK(clk),
    .HRESETn(cpuresetn),
    .FCLK(clk),
    //input
    .HSEL(HSEL_AHBL1P4),
	.HADDR(HADDR_AHBL1P4),
	.HWDATA(HWDATA_AHBL1P4),
	
	.HREADY(HREADY_AHBL1P4),
	.HTRANS(HTRANS_AHBL1P4),
	.HSIZE(HSIZE_AHBL1P4),
	.HWRITE(HWRITE_AHBL1P4),
	
	.ECOREVNUM(4'h0),
	
	//output
	.HREADYOUT(HREADYOUT_AHBL1P4),
	.HRESP(HRESP_AHBL1P4),
	.HRDATA(HRDATA_AHBL1P4),
	//GPIO
	.PORTIN(PORTIN),
	.PORTOUT(PORTOUT),
	.PORTEN(PORTEN),
	.PORTFUNC(),
	.GPIOINT(),
	.COMBINT(gpio_int)
);
//------------------------------------------------------------------------------
// AHB to APB
//------------------------------------------------------------------------------
wire    [15:0]  PADDR;    
wire            PENABLE;  
wire            PWRITE;   
wire    [3:0]   PSTRB;    
wire    [2:0]   PPROT;    
wire    [31:0]  PWDATA;   
wire            PSEL;     
wire            APBACTIVE;                  
wire    [31:0]  PRDATA;   
wire            PREADY;  
wire            PSLVERR; 

cmsdk_ahb_to_apb #(
    .ADDRWIDTH                          (16),
    .REGISTER_RDATA                     (1),
    .REGISTER_WDATA                     (1)
)    ApbBridge  (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .PCLKEN                             (1'b1),
    .HSEL                               (HSEL_AHBL1P2),
    .HADDR                              (HADDR_AHBL1P2),//32bit
    .HTRANS                             (HTRANS_AHBL1P2),
    .HSIZE                              (HSIZE_AHBL1P2),
    .HPROT                              (HPROT_AHBL1P2),
    .HWRITE                             (HWRITE_AHBL1P2),
    .HREADY                             (HREADY_AHBL1P2),
    .HWDATA                             (HWDATA_AHBL1P2),
    .HREADYOUT                          (HREADYOUT_AHBL1P2),
    .HRDATA                             (HRDATA_AHBL1P2),
    .HRESP                              (HRESP_AHBL1P2[0]),        
    .PADDR                              (PADDR),//addr_reg  <= HADDR[ADDRWIDTH-1:2]; PADDR   = {addr_reg, 2'b00};
    .PENABLE                            (PENABLE),
    .PWRITE                             (PWRITE),
    .PSTRB                              (PSTRB),
    .PPROT                              (PPROT),
    .PWDATA                             (PWDATA),
    .PSEL                               (PSEL),
    .APBACTIVE                          (APBACTIVE),
    .PRDATA                             (PRDATA),
    .PREADY                             (PREADY),
    .PSLVERR                            (PSLVERR)                      
);

assign  HRESP_AHBL1P2[1]    =   1'b0;

wire            PSEL_APBP0;
wire            PREADY_APBP0;
wire    [31:0]  PRDATA_APBP0;
wire            PSLVERR_APBP0;

wire            PSEL_APBP1;
wire            PREADY_APBP1;
wire    [31:0]  PRDATA_APBP1;
wire            PSLVERR_APBP1;

cmsdk_apb_slave_mux #(
    .PORT0_ENABLE                       (1),
    .PORT1_ENABLE                       (1),
    .PORT2_ENABLE                       (0),
    .PORT3_ENABLE                       (0),
    .PORT4_ENABLE                       (0),
    .PORT5_ENABLE                       (0),
    .PORT6_ENABLE                       (0),
    .PORT7_ENABLE                       (0),
    .PORT8_ENABLE                       (0),
    .PORT9_ENABLE                       (0),
    .PORT10_ENABLE                      (0),
    .PORT11_ENABLE                      (0),
    .PORT12_ENABLE                      (0),
    .PORT13_ENABLE                      (0),
    .PORT14_ENABLE                      (0),
    .PORT15_ENABLE                      (0)
)   ApbSystem   (
    .DECODE4BIT                         (PADDR[15:12]),
    .PSEL                               (PSEL),

    .PSEL0                              (PSEL_APBP0),
    .PREADY0                            (PREADY_APBP0),
    .PRDATA0                            (PRDATA_APBP0),
    .PSLVERR0                           (PSLVERR_APBP0),
    
    .PSEL1                              (PSEL_APBP1),
    .PREADY1                            (PREADY_APBP1),
    .PRDATA1                            (PRDATA_APBP1),
    .PSLVERR1                           (PSLVERR_APBP1),

    .PSEL2                              (),
    .PREADY2                            (1'b1),
    .PRDATA2                            (32'b0),
    .PSLVERR2                           (1'b0),

    .PSEL3                              (),
    .PREADY3                            (1'b1),
    .PRDATA3                            (32'b0),
    .PSLVERR3                           (1'b0),

    .PSEL4                              (),
    .PREADY4                            (1'b1),
    .PRDATA4                            (32'b0),
    .PSLVERR4                           (1'b0),

    .PSEL5                              (),
    .PREADY5                            (1'b1),
    .PRDATA5                            (32'b0),
    .PSLVERR5                           (1'b0),

    .PSEL6                              (),
    .PREADY6                            (1'b1),
    .PRDATA6                            (32'b0),
    .PSLVERR6                           (1'b0),

    .PSEL7                              (),
    .PREADY7                            (1'b1),
    .PRDATA7                            (32'b0),
    .PSLVERR7                           (1'b0),

    .PSEL8                              (),
    .PREADY8                            (1'b1),
    .PRDATA8                            (32'b0),
    .PSLVERR8                           (1'b0),

    .PSEL9                              (),
    .PREADY9                            (1'b1),
    .PRDATA9                            (32'b0),
    .PSLVERR9                           (1'b0),

    .PSEL10                             (),
    .PREADY10                           (1'b1),
    .PRDATA10                           (32'b0),
    .PSLVERR10                          (1'b0),

    .PSEL11                             (),
    .PREADY11                           (1'b1),
    .PRDATA11                           (32'b0),
    .PSLVERR11                          (1'b0),

    .PSEL12                             (),
    .PREADY12                           (1'b1),
    .PRDATA12                           (32'b0),
    .PSLVERR12                          (1'b0),
    
    .PSEL13                             (),
    .PREADY13                           (1'b1),
    .PRDATA13                           (32'b0),
    .PSLVERR13                          (1'b0),

    .PSEL14                             (),
    .PREADY14                           (1'b1),
    .PRDATA14                           (32'b0),
    .PSLVERR14                          (1'b0),

    .PSEL15                             (),
    .PREADY15                           (1'b1),
    .PRDATA15                           (32'b0),
    .PSLVERR15                          (1'b0),

    .PREADY                             (PREADY),
    .PRDATA                             (PRDATA),
    .PSLVERR                            (PSLVERR)

);
//------------------------------------------------------------------------------
// APB UART
//------------------------------------------------------------------------------

wire            TXINT;
wire            RXINT;
wire            TXOVRINT;
wire            RXOVRINT;
wire            UARTINT;      

cmsdk_apb_uart UART(
    .PCLK                               (clk),
    .PCLKG                              (clk),
    .PRESETn                            (cpuresetn),
    .PSEL                               (PSEL_APBP0),
    .PADDR                              (PADDR[11:2]),
    .PENABLE                            (PENABLE), 
    .PWRITE                             (PWRITE),
    .PWDATA                             (PWDATA),
    .ECOREVNUM                          (4'b0),
    .PRDATA                             (PRDATA_APBP0),
    .PREADY                             (PREADY_APBP0),
    .PSLVERR                            (PSLVERR_APBP0),
    .RXD                                (RXD),
    .TXD                                (TXD),
    .TXEN                               (   ),
    .BAUDTICK                           (   ),
    .TXINT                              (TXINT),
    .RXINT                              (RXINT),
    .TXOVRINT                           (TXOVRINT),
    .RXOVRINT                           (RXOVRINT),
    .UARTINT                            (UARTINT)
);

assign  HRESP_AHBL1P3[1]    =   1'b0;
assign  HRDATA_AHBL1P3      =   32'b0;
//------------------------------------------------------------------------------
// APB SmartCamera
//------------------------------------------------------------------------------
SmartCamera SmartCamera_inst(
	.PCLK              (clk          ),
    .PRESETn           (cpuresetn    ),

    .PSEL              (PSEL_APBP1   ),
    .PADDR             (PADDR[11:2]  ),
    .PENABLE           (PENABLE      ), 
    .PWRITE            (PWRITE       ),
    .PWDATA            (PWDATA       ),
    .PRDATA            (PRDATA_APBP1 ),
    .PREADY            (PREADY_APBP1 ),

    .PSLVERR           (PSLVERR_APBP1),
	//------------------------------------------------------
	//-----Ethernet--------------
	.e_txc             (e_txc  ),
	.e_rxc             (e_rxc  ),
	.e_rxdv            (e_rxdv ),
	.e_rxer            (e_rxer ),
	.e_rxd             (e_rxd  ),
	.e_reset           (e_reset),
	.e_gtxc            (e_gtxc ),
	.e_txen            (e_txen ),
	.e_txer            (e_txer ),
	.e_txd             (e_txd  ),
	//-----UART-----------------    
	.uart_rx           (uart_rx),
	.uart_tx           (uart_tx),
	.CH9350_TXD        (CH9350_TXD),
	//-----BEEP-----------------    
	.BEEP			   (BEEP   ),
	//-----SMI-----------------
	.MDC               (MDC    ),
	.MDIO              (MDIO   ),
	//------VGA----------------
	.vga_out_hs        (vga_out_hs),        //vga horizontal synchronization
	.vga_out_vs        (vga_out_vs),        //vga vertical synchronization
	.vga_out_r         (vga_out_r ),         //vga red
	.vga_out_g         (vga_out_g ),         //vga green
	.vga_out_b         (vga_out_b ),        //vga blue
	//-----SDRAM_port-----------
	.sdram_clk         (sdram_clk  ),         //sdram clock
	.sdram_cke         (sdram_cke  ),         //sdram clock enable
	.sdram_cs_n        (sdram_cs_n ),        //sdram chip select
	.sdram_we_n        (sdram_we_n ),        //sdram write enable
	.sdram_cas_n       (sdram_cas_n),       //sdram column address strobe
	.sdram_ras_n       (sdram_ras_n),       //sdram row address strobe
	.sdram_dqm         (sdram_dqm  ),         //sdram data enable
	.sdram_ba          (sdram_ba   ),          //sdram bank address
	.sdram_addr        (sdram_addr ),        //sdram address
	.sdram_dq          (sdram_dq   ),
	//-----数码管--------------------
	.seg_sel           (seg_sel    ), 
	.seg_data          (seg_data   )
);

//------------------------------------------------------------------------------
// AHB ITCM
//------------------------------------------------------------------------------

wire    [13:0]  ITCMADDR;//13:0
wire    [31:0]  ITCMRDATA,ITCMWDATA;
wire    [3:0]   ITCMWRITE;
wire            ITCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16 )//16
)   AhbItcm (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL1P0),
    .HREADY                             (HREADY_AHBL1P0),
    .HTRANS                             (HTRANS_AHBL1P0),
    .HSIZE                              (HSIZE_AHBL1P0),
    .HWRITE                             (HWRITE_AHBL1P0),
    .HADDR                              (HADDR_AHBL1P0),
    .HWDATA                             (HWDATA_AHBL1P0),
    .HREADYOUT                          (HREADYOUT_AHBL1P0),
    .HRESP                              (HRESP_AHBL1P0[0]),
    .HRDATA                             (HRDATA_AHBL1P0),
    .SRAMRDATA                          (ITCMRDATA),
    .SRAMADDR                           (ITCMADDR),
    .SRAMWEN                            (ITCMWRITE),
    .SRAMWDATA                          (ITCMWDATA),
    .SRAMCS                             (ITCMCS)
);
assign  HRESP_AHBL1P0[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)//14
)   ITCM    (
    .CLK                                (clk),
    .ADDR                               (ITCMADDR),
    .WDATA                              (ITCMWDATA),
    .WREN                               (ITCMWRITE),
    .CS                                 (ITCMCS),
    .RDATA                              (ITCMRDATA)
);

//------------------------------------------------------------------------------
// AHB DTCM
//------------------------------------------------------------------------------

wire    [13:0]  DTCMADDR;
wire    [31:0]  DTCMRDATA,DTCMWDATA;
wire    [3:0]   DTCMWRITE;
wire            DTCMCS;

cmsdk_ahb_to_sram #(
    .AW                                 (16)
)   AhbDtcm (
    .HCLK                               (clk),
    .HRESETn                            (cpuresetn),
    .HSEL                               (HSEL_AHBL1P1),
    .HREADY                             (HREADY_AHBL1P1),
    .HTRANS                             (HTRANS_AHBL1P1),
    .HSIZE                              (HSIZE_AHBL1P1),
    .HWRITE                             (HWRITE_AHBL1P1),
    .HADDR                              (HADDR_AHBL1P1),
    .HWDATA                             (HWDATA_AHBL1P1),
    .HREADYOUT                          (HREADYOUT_AHBL1P1),
    .HRESP                              (HRESP_AHBL1P1[0]),
    .HRDATA                             (HRDATA_AHBL1P1),
    .SRAMRDATA                          (DTCMRDATA),
    .SRAMADDR                           (DTCMADDR),
    .SRAMWEN                            (DTCMWRITE),
    .SRAMWDATA                          (DTCMWDATA),
    .SRAMCS                             (DTCMCS)
);
assign  HRESP_AHBL1P1[1]    =   1'b0;

cmsdk_fpga_sram #(
    .AW                                 (14)
)   DTCM    (
    .CLK                                (clk),
    .ADDR                               (DTCMADDR),
    .WDATA                              (DTCMWDATA),
    .WREN                               (DTCMWRITE),
    .CS                                 (DTCMCS),
    .RDATA                              (DTCMRDATA)
);

//------------------------------------------------------------------------------
// INTERRUPT 
//------------------------------------------------------------------------------

assign  IRQ     =   {236'b0,gpio_int,TXOVRINT|RXOVRINT,TXINT,RXINT};

//------------------------------------------------------------------------------
// CH9350
//------------------------------------------------------------------------------
parameter                        CLK_FRE = 50;//Mhz
localparam                       IDLE =  0;
localparam                       SEND =  1;   //send HELLO ALINX\r\n
localparam                       WAIT =  2;   //wait 1 second and send uart received data

reg[7:0]                         tx_str;
reg[31:0]                        wait_cnt;
reg[7:0]                         tx_data;
reg[3:0]                         state;
reg[7:0]                         tx_cnt;
reg                              tx_data_valid;
wire                             tx_data_ready;

always@(*)begin
	case(tx_cnt)
		8'd0 :  tx_str <= 8'h57;
		8'd1 :  tx_str <= 8'hAB;
		8'd2 :  tx_str <= 8'h12;
		8'd3 :  tx_str <= 8'h00;
		8'd4 :  tx_str <= 8'h00;
		8'd5 :  tx_str <= 8'h00;
		8'd6 :  tx_str <= 8'h00;
		8'd7 :  tx_str <= 8'hFF;
		8'd8 :  tx_str <= 8'h80;
		8'd9 :  tx_str <= 8'h00;
		8'd10 : tx_str <= 8'h20;
	endcase
end

always@(posedge CLK50m or negedge RSTn)begin
	if(RSTn == 1'b0)begin
		wait_cnt <= 32'd0;
		tx_data <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_data_valid <= 1'b0;
	end
	else
	case(state)
		IDLE:
			state <= SEND;
		SEND:begin
			wait_cnt <= 32'd0;
			tx_data <= tx_str;
			if(tx_data_valid == 1'b1 && tx_data_ready == 1'b1 && tx_cnt < 8'd10)begin//发送中
				tx_cnt <= tx_cnt + 8'd1; //Send data counter
			end
			else if(tx_data_valid && tx_data_ready)begin     //全部发送完毕
				tx_cnt        <= 8'd0;
				tx_data_valid <= 1'b0;
				state <= WAIT;
			end
			else if(~tx_data_valid)begin
				tx_data_valid <= 1'b1;
			end
		end
		WAIT:begin
			wait_cnt <= wait_cnt + 32'd1;
			if(tx_data_valid && tx_data_ready)begin
				tx_data_valid <= 1'b0;
			end
			else if(wait_cnt >= CLK_FRE * 1000000) // wait for 1 second
				state <= SEND;
		end
		default:
			state <= IDLE;
	endcase
end

uart_tx#
(
	.CLK_FRE(CLK_FRE),
	.BAUD_RATE(115200)
) uart_tx_inst
(
	.clk                        (CLK50m        ),
	.rst_n                      (RSTn          ),
	.tx_data                    (tx_data       ),
	.tx_data_valid              (tx_data_valid ),
	.tx_data_ready              (tx_data_ready ),
	.tx_pin                     (CH9350_RXD    )
);




endmodule