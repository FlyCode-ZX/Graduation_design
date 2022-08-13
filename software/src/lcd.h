#ifndef __LCD_H
#define __LCD_H			  	 

   
#define USE_HORIZONTAL 2  //设置横屏或者竖屏显示 0或1为竖屏 2或3为横屏
#if USE_HORIZONTAL==0||USE_HORIZONTAL==1
#define LCD_W 320
#define LCD_H 480

#else
#define LCD_W 480
#define LCD_H 320
#endif
#define	u8 unsigned char
#define	u16 unsigned int
#define	u32 unsigned long					  
//-----------------测试LED端口定义---------------- 
#define LED_ON  GPIO_output(0,10)
#define LED_OFF GPIO_output(0,10)

//-----------------OLED端口定义---------------- 

#define OLED_SCLK_Clr() GPIO_output(12,0)
#define OLED_SCLK_Set() GPIO_output(12,1)

#define OLED_SDIN_Clr() GPIO_output(13,0)
#define OLED_SDIN_Set() GPIO_output(13,1)

#define OLED_RST_Clr() GPIO_output(14,0)
#define OLED_RST_Set() GPIO_output(14,1)

#define OLED_DC_Clr() GPIO_output(15,0)
#define OLED_DC_Set() GPIO_output(15,1)

#define OLED_BLK_Clr()  GPIO_output(0,0)
#define OLED_BLK_Set()  GPIO_output(0,1)


#define OLED_CMD  0	//写命令
#define OLED_DATA 1	//写数据

extern  u16 BACK_COLOR;   //背景色

void LCD_Writ_Bus(u8 dat);
void LCD_WR_DATA8(u8 dat);
void LCD_WR_DATA(u16 dat);
void LCD_WR_REG(u8 dat);
void LCD_Address_Set(u16 x1,u16 y1,u16 x2,u16 y2);
void Lcd_Init(void); 
void LCD_Clear(u16 Color);
void LCD_ShowChinese32x32(u16 x,u16 y,u8 index,u8 size,u16 color);
void LCD_DrawPoint(u16 x,u16 y,u16 color);
void LCD_DrawPoint_big(u16 x,u16 y,u16 colory);
void LCD_Fill(u16 xsta,u16 ysta,u16 xend,u16 yend,u16 color);
void LCD_DrawLine(u16 x1,u16 y1,u16 x2,u16 y2,u16 color);
void LCD_DrawRectangle(u16 x1, u16 y1, u16 x2, u16 y2,u16 color);
void Draw_Circle(u16 x0,u16 y0,u8 r,u16 color);
void LCD_ShowChar(u16 x,u16 y,u8 num,u8 mode,u16 color);
void LCD_ShowString(u16 x,u16 y,const u8 *p,u16 color);
u32 mypow(u8 m,u8 n);
void LCD_ShowNum(u16 x,u16 y,u16 num,u8 len,u16 color);
void LCD_ShowNum1(u16 x,u16 y,float num,u8 len,u16 color);
void LCD_ShowPicture(u16 x1,u16 y1,u16 x2,u16 y2);
void LCD_Show_ASCII(u16 x,u16 y,u8 *p,u16 color);
void LCD_show_item(void);
void LCD_show_ui01(void);
void LCD_show_sys_set(void);

//画笔颜色
#define WHITE         	 0xFCFCFC
#define BLACK            0X000000
#define RED           	 0xFC0000
#define GREEN            0x00FC00
#define BLUE             0x0000FC
					  		 
#endif  
	 
	 



