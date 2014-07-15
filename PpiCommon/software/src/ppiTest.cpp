#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/mman.h>
#include <iostream>
#include <iomanip>
#include <RceG3CpuSim.h>
#include <PpiDmaSim.h>
using namespace std;
 
int main(int argc, char **argv) {
   uint              memSize  = 4096 * 10;
   uint              buffSize = 1024;
   unsigned char     rxData[buffSize];
   unsigned char     txData[buffSize];
   unsigned char *   mem;
   uint              x;
   uint              y;
   uint              txHdrSize;
   uint              txPaySize;
   uint              rxHdrSize;
   uint              rxPaySize;
   uint              txType;
   uint              rxType;
   uint              rxErr;
   RceG3CpuSim     * rce;
   PpiDmaSim       * dma;
   int               ret;

   mem = (unsigned char *)malloc(memSize);

   if ( mem == NULL ) {
      return 1;
      printf("Malloc Failed\n");
   }

   rce = new RceG3CpuSim(mem,memSize,0x0000FFFF);
   if ( ! rce->open() ) {
      printf("Failed to open rce\n");
      return 1;
   }

   rce->setVerbose(true);

   rce->write(0x40000000,0x80000008);
   rce->write(0x40000004,0x80000009);
   rce->write(0x40000008,0x80000010);
   rce->write(0x4000000C,0x80000011);

   rce->write(0x40008000,0xFFFFFFFF);

   dma = new PpiDmaSim(0,rce,mem,memSize);

   txHdrSize = 80;
   txPaySize = 128;
   txType    = 3;

   for (x=0; x < (txHdrSize+txPaySize); x++) txData[x] = x;

   for (y=0; y < 2; y++) {

      printf("Write\n");
      ret = dma->write(txData,txHdrSize,txPaySize,txType);
      printf("Write Done. Ret=%i\n",ret);

      printf("Read\n");
      while (dma->read(rxData,buffSize,&rxType,&rxErr,&rxHdrSize,&rxPaySize) == 0 ) usleep(100);
      printf("Read Done\n");

      if ( rxHdrSize != txHdrSize ) printf("Header size mismatch!\n");
      if ( rxPaySize != txPaySize ) printf("Payload size mismatch!\n");

      for (x=0; x < (txHdrSize+txPaySize); x++) {
         if ( txData[x] != rxData[x] ) printf("Data mismatch. Idx=%i Got=0x%08x Exp=0x%08x\n",x,rxData[x],txData[x]);
      }

      printf("\n\n\n ------------ Loop %i DOne --------------------\n\n\n",y);
   }

   ret = rce->read(0x40008008);
   printf("Int status = 0x%08x\n",ret);
   ret = rce->read(0x40008008);
   printf("Int status = 0x%08x\n",ret);

   printf("Simulation Done\n");
}

