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
		GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)&(~(1<<id));//bit1��0
	}
	else if(value == 1){
		GPIO->DATA_OUTPUT= (GPIO->DATA_OUTPUT)|(1<<id);   //bit1��1
	}
}

void EXTIX_Init(void)
{
   	NVIC_InitTypeDef NVIC_InitStructure;
  	NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn;			//ʹ�ܰ���WK_UP���ڵ��ⲿ�ж�ͨ��
  	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0x02;	//��ռ���ȼ�2�� 
  	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0x03;					//�����ȼ�3
  	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;								//ʹ���ⲿ�ж�ͨ��
  	NVIC_Init(&NVIC_InitStructure); 
}





