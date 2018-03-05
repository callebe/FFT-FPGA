// Includes de Bibliotecas
#include <stdio.h> //Biblioteca de fun��es b�sicas
#include "platform.h" //Bilbioteca de drivers do TE0726
#include "xscutimer.h" //Biblioteca de drivers do SCU Driver
#include "xparameters.h" //Biblioteca de Defini��es do TE0726
#include "xscugic.h" //Biblioteca de Drivers do GIC (General Interrrupt Control)

//Defines
#define Interrupt_Count_Timeout_value 50

//Prototipo das fun��es
static void timer_interrupt_handler (void *CallBackRef);

//Vari�veis Globias
int InterruptCounter = 0;

int main(){

	int Status;

    init_platform();

    //Declara��o e Configura��o do Timer SCU
    XScuTimer my_Timer; //Declara��o da inst�ncia
    XScuTimer_Config *Timer_Config; //Declara��o da configura��o do timer
    Timer_Config = XScuTimer_LookupConfig(XPAR_PS7_SCUTIMER_0_DEVICE_ID); //Preenchimento das Configura��o do timer
	Status = XScuTimer_CfgInitialize(&my_Timer, Timer_Config, Timer_Config->BaseAddr); // Configura��o do Timer e Verifica��o
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    //Declara��o e Configura��o do GIC
    XScuGic my_Gic;  //Declara��o da inst�ncia
    XScuGic_Config *Gic_Config; //Declara��o da configura��o do Gic
    Gic_Config = XScuGic_LookupConfig(XPAR_PS7_SCUGIC_0_DEVICE_ID); // Preenchimento das Configura��es do GIC
    Status = XScuGic_CfgInitialize(&my_Gic, Gic_Config, Gic_Config->CpuBaseAddress); //Configura��o do GIC e Verifica��o
    if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

    //Inicializa��o manipulador de exce��es do ARM
    Xil_ExceptionInit();

    //Conecta o Xilinx General Interrupt handler fornecido a l�gica de tratamento de interrup��o no processador
    //Todas as interrup��es passam pelo controle de interrup��es, e ent�o o processador ARM pergunta primeiro ao
    //controle de interrup��o qual periferico gerou a interrup��o. O manipulador que faz isso � fornecido pela Xilinx
    //e � chamado de "XScuGic_InterruptHandler"
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_IRQ_INT, (Xil_ExceptionHandler)XScuGic_InterruptHandler, &my_Gic);

    //Conecta o tratamento de interrup��o para o timer
    Status = XScuGic_Connect(&my_Gic, XPAR_SCUTIMER_INTR, (Xil_ExceptionHandler)timer_interrupt_handler, (void *)&my_Timer);

    //Habilita o Input da interrup��o no GIC para a interrup��o pelo timer
    XScuGic_Enable(&my_Gic, XPAR_SCUTIMER_INTR);

    //Habilita o Output da interrup��o no timer
    XScuTimer_EnableInterrupt(&my_Timer);

    //Habilita as interrup��es no processador ARM
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

	//Os drivers Xilinx automaticamente passaram a instancia do periferico que gerou a interrup��o usando o CallBackRef.
	XScuTimer *my_Timer_LOCAL = (XScuTimer *) CallBackRef;

	//Atraves do parametro myTimer_LOCAL eu posso verificar qual o timer que provocou a interrup��o, se eu estiver usando
	//o mesmo tratamento de interrup��o para os dois
	if(XScuTimer_IsExpired(my_Timer_LOCAL)){
		//Lipar flag de interrup��o
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
