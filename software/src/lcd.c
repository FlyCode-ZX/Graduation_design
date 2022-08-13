#include "stdlib.h"	
#include "lcd.h"
#include "oledfont.h"
#include "bmp.h"
#include "delay.h"

u16 BACK_COLOR;   //背景色
extern char arrow;
extern unsigned char ui_id ;
/******************************************************************************
      函数说明：LCD串行数据写入函数
      入口数据：dat  要写入的串行数据
      返回值：  无
******************************************************************************/
void LCD_Writ_Bus(u8 dat) 
{	
	u8 i;	
	for(i=0;i<8;i++)
	{			  
		OLED_SCLK_Clr();
		if(dat&0x80)
		   OLED_SDIN_Set();
		else 
		   OLED_SDIN_Clr();
		OLED_SCLK_Set();
		dat<<=1;   
	}
}


/******************************************************************************
      函数说明：LCD写入数据
      入口数据：dat 写入的数据
      返回值：  无
******************************************************************************/
void LCD_WR_DATA8(u8 dat)
{
	OLED_DC_Set();//写数据
	LCD_Writ_Bus(dat);
}


/******************************************************************************
      函数说明：LCD写入数据
      入口数据：dat 写入的数据
      返回值：  无
******************************************************************************/
void LCD_WR_DATA(u16 dat)
{
	OLED_DC_Set();//写数据
	LCD_Writ_Bus(dat>>16);
	LCD_Writ_Bus(dat>>8);
	LCD_Writ_Bus(dat);
}


/******************************************************************************
      函数说明：LCD写入命令
      入口数据：dat 写入的命令
      返回值：  无
******************************************************************************/
void LCD_WR_REG(u8 dat)
{
	OLED_DC_Clr();//写命令
	LCD_Writ_Bus(dat);
}


/******************************************************************************
      函数说明：设置起始和结束地址
      入口数据：x1,x2 设置列的起始和结束地址
                y1,y2 设置行的起始和结束地址
      返回值：  无
******************************************************************************/
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2)
{
	LCD_WR_REG(0x2a);//列地址设置
   LCD_WR_DATA8(x1>>8);
   LCD_WR_DATA8(x1);
   LCD_WR_DATA8(x2>>8);
   LCD_WR_DATA8(x2);
   LCD_WR_REG(0x2b);//行地址设置
   LCD_WR_DATA8(y1>>8);
   LCD_WR_DATA8(y1);
   LCD_WR_DATA8(y2>>8);
   LCD_WR_DATA8(y2);
	LCD_WR_REG(0x2c);//储存器写
}


