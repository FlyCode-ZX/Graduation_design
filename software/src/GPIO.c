#include "CortexM3.h"
#include "GPIO.h"
#include "misc.h"

void GPIO_init()
{
	 GPIO->OUT_EN_SET =0xff83;
	 GPIO->OUT_EN_CLR =0x007c;
	 GPIO->ALTER_FUNC_SET =0x0000;
	 GPIO->ALTER_FUNC_CLR =0xffff;
	 GPIO->DATA_OUTPUT    =0xffff;//4+5+7
	
	 
	 GPIO->INT_EN_SET     =0x007c;
	 // GPIO->INT_TYPE_SET   =0xffff;
	 GPIO->INT_POL_CLR    =0xffff;
}
unsigned char GPIO_input(unsigned char id){
	return ((GPIO->DATA_INPUT)>>id)&0x01;
}

void GPIO_output(unsigned char id,unsigned char value){
	
	if(value == 0){
		GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)&(~(1<<id));//bit1清0
	}
	else if(value == 1){
		GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)|(1<<id);   //bit1置1
	}
}

void EXTIX_Init(void)
{
   	NVIC_InitTypeDef NVIC_InitStructure;
  	NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn;			//使能按键WK_UP所在的外部中断通道
  	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x02;	//抢占优先级2， 
  	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x03;					//子优先级3
  	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;								//使能外部中断通道
  	NVIC_Init(&NVIC_InitStructure); 
}





