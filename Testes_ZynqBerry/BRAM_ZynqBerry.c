#include <stdio.h>
#include "platform.h"
#include "xil_io.h"
#include "xparameters.h"


int main(){

	int word1;
	int word2;
	int word3;
	int word4;
	int word5;

    init_platform();

    // 64Bits
    Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x00, 0xAB); //]
    Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x01, 0xFF); //] Word 1
    Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x02, 0x34); //]
    Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x03, 0x8C); //]
    Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x04, 0xAC); //}
	Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x05, 0xF0); //} Word 2
	Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x06, 0x35); //}
	Xil_Out8(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x07, 0x8D); //}

	// 64Bits
    Xil_Out16(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x08, 0xABAB); //] Word 3
    Xil_Out16(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x0A, 0xFFFF); //]
    Xil_Out16(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x0C, 0x3434); //} Word 4
    Xil_Out16(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x0E, 0x8C8C); //}

    // 32Bits
    Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x10, 0xAAAABBBB); //] Word5

    while(1){
    	word1 = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR);
    	word2 = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x04);
    	word3 = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x08);
    	word4 = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x0C);
    	word5 = Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x10);
    	printf("Word1 = 0x%08x\n", word1);
    	printf("Word2 = 0x%08x\n", word2);
    	printf("Word3 = 0x%08x\n", word3);
    	printf("Word4 = 0x%08x\n", word4);
    	printf("Word5 = 0x%08x\n", word5);
    }
    cleanup_platform();
    return 0;
}