/******************************************************************************
      函数说明：LCD初始化函数
      入口数据：无
      返回值：  无
******************************************************************************/
void Lcd_Init(void)
{
	OLED_RST_Clr();
	delay_ms(200);
	OLED_RST_Set();
	delay_ms(20);
	OLED_BLK_Set();
	
//************* Start Initial Sequence **********// 
LCD_WR_REG(0x11); //Exit Sleep
delay_ms(60);
LCD_WR_REG(0XF2);
LCD_WR_DATA8(0x18);
LCD_WR_DATA8(0xA3);
LCD_WR_DATA8(0x12);
LCD_WR_DATA8(0x02);
LCD_WR_DATA8(0XB2);
LCD_WR_DATA8(0x12);
LCD_WR_DATA8(0xFF);
LCD_WR_DATA8(0x10);
LCD_WR_DATA8(0x00);
LCD_WR_REG(0XF8);
LCD_WR_DATA8(0x21);
LCD_WR_DATA8(0x04);
LCD_WR_REG(0X13);

LCD_WR_REG(0x36);    // Memory Access Control 
	if(USE_HORIZONTAL==0)LCD_WR_DATA8(0x08);
	else if(USE_HORIZONTAL==1)LCD_WR_DATA8(0xC8);
	else if(USE_HORIZONTAL==2)LCD_WR_DATA8(0x78);
	else LCD_WR_DATA8(0xA8);

LCD_WR_REG(0xB4);
LCD_WR_DATA8(0x02);
LCD_WR_REG(0xB6);
LCD_WR_DATA8(0x02);
LCD_WR_DATA8(0x22);
LCD_WR_REG(0xC1);
LCD_WR_DATA8(0x41);
LCD_WR_REG(0xC5);
LCD_WR_DATA8(0x00);
LCD_WR_DATA8(0x18);



LCD_WR_REG(0x3a);
LCD_WR_DATA8(0x66);
delay_ms(50);



LCD_WR_REG(0xE0);
LCD_WR_DATA8(0x0F);
LCD_WR_DATA8(0x1F);
LCD_WR_DATA8(0x1C);
LCD_WR_DATA8(0x0C);
LCD_WR_DATA8(0x0F);
LCD_WR_DATA8(0x08);
LCD_WR_DATA8(0x48);
LCD_WR_DATA8(0x98);
LCD_WR_DATA8(0x37);
LCD_WR_DATA8(0x0A);
LCD_WR_DATA8(0x13);
LCD_WR_DATA8(0x04);
LCD_WR_DATA8(0x11);
LCD_WR_DATA8(0x0D);
LCD_WR_DATA8(0x00);
LCD_WR_REG(0xE1);
LCD_WR_DATA8(0x0F);
LCD_WR_DATA8(0x32);
LCD_WR_DATA8(0x2E);
LCD_WR_DATA8(0x0B);
LCD_WR_DATA8(0x0D);
LCD_WR_DATA8(0x05);
LCD_WR_DATA8(0x47);
LCD_WR_DATA8(0x75);
LCD_WR_DATA8(0x37);
LCD_WR_DATA8(0x06);
LCD_WR_DATA8(0x10);
LCD_WR_DATA8(0x03);
LCD_WR_DATA8(0x24);
LCD_WR_DATA8(0x20);
LCD_WR_DATA8(0x00);
LCD_WR_REG(0x11);
delay_ms(120);
LCD_WR_REG(0x29);
LCD_WR_REG(0x2C);

LCD_Address_Set(0,0,0,0);
} 


/******************************************************************************
      函数说明：LCD清屏函数
      入口数据：无
      返回值：  无
******************************************************************************/
void LCD_Clear(u16 Color)
{
	u16 i,j;  	
	LCD_Address_Set(0,0,LCD_W-1,LCD_H-1);
    for(i=0;i<LCD_W;i++)
	 {
	  for (j=0;j<LCD_H;j++)
	   	{
        	LCD_WR_DATA(Color);	 			 
	    }

	  }
}


/******************************************************************************
      函数说明：LCD显示汉字
      入口数据：x,y   起始坐标
                index 汉字的序号
                size  字号
      返回值：  无
******************************************************************************/
void LCD_ShowChinese32x32(u16 x,u16 y,u8 index,u8 size,u16 color)	
{  
	u8 k,i,j;
	for(k=0;k<7;k++){
		LCD_Address_Set(x+k*24,y,x+k*24+size-1,y+size-1); //设置一个汉字的区域
		
		for(j=0;j<72;j++)//
		{
			for(i=0;i<8;i++)
			{
				if((Hzk24[k*72+j]&(1<<i))!=0)//从数据的低位开始读
				{
					LCD_WR_DATA(color);//点亮
				}
				else
				{
					LCD_WR_DATA(WHITE);//不点亮
				}
			}
		}
	}
}

void LCD_Show_ASCII(u16 x,u16 y,u8 *p,u16 color){
	
	u8 k,i,j;
	u16 index;
	for(k=0;p[k]!='\0';k++){
		
		LCD_Address_Set(x+k*8,y,x+k*8+8-1,y+16-1); //设置一个汉字的区域
		
		if(p[k]>=48 && p[k]<=57)      index =   0             + (p[k]-48)*16;
		else if(p[k]>=65 && p[k]<=90) index =   16*10         + (p[k]-65)*16;
		else if(p[k]>=97 && p[k]<=122)index =   16*10 + 16*26 + (p[k]-97)*16;
		else if(p[k] ==95)             index =   16*10 + 16*26 + 16*26 + 16*0;
		else if(p[k] ==58)             index =   16*10 + 16*26 + 16*26 + 16*1;
		else if(p[k] ==60)             index =   16*10 + 16*26 + 16*26 + 16*2;
		else if(p[k] ==32)             index =   16*10 + 16*26 + 16*26 + 16*3;
		else if(p[k] ==43)             index =   16*10 + 16*26 + 16*26 + 16*4;
		else if(p[k] ==45)             index =   16*10 + 16*26 + 16*26 + 16*5;
		for(j=0;j<16;j++)//
		{
			for(i=0;i<8;i++)//for(i=0;i<8;i++)  for(i=7;i>0;i--)
			{
				if((ASCII_num[index+j]&(1<<i))!=0)//从数据的低位开始读
				{
					LCD_WR_DATA(color);//点亮
				}
				else
				{
					LCD_WR_DATA(WHITE);//不点亮
				}
			}
		}
	}
}

