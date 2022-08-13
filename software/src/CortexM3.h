#ifndef __CoreM3_H
#define __CoreM3_H	
#include <stdint.h>


#include "core_cm3_int.h"
#include "core_cm3.h"

/******************************************************************************/
/*                         Peripheral memory map                              */
/******************************************************************************/
#define APB_BASE                (0x40000000UL     )
#define UART_BASE               (APB_BASE         )
#define SmartCamera_BASE        (APB_BASE+0x1000UL)
/******************************************************************************/
/*                         Peripheral declaration                             */
/******************************************************************************/


/*------------- Universal Asynchronous Receiver Transmitter (UART) -----------*/
typedef struct
{
  __IO   uint32_t  DATA;          /*!< Offset: 0x000 Data Register    (R/W) */
  __IO   uint32_t  STATE;         /*!< Offset: 0x004 Status Register  (R/W) */
  __IO   uint32_t  CTRL;          /*!< Offset: 0x008 Control Register (R/W) */
  union {
    __I    uint32_t  INTSTATUS;   /*!< Offset: 0x00C Interrupt Status Register (R/ ) */
    __O    uint32_t  INTCLEAR;    /*!< Offset: 0x00C Interrupt Clear Register ( /W) */
  };
	
  __IO   uint32_t  BAUDDIV;       /*!< Offset: 0x010 Baudrate Divider Register (R/W) */

}  UART_TypeDef;

#define UART                ((UART_TypeDef          *) UART_BASE          )
/*  UART DATA Register Definitions */

#define  UART_DATA_Pos               0                                            /*!<  UART_DATA_Pos: DATA Position */
#define  UART_DATA_Msk              (0xFFul <<  UART_DATA_Pos)               /*!<  UART DATA: DATA Mask */

#define  UART_STATE_RXOR_Pos         3                                            /*!<  UART STATE: RXOR Position */
#define  UART_STATE_RXOR_Msk         (0x1ul <<  UART_STATE_RXOR_Pos)         /*!<  UART STATE: RXOR Mask */

#define  UART_STATE_TXOR_Pos         2                                            /*!<  UART STATE: TXOR Position */
#define  UART_STATE_TXOR_Msk         (0x1ul <<  UART_STATE_TXOR_Pos)         /*!<  UART STATE: TXOR Mask */

#define  UART_STATE_RXBF_Pos         1                                            /*!<  UART STATE: RXBF Position */
#define  UART_STATE_RXBF_Msk         (0x1ul <<  UART_STATE_RXBF_Pos)         /*!<  UART STATE: RXBF Mask */

#define  UART_STATE_TXBF_Pos         0                                            /*!<  UART STATE: TXBF Position */
#define  UART_STATE_TXBF_Msk         (0x1ul <<  UART_STATE_TXBF_Pos )        /*!<  UART STATE: TXBF Mask */

#define  UART_CTRL_HSTM_Pos          6                                            /*!<  UART CTRL: HSTM Position */
#define  UART_CTRL_HSTM_Msk          (0x01ul <<  UART_CTRL_HSTM_Pos)         /*!<  UART CTRL: HSTM Mask */

#define  UART_CTRL_RXORIRQEN_Pos     5                                            /*!<  UART CTRL: RXORIRQEN Position */
#define  UART_CTRL_RXORIRQEN_Msk     (0x01ul <<  UART_CTRL_RXORIRQEN_Pos)    /*!<  UART CTRL: RXORIRQEN Mask */

#define  UART_CTRL_TXORIRQEN_Pos     4                                            /*!<  UART CTRL: TXORIRQEN Position */
#define  UART_CTRL_TXORIRQEN_Msk     (0x01ul <<  UART_CTRL_TXORIRQEN_Pos)    /*!<  UART CTRL: TXORIRQEN Mask */

#define  UART_CTRL_RXIRQEN_Pos       3                                            /*!<  UART CTRL: RXIRQEN Position */
#define  UART_CTRL_RXIRQEN_Msk       (0x01ul <<  UART_CTRL_RXIRQEN_Pos)      /*!<  UART CTRL: RXIRQEN Mask */

#define  UART_CTRL_TXIRQEN_Pos       2                                            /*!<  UART CTRL: TXIRQEN Position */
#define  UART_CTRL_TXIRQEN_Msk       (0x01ul <<  UART_CTRL_TXIRQEN_Pos)      /*!<  UART CTRL: TXIRQEN Mask */

#define  UART_CTRL_RXEN_Pos          1                                            /*!<  UART CTRL: RXEN Position */
#define  UART_CTRL_RXEN_Msk          (0x01ul <<  UART_CTRL_RXEN_Pos)         /*!<  UART CTRL: RXEN Mask */

#define  UART_CTRL_TXEN_Pos          0                                            /*!<  UART CTRL: TXEN Position */
#define  UART_CTRL_TXEN_Msk          (0x01ul <<  UART_CTRL_TXEN_Pos)         /*!<  UART CTRL: TXEN Mask */

#define  UART_INTSTATUS_RXORIRQ_Pos  3                                            /*!<  UART CTRL: RXORIRQ Position */
#define  UART_CTRL_RXORIRQ_Msk       (0x01ul <<  UART_INTSTATUS_RXORIRQ_Pos) /*!<  UART CTRL: RXORIRQ Mask */

#define  UART_CTRL_TXORIRQ_Pos       2                                            /*!<  UART CTRL: TXORIRQ Position */
#define  UART_CTRL_TXORIRQ_Msk       (0x01ul <<  UART_CTRL_TXORIRQ_Pos)      /*!<  UART CTRL: TXORIRQ Mask */

#define  UART_CTRL_RXIRQ_Pos         1                                            /*!<  UART CTRL: RXIRQ Position */
#define  UART_CTRL_RXIRQ_Msk         (0x01ul <<  UART_CTRL_RXIRQ_Pos)        /*!<  UART CTRL: RXIRQ Mask */

#define  UART_CTRL_TXIRQ_Pos         0                                            /*!<  UART CTRL: TXIRQ Position */
#define  UART_CTRL_TXIRQ_Msk         (0x01ul <<  UART_CTRL_TXIRQ_Pos)        /*!<  UART CTRL: TXIRQ Mask */

#define  UART_BAUDDIV_Pos            0                                            /*!<  UART BAUDDIV: BAUDDIV Position */
#define  UART_BAUDDIV_Msk            (0xFFFFFul <<  UART_BAUDDIV_Pos)        /*!<  UART BAUDDIV: BAUDDIV Mask */

#endif  

