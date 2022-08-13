#include "delay.h"
void delay(unsigned char MS)
{
	unsigned char J=0xff, K=0xff;
	while(MS>0){
		while(J>0)
		{
			while(K>0)
			{
				K=K-1;
			}
			J=J-1;
		}
		MS=MS-1;
	}
	//=======================
}
void delay_ms(unsigned int MS){

	while(MS>0){
		delay(0xff);
		MS=MS-1;
	}
	
}

