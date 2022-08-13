#include "stdio.h"
#include "CortexM3.h"
#include "delay.h"
#include "GPIO.h"
#include "SmartCamera.h"
unsigned char ui_id ;
char arrow ;
extern unsigned char LED_model;
unsigned char  LCD_show_ui00;
void NMIHandler(void) {
    ;
}

void HardFaultHandler(void) {
    printf("HardFault!\n");
}

void MemManageHandler(void) {
    ;
}

void BusFaultHandler(void) {
    ;
}

void UsageFaultHandler(void) {
    ;
}

void SVCHandler(void) {
    ;
}

void DebugMonHandler(void) {
    ;
}

void PendSVHandler(void) {
    ;
}

void SysTickHandler(void) {
    ;
}

void UARTRXHandler(void) {
    ;
}

void UARTTXHandler(void) {
    ;
}

void UARTOVRHandler(void) {
    ;
}
//-----------------------------------------------------
void GPIOHandler(void) {
	
	delay_ms(500);//Ïû¶¶
	GPIO->INT_STA   =0xffff;
	
	if(ui_id == 0){
		
		if(GPIO_input(6)==0){
			while(GPIO_input(6)==0);
			LCD_show_arrow(5,0,0);
		}
		else if(GPIO_input(5)==0){
			while(GPIO_input(5)==0);
			LCD_show_arrow(5,1,0);
		}
		else if(GPIO_input(4)==0){//OK
			  while(GPIO_input(4)==0);
				if(arrow==1)      LCD_show_ui01();
			  else if(arrow==2) LCD_show_ui02();
				else if(arrow==3) LCD_show_ui03();
				else if(arrow==4) SmartCamera_reset();
				else if(arrow==5) SmartCamera_send_SYN();
		}
	}
	else if(ui_id == 1){    //LEDmodel
		if(GPIO_input(6)==0){
			while(GPIO_input(6)==0);
			LCD_show_arrow(4,0,0);
		}
		else if(GPIO_input(5)==0){
			while(GPIO_input(5)==0);
			LCD_show_arrow(4,1,0);
		}
		else if(GPIO_input(4)==0){//OK
			  while(GPIO_input(4)==0);
				if(arrow == 4) LCD_show_item();
				else           LED_model = arrow -1;			
		}
	}
	else if(ui_id == 2){
		
		if(GPIO_input(6)==0){
			while(GPIO_input(6)==0);
			LCD_show_arrow(5,0,0);
		}
		else if(GPIO_input(5)==0){
			while(GPIO_input(5)==0);
			LCD_show_arrow(5,1,0);
		}
		else if(GPIO_input(4)==0){//OK
			  while(GPIO_input(4)==0);
				if(arrow == 5) LCD_show_item();		
		}
		else if(GPIO_input(3)==0){//+
			  while(GPIO_input(3)==0);
				if(arrow==1){
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>8)&0xff)+1)&0xff)<<8) + 
					                             ((SmartCamera->sys_reg01)&0xFFFF00FF);
				}
				else if(arrow==2){
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>16)&0xff)+1)&0xff)<<16) + 
					                             ((SmartCamera->sys_reg01)&0xFF00FFFF);
				}
				else if(arrow==3){
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>24)&0xff)+1)&0xff)<<24) + 
					                             ((SmartCamera->sys_reg01)&0x00FFFFFF);
				}
				else if(arrow==4){
					SmartCamera->sys_reg02 = SmartCamera->sys_reg02 +1;
				}
				LCD_show_sys_set();
		}
		else if(GPIO_input(2)==0){//-
			  while(GPIO_input(2)==0);
				if(arrow==1){
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>8)&0xff)-1)&0xff)<<8) + 
					                             ((SmartCamera->sys_reg01)&0xFFFF00FF);
				}
				else if(arrow==2){
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>16)&0xff)-1)&0xff)<<16) + 
					                             ((SmartCamera->sys_reg01)&0xFF00FFFF);
				}
				else if(arrow==3){
					
					SmartCamera->sys_reg01 = ((((((SmartCamera->sys_reg01)>>24)&0xff)-1)&0xff)<<24) + 
					                             ((SmartCamera->sys_reg01)&0x00FFFFFF);
				}
				else if(arrow==4){
					SmartCamera->sys_reg02 = SmartCamera->sys_reg02 -1;
				}
				LCD_show_sys_set();
		}
	}
	else if(ui_id == 3){
		
		if(GPIO_input(4)==0){//OK
			  while(GPIO_input(4)==0);
				LCD_show_ui00 = 1;		
		}
		else if(GPIO_input(3)==0){
			  while(GPIO_input(3)==0);
			  SmartCamera_reset();
		}
		else if(GPIO_input(2)==0){
			  while(GPIO_input(2)==0);
			  SmartCamera_send_SYN();
		}
	}
  printf("GPIO!\n");
}




