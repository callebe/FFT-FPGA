// Includes de Bibliotecas
#include <stdio.h> //Biblioteca de funções básicas
#include "platform.h" //Bilbioteca de drivers do TE0726
#include "xscutimer.h" //Biblioteca de drivers do SCU Driver
#include "xparameters.h" //Biblioteca de Definições do TE0726
#include "xscugic.h" //Biblioteca de Drivers do GIC (General Interrrupt Control)

//Defines
#define Interrupt_Count_Timeout_value 50

//Prototipo das funções
static void timer_interrupt_handler (void *CallBackRef);

//Variáveis Globias
int InterruptCounter = 0;

int main(){

	int Status;

    init_platform();

    //Declaração e Configuração do Timer SCU
    XScuTimer my_Timer; //Declaração da instância
    XScuTimer_Config *Timer_Config; //Declaração da configuração do timer
    Timer_Config = XScuTimer_LookupConfig(XPAR_PS7_SCUTIMER_0_DEVICE_ID); //Preenchimento das Configuração do timer
	Status = XScuTimer_CfgInitialize(&my_Timer, Timer_Config, Timer_Config->BaseAddr); // Configuração do Timer e Verificação
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    //Declaração e Configuração do GIC
    XScuGic my_Gic;  //Declaração da instância
    XScuGic_Config *Gic_Config; //Declaração da configuração do Gic
    Gic_Config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID); // Preenchimento das Configurações do GIC
    Status = XScuGic_CfgInitialize(&my_Gic, Gic_Config, Gic_Config->CpuBaseAddress); //Configuração do GIC e Verificação
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    //Inicialização manipulador de exceções do ARM
    Xil_ExceptionInit();

    //Conecta o Xilinx General Interrupt handler fornecido a lógica de tratamento de interrupção no processador
    //Todas as interrupções passam pelo controle de interrupções, e então o processador ARM pergunta primeiro ao
    //controle de interrupção qual periferico gerou a interrupção. O manipulador que faz isso é fornecido pela Xilinx
    //e é chamado de "XScuGic_InterruptHandler"
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &my_Gic);

    //Conecta o tratamento de interrupção para o timer
    Status = XScuGic_Connect(&my_Gic, XPAR_SCUTIMER_INTR, (Xil_ExceptionHandler)timer_interrupt_handler, (void *)&my_Timer);

    //Habilita o Input da interrupção no GIC para a interrupção pelo timer
    XScuGic_Enable(&my_Gic, XPAR_SCUTIMER_INTR);

    //Habilita o Output da interrupção no timer
    XScuTimer_EnableInterrupt(&my_Timer);

    //Habilita as interrupções no processador ARM
    Xil_ExceptionEnable();

    //Carrega o timer com o valor para um segundo
    XScuTimer_LoadTimer(&my_Timer, XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ/2);

    //Habilitar a recarga automatica do timer
    XScuTimer_EnableAutoReload(&my_Timer);

    //Inicia o timer SCU
    XScuTimer_Start(&my_Timer);

    while(1);

    cleanup_platform();
    return 0;
}


static void timer_interrupt_handler (void *CallBackRef){

	//Os drivers Xilinx automaticamente passaram a instancia do periferico que gerou a interrupção usando o CallBackRef.
	XScuTimer *my_Timer_LOCAL = (XScuTimer *) CallBackRef;

	//Atraves do parametro myTimer_LOCAL eu posso verificar qual o timer que provocou a interrupção, se eu estiver usando
	//o mesmo tratamento de interrupção para os dois
	if(XScuTimer_IsExpired(my_Timer_LOCAL)){
		//Lipar flag de interrupção
		XScuTimer_ClearInterruptStatus(my_Timer_LOCAL);

		//Incrementa o contador
		InterruptCounter++;

		//Printa o numero de contagens
		printf("Contagen %d \n", InterruptCounter);
		if(InterruptCounter > Interrupt_Count_Timeout_value){
			//Para a recarga de contagem do contador
			XScuTimer_DisableAutoReload(my_Timer_LOCAL);
		}

	}

}
