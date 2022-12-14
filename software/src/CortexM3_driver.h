#include "CortexM3.h"

extern uint32_t  uart_init( UART_TypeDef * UART, uint32_t divider, uint32_t tx_en,
                           uint32_t rx_en, uint32_t tx_irq_en, uint32_t rx_irq_en, uint32_t tx_ovrirq_en, uint32_t rx_ovrirq_en);

  /**
   * @brief Returns whether the UART RX Buffer is Full.
   */

 extern uint32_t  uart_GetRxBufferFull( UART_TypeDef * UART);

  /**
   * @brief Returns whether the UART TX Buffer is Full.
   */

 extern uint32_t  uart_GetTxBufferFull( UART_TypeDef * UART);

  /**
   * @brief Sends a character to the UART TX Buffer.
   */


 extern void  uart_SendChar( UART_TypeDef * UART, char txchar);

  /**
   * @brief Receives a character from the UART RX Buffer.
   */

 extern char  uart_ReceiveChar( UART_TypeDef * UART);

  /**
   * @brief Returns UART Overrun status.
   */

 extern uint32_t  uart_GetOverrunStatus( UART_TypeDef * UART);

  /**
   * @brief Clears UART Overrun status Returns new UART Overrun status.
   */

 extern uint32_t  uart_ClearOverrunStatus( UART_TypeDef * UART);

  /**
   * @brief Returns UART Baud rate Divider value.
   */

 extern uint32_t  uart_GetBaudDivider( UART_TypeDef * UART);

  /**
   * @brief Return UART TX Interrupt Status.
   */

 extern uint32_t  uart_GetTxIRQStatus( UART_TypeDef * UART);

  /**
   * @brief Return UART RX Interrupt Status.
   */

 extern uint32_t  uart_GetRxIRQStatus( UART_TypeDef * UART);

  /**
   * @brief Clear UART TX Interrupt request.
   */

 extern void  uart_ClearTxIRQ( UART_TypeDef * UART);

  /**
   * @brief Clear UART RX Interrupt request.
   */

 extern void  uart_ClearRxIRQ( UART_TypeDef * UART);

  /**
   * @brief Set CM3DS_MPS2 Timer for multi-shoot mode with internal clock
   */
