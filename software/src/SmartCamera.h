#ifndef __CAMERA_display_H
#define __CAMERA_display_H

void SmartCamera_init(void);
void SmartCamera_reset(void);
void SmartCamera_send_SYN(void);
void show_TCP_status(void);
void button(void);
//#include "stdint.h"
#include "CortexM3.h"
/*------------- SmartCamera -----------*/
typedef struct
{
  volatile   uint32_t   sys_reg00;         
  volatile   uint32_t   src_ip;       
	volatile   uint32_t   des_ip; 
  volatile   uint32_t   port;
	volatile   uint32_t   sys_reg01; 
	volatile   uint32_t   sys_reg02; 
	volatile   uint32_t   eth_speed;
  volatile   uint32_t   valid_data_speed;
  volatile   uint32_t   sys_reg03;
  volatile   uint32_t   sys_reg04;	
	volatile   uint32_t   test;
	
}  SmartCamera_TypeDef;

#define SmartCamera         ((SmartCamera_TypeDef   *) SmartCamera_BASE   )

#endif  

