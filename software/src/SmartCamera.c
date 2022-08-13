#include "CortexM3.h"
#include "SmartCamera.h"
#include "GPIO.h"

void SmartCamera_init(){
	
	SmartCamera->src_ip = 0xc0a80202; //192.168.2.2
	SmartCamera->des_ip = 0xc0a80206; //192.168.2.6
	SmartCamera->port   = 0x1F900000;
	SmartCamera->sys_reg01 = 0xc8000000;
	SmartCamera->sys_reg02 = 2;       //BEEP time
}
void SmartCamera_reset(){
	 SmartCamera->sys_reg00 = (SmartCamera->sys_reg00)|0x01;
}
void SmartCamera_send_SYN(){
	 SmartCamera->sys_reg00 = (SmartCamera->sys_reg00)|0x02;
}
unsigned int SmartCamera_get_info(unsigned char id){
	
	if(id==0){
		return  (SmartCamera->sys_reg01)&0x0f;
	}
	else if(id==1){//Y+
		return  ((SmartCamera->sys_reg01)>>8)&0xff;
	}
	else if(id==2){//Y-
		return  ((SmartCamera->sys_reg01)>>16)&0xff;
	}
	else if(id==3){//T
		return  ((SmartCamera->sys_reg01)>>24)&0xff;
	}
	else if(id==4){//BEEP time
		return  (SmartCamera->sys_reg02)&0xff;
	}
}
void show_TCP_status(){
	switch((SmartCamera->sys_reg01)&0x0f){
			case 0: {
				//OLED_showStr_fixed(57,1,"IDLE     ");
				break;
			}
			case 1:{
				//OLED_showStr_fixed(57,1,"SYNready ");
				break;
			}
			case 2:{
				//OLED_showStr_fixed(57,1,"SYN      ");
				break;
			}
			case 3:{
				//OLED_showStr_fixed(57,1,"WaitACK  ");
				break;
			}
			case 4:{
				//OLED_showStr_fixed(57,1,"ACK      ");
				break;
			}
			case 5:{
				//OLED_showStr_fixed(57,1,"PSH      ");
				break;
			}
			case 6:{
				//OLED_showStr_fixed(57,1,"WaitACK  ");
				break;
			}
			case 7:{
				//OLED_showStr_fixed(57,1,"PSHACK   ");
				break;
			}
			case 8:{
				//OLED_showStr_fixed(57,1,"FIN      ");
				break;
			}
			case 9:{
				//OLED_showStr_fixed(57,1,"FINACK   ");
				break;
			}
			case 10:{
				//OLED_showStr_fixed(57,1,"FIN      ");
				break;
			}
			case 11:{
				//OLED_showStr_fixed(57,1,"WaitACK  ");
				break;
			}
			default:{
				//OLED_showStr_fixed(57,1,"None     ");
			}
		}
}


