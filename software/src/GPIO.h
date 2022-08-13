#ifndef __GPIO_display_H
#define __GPIO_display_H
void GPIO_init(void);
void GPIO_output(unsigned char id,unsigned char value);
unsigned char GPIO_input(unsigned char id);
void EXTIX_Init(void);
#include "core_cm3.h"
/*------------- GPIO -----------*/
typedef struct
{
  __IO   uint32_t   DATA_INPUT;          /*!< Offset: 0x000 Data input Register    (R/W) */
  __IO   uint32_t   DATA_OUTPUT;         /*!< Offset: 0x004 Data Output latch  (R/W) */
	__IO   uint32_t   NONE00;              /*!< Offset: 0x008   (R/W) */
	__IO   uint32_t   NONE01;              /*!< Offset: 0x00C   (R/W) */
  __IO   uint32_t   OUT_EN_SET;         /*!< Offset: 0x010 Output Enable Set (R/W) */
	__IO   uint32_t   OUT_EN_CLR;        /*!< Offset:  0x014  Output Enable Clear (R/W) */
	__IO   uint32_t   ALTER_FUNC_SET;
	__IO   uint32_t   ALTER_FUNC_CLR;
	
	__IO   uint32_t   INT_EN_SET  ;
	__IO   uint32_t   INT_EN_CLR  ;
	__IO   uint32_t   INT_TYPE_SET;
	__IO   uint32_t   INT_TYPE_CLR;
	__IO   uint32_t   INT_POL_SET ;
	__IO   uint32_t   INT_POL_CLR ;
	__IO   uint32_t   INT_STA     ;
	__IO   uint32_t   INT_STA_CLR ;
	
}  GPIO_TypeDef;

/******************************************************************************/
/*                         Peripheral memory map                              */
/******************************************************************************/
/* Peripheral and SRAM base address */
#define AHB_BASE         (0x50000000UL)
#define GPIO_BASE        (AHB_BASE)

/******************************************************************************/
/*                         Peripheral declaration                             */
/******************************************************************************/
#define GPIO         ((GPIO_TypeDef   *) GPIO_BASE   )

#endif  