#define x_start   290
#define y_start   120
#define y2y       24
void LCD_clear_item(){
	unsigned char i;
	for(i=0;i<10;i++){	
		LCD_Show_ASCII(x_start,y_start + y2y*i,"                      ",WHITE);
	}
}
void LCD_show_arrow(unsigned char max,unsigned char action,unsigned char pos){
	
	LCD_Show_ASCII(x_start+ 8*18,y_start + y2y*(arrow-1)," ",BLACK);
	if(pos==0){
		if(action==1)arrow ++;
		else         arrow --;
		
		if(arrow >max) arrow =1;
		if(arrow <=   0) arrow = max;
		LCD_Show_ASCII(x_start+ 8*18,y_start + y2y*(arrow-1),"<",BLACK);
	}
	else {
		LCD_Show_ASCII(x_start+ 8*18,y_start,"<",BLACK);
	}
	
}
void LCD_show_item(){
	ui_id = 0;
	LCD_clear_item();
	LCD_show_arrow(5,0,1);
	arrow = 1;
	LCD_Show_ASCII(x_start,y_start + y2y*0,"LED model:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*1,"Sys set:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*2,"Sys monitor:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*3,"Accelerator RST",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*4,"Accelerator RUN",BLACK);
}
void LCD_show_ui01(){
	ui_id = 1;
	LCD_clear_item();
	LCD_show_arrow(3,0,1);
	arrow = 1;
	LCD_Show_ASCII(x_start,y_start + y2y*0,"Left roll",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*1,"Right roll",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*2,"All",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*3,"Back",BLACK);
	
}
//-------------------------------------------------------------------
void LCD_show_ui02(){
	ui_id = 2;
	LCD_clear_item();
	LCD_show_arrow(5,0,1);
	arrow = 1;
	LCD_Show_ASCII(x_start,y_start + y2y*0,"Y+:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*1,"Y-:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*2,"Threshold:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*3,"Beep time:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*4,"Back",BLACK);
	LCD_show_sys_set();
}
void LCD_show_sys_set(){
	unsigned char num[5];
	unsigned int  value;
	value = SmartCamera_get_info(1);//Y+
	num[0]     = value/100+48;
	num[1]     = value%100/10+48;
	num[2]     = value%100%10+48;
	num[3]     = '\0';
	LCD_Show_ASCII(x_start + 12*8,y_start + y2y*0,num,BLACK);
	//-------------------------------------------------------
	value = SmartCamera_get_info(2);//Y-
	num[0]     = value/100+48;
	num[1]     = value%100/10+48;
	num[2]     = value%100%10+48;
	LCD_Show_ASCII(x_start + 12*8,y_start + y2y*1,num,BLACK);
	//-------------------------------------------------------
	value = SmartCamera_get_info(3);//T
	num[0]     = value/100+48;
	num[1]     = value%100/10+48;
	num[2]     = value%100%10+48;
	LCD_Show_ASCII(x_start + 12*8,y_start + y2y*2,num,BLACK);
	//-------------------------------------------------------
	value = SmartCamera_get_info(4);//BEEP TIME
	num[0]     = value/100+48;
	num[1]     = value%100/10+48;
	num[2]     = value%100%10+48;
	LCD_Show_ASCII(x_start + 12*8,y_start + y2y*3,num,BLACK);	
}
//-------------------------------------------------------------------
void LCD_show_ui03(){
	ui_id = 3;
	arrow = 1;
	LCD_clear_item();
	LCD_Show_ASCII(x_start,y_start + y2y*0,"Aclor Sta:",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*1,"Eth speed:        Kbps",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*2,"Valda speed:      Kbps",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*3,"Frame speed:      fps",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*4,"Store speed:      fps",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*5,"Eth rdusedw:      Byte",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*6,"Vec rdusedw:      Byte",BLACK);
	LCD_Show_ASCII(x_start,y_start + y2y*7,"VGA rdusedw:      Byte",BLACK);
}
/******************************************************************************
      函数说明：LCD显示汉字
      入口数据：x,y   起始坐标
      返回值：  无
******************************************************************************/
void LCD_DrawPoint(u16 x,u16 y,u16 color)
{
	LCD_Address_Set(x,y,x,y);//设置光标位置 
	LCD_WR_DATA(color);
} 

/******************************************************************************
      函数说明：在指定区域填充颜色
      入口数据：xsta,ysta   起始坐标
                xend,yend   终止坐标
      返回值：  无
******************************************************************************/
void LCD_Fill(u16 xsta,u16 ysta,u16 xend,u16 yend,u16 color)
{          
	u16 i,j; 
	LCD_Address_Set(xsta,ysta,xend,yend);      //设置光标位置 
	for(i=ysta;i<=yend;i++)
	{													   	 	
		for(j=xsta;j<=xend;j++)LCD_WR_DATA(color);//设置光标位置 	    
	} 					  	    
}

void LCD_DrawLine(u16 x1,u16 y1,u16 x2,u16 y2,u16 color)
{
	u16 t; 
	int xerr=0,yerr=0,delta_x,delta_y,distance;
	int incx,incy,uRow,uCol;
	delta_x=x2-x1; //计算坐标增量 
	delta_y=y2-y1;
	uRow=x1;//画线起点坐标
	uCol=y1;
	if(delta_x>0)incx=1; //设置单步方向 
	else if (delta_x==0)incx=0;//垂直线 
	else {incx=-1;delta_x=-delta_x;}
	if(delta_y>0)incy=1;
	else if (delta_y==0)incy=0;//水平线 
	else {incy=-1;delta_y=-delta_x;}
	if(delta_x>delta_y)distance=delta_x; //选取基本增量坐标轴 
	else distance=delta_y;
	for(t=0;t<distance+1;t++)
	{
		LCD_DrawPoint(uRow,uCol,color);//画点
		xerr+=delta_x;
		yerr+=delta_y;
		if(xerr>distance)
		{
			xerr-=distance;
			uRow+=incx;
		}
		if(yerr>distance)
		{
			yerr-=distance;
			uCol+=incy;
		}
	}
}

void LCD_DrawRectangle(u16 x1, u16 y1, u16 x2, u16 y2,u16 color)
{
	LCD_DrawLine(x1,y1,x2,y1,color);
	LCD_DrawLine(x1,y1,x1,y2,color);
	LCD_DrawLine(x1,y2,x2,y2,color);
	LCD_DrawLine(x2,y1,x2,y2,color);
}

void LCD_ShowPicture(u16 x1,u16 y1,u16 x2,u16 y2)
{
	int i,j;
	unsigned char value;
	unsigned char value01;
	x2 = x1+240-1;
	y2 = y1+240-1;
	
	LCD_Address_Set(x1,y1,x2,y2);
	
		for(i=0;i<7200;i++)
	  { 	
			value  =  gImage_78[i];
			
			for(j=0;j<8;j++){   
				
				value01 = ((value>>(7-j))&0x01);
				
				if(value01 == 0x00){
						LCD_WR_DATA8(0xff);//R
						LCD_WR_DATA8(0xff);//G
						LCD_WR_DATA8(0xff);//B
			  }
				else if(value01 == 0x01){
						LCD_WR_DATA8(0x00);
						LCD_WR_DATA8(0x00);
						LCD_WR_DATA8(0xff);
			  }
			}
	  }
		//--------------------------
		LCD_Address_Set(80,10,80+319,10+31);
		for(i=0;i<320*32/8;i++){ 
			value  =  Title[i];
			for(j=7;j>=0;j--){  
	    
			   value01  =  (value>>j)&0x01;
				 if(value01 == 0){
					  LCD_WR_DATA8(0xff);
						LCD_WR_DATA8(0xff);
						LCD_WR_DATA8(0xff);
				 }
				 else if(value01 == 1){
					  LCD_WR_DATA8(0xff);
						LCD_WR_DATA8(0x00);
						LCD_WR_DATA8(0x00);
				 }
			}
		}
}


