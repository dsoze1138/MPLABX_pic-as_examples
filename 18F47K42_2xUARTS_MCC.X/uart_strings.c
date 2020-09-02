/*
 * File:   uart_strings.c
 * Author: dan1138
 *
 * Created on August 30, 2020, 1:01 PM
 */


#include "mcc_generated_files/mcc.h"
#include "uart_strings.h"
#include <stdint.h>
/*
 * put string to UART1
 */
void UART1_puts(char *pszString)
{
    uint8_t temp;
    
    if(pszString)
    {
        while(!!(temp = (uint8_t) *pszString++)) UART1_Write(temp);
    }
}
/*
 * put string to UART2
 */
void UART2_puts(char *pszString)
{
    uint8_t temp;
    
    if(pszString){
        while(!!(temp = (uint8_t) *pszString++)) UART2_Write(temp);
    }
}
