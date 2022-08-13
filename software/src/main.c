#include <stdio.h>
#include "delay.h"

#include "CortexM3.h"
#include "GPIO.h"
#include "SmartCamera.h"

#include "lcd.h"
#include "misc.h"
//RAM ROM  64K * 32bit
unsigned char num[5];
unsigned int  value;
extern  unsigned char ui_id;
extern  char arrow;
unsigned char LED_model;
extern unsigned char  LCD_show_ui00;
int main(void) {
	unsigned char i,tcp_sta;
	ui_id  =    0xff;
	arrow  =    1;
	LED_model  = 0;
	num[5] = '\0';
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
	EXTIX_Init();
	
  GPIO_init();
	Lcd_Init();			//³õÊ¼»¯OLED  
	LCD_Clear(WHITE);
	LCD_ShowPicture(25,60,0,0);
	LCD_DrawRectangle(280,60,470,310,RED);
	LCD_ShowChinese32x32(291,70,0,24,BLACK);
	LCD_show_item();
		
  SmartCamera_init();
	SmartCamera_reset();
	delay_ms(10);
  while(1){
		//printf("Runing\n");
		
		
		//-----------------------------------------
		//show_TCP_status();
		//-----------------------------------------
		if(LED_model ==0 ){
			 GPIO_output(7+i-1,0);
			 delay_ms(200);
			 GPIO_output(7+i-1,1);
			 delay_ms(200);
			 i++;
			if(i>=6) i=0;
		}
		else if(LED_model ==1){
			 GPIO_output(7+i-1,0);
			 delay_ms(200);
			 GPIO_output(7+i-1,1);
			 delay_ms(200);
			 i--;
			if(i<=0) i=5;
		}
		else if(LED_model ==2){
			GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)&(~(0x0f80));//bit1Çå0
			delay_ms(400);
			GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)|0x0f80;   //bit1ÖÃ1
			delay_ms(400);
		}
		//----------------------------------
		if(ui_id==3){
			//--------------------------------------00
			tcp_sta  = (SmartCamera->sys_reg01)&0xff;
			if( tcp_sta == 0)      LCD_Show_ASCII(290 + 12*8,120 + 24*0,"IDLE    ",BLUE);
			else if(tcp_sta == 2)  LCD_Show_ASCII(290 + 12*8,120 + 24*0,"Send SYN",BLUE);
			else if(tcp_sta == 4)  LCD_Show_ASCII(290 + 12*8,120 + 24*0,"Send ACK",BLUE);
      else if(tcp_sta == 5)  LCD_Show_ASCII(290 + 12*8,120 + 24*0,"Receive ",BLUE);
			else if(tcp_sta == 3)  LCD_Show_ASCII(290 + 12*8,120 + 24*0,"Receive ",BLUE);
			//-----------------------------------------01
			value = (SmartCamera->eth_speed)*4/1024;
			num[0]     = value/10000+48;
			num[1]     = value%10000/1000+48;
			num[2]     = value%10000%1000/100+48;
			num[3]     = value%10000%1000%100/10+48;
			num[4]     = value%10000%1000%100%10+48;
			num[5] = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*1,num,BLUE);
			//-----------------------------------------02
			value = (SmartCamera->valid_data_speed)*8/1024;
			num[0]     = value/10000+48;
			num[1]     = value%10000/1000+48;
			num[2]     = value%10000%1000/100+48;
			num[3]     = value%10000%1000%100/10+48;
			num[4]     = value%10000%1000%100%10+48;
			num[5] = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*2,num,BLUE);
			//-----------------------------------------03decode
			value =  (SmartCamera->sys_reg03)&0xff;
			num[0]     = value/100+48;
			num[1]     = value%100/10+48;
			num[2]     = value%100%10+48;
			num[3]     = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*3,num,BLUE);
			//-----------------------------------------04store
			value =  (((SmartCamera->sys_reg03)>>8)&0xff)*2;
			num[0]     = value/100+48;
			num[1]     = value%100/10+48;
			num[2]     = value%100%10+48;
			num[3]     = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*4,num,BLUE);
			//-----------------------------------------05Eth rdusedw
			value =  (SmartCamera->sys_reg04)&0xffff;
			num[0]     = value/10000+48;
			num[1]     = value%10000/1000+48;
			num[2]     = value%10000%1000/100+48;
			num[3]     = value%10000%1000%100/10+48;
			num[4]     = value%10000%1000%100%10+48;
			num[5] = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*5,num,BLUE);
			//-----------------------------------------06Vec rdusedw
			value =  ((SmartCamera->sys_reg04)>>16)&0xffff;
			num[0]     = value/10000+48;
			num[1]     = value%10000/1000+48;
			num[2]     = value%10000%1000/100+48;
			num[3]     = value%10000%1000%100/10+48;
			num[4]     = value%10000%1000%100%10+48;
			num[5] = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*6,num,BLUE);
			//-----------------------------------------07VGA rdusedw
			value =  ((SmartCamera->sys_reg03)>>16)&0xffff;
			num[0]     = value/10000+48;
			num[1]     = value%10000/1000+48;
			num[2]     = value%10000%1000/100+48;
			num[3]     = value%10000%1000%100/10+48;
			num[4]     = value%10000%1000%100%10+48;
			num[5] = '\0';
			LCD_Show_ASCII(290 + 12*8,120 + 24*7,num,BLUE);
		}
		if(LCD_show_ui00==1){
			LCD_show_ui00 = 0;
			LCD_show_item();
		}
	}
}













