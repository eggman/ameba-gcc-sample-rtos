#include "cmsis_os.h"

osThreadId main_tid = 0;

void main_task(void const *arg)
{
    int i=0;

    while (1) {
        DiagPrintf("Hello World : %d\r\n", i++);
        HalDelayUs(1000000);
    }
}

int main(void)
{
    osKernelInitialize();

    DiagPrintf("Starting main task\n");

    osThreadDef(main_task, osPriorityHigh, 1, 8152);
    main_tid = osThreadCreate (osThread (main_task), NULL);

    osKernelStart();
    while(1);
    return 0;
}
