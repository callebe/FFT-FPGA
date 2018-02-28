#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include "xuartps.h"

//Defini��es
#define LED 0x2
#define Botton 0x1
#define GPIO_CHANNEL 1 //Canal de GPIO a ser Usada


int main(){

	// Declara��o de Vari�veis
	int Status; //Vari�vel de inicializa��o
	XGpio my_Gpio; //Struct do Drive da GPIO
	XUartPs Uart_Ps;//Struct do Drive da UARTPs
	XUartPs_Config *Config_UARTPS; //Struct de Configura��o da UART da PS
	u8 Data = 'H';

	//Inicializa��o da Plantaforma
	init_platform();

	//Configura��o da GPIO
	Status = XGpio_Initialize(&my_Gpio, XPAR_AXI_GPIO_0_DEVICE_ID); //Inicializa��o da GPIO e Verifica��o de Efetiva��o da Inicializa��o
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XGpio_SetDataDirection(&my_Gpio, GPIO_CHANNEL, Botton); //Sele��o de dire��o da GPIO 1 - entra 0 - sai

	//Configura��o da Uart PS
	Config_UARTPS = XUartPs_LookupConfig(XPAR_XUARTPS_1_DEVICE_ID); //Verifica��o de Efetiva��o da Configura��o
	if (NULL == Config_UARTPS) {
		return XST_FAILURE;
	}
	Status = XUartPs_CfgInitialize(&Uart_Ps, Config_UARTPS, Config_UARTPS->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	XUartPs_SetBaudRate(&Uart_Ps, 115200); //Configura��o do BoudRate

	//Envio de dados por Bit
	XUartPs_Send(&Uart_Ps, &Data, 1);

	while(1){
		Data = XGpio_DiscreteRead(&my_Gpio, GPIO_CHANNEL); //Le o valor do canal
		if(Data & Botton){
			XGpio_DiscreteWrite(&my_Gpio, GPIO_CHANNEL, (Data & ~LED)); // Define o valor do canal
		}
		else{
			XGpio_DiscreteWrite(&my_Gpio, GPIO_CHANNEL, (Data + LED)); // Define o valor do canal
			//Envio de dados por Bit
			XUartPs_Send(&Uart_Ps, &Data, 1);
		}
    }

    cleanup_platform();
    return 0;
}
