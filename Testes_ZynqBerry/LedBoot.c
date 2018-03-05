#include "xparameters.h"
#include "xgpio.h"
#include <stdio.h>
#include <stdlib.h>

int main()
{
    XGpio led;
   	XGpio_Config led_config;
   	char s_interval[100];
   	int i_interval = 1000;
   	int count;

   	led_config.DeviceId = XPAR_AXI_GPIO_0_DEVICE_ID;
	XGpio_CfgInitialize(&led, &led_config, XPAR_AXI_GPIO_0_BASEADDR);
	XGpio_SetDataDirection(&led, 1, 0);

	while(1){
		printf("input Interval[ms] (now %d [ms])\n", i_interval);
		scanf("%s",s_interval);
		i_interval = atoi(s_interval);
		printf("set %d[ms]\n\n",i_interval);
		count = i_interval * 50000; //50000 = 50000000[MHz] / 1000 (input [ms])
		XGpio_DiscreteWrite(&led,1,count);
	}


    return 0;
}
