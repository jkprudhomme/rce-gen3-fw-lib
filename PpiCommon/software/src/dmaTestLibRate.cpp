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
#include <AxiStreamDmaSim.h>
#include <AxiMasterSim.h>
using namespace std;
 
int main(int argc, char **argv) {
   uint              buffCount = 8;
   uint              buffSize  = 1024;
   unsigned char     rxData[buffSize];
   unsigned char     txData[buffSize];
   unsigned char *   mem;
   uint              x;
   uint              y;
   uint              txSize;
   uint              rxSize;
   RceG3CpuSim     * rce;
   AxiMasterSim    * master;
   AxiStreamDmaSim * dma;
   uint            wcount;
   uint            rcount;
   uint            err;

   mem = (unsigned char *)malloc(buffSize*buffCount);

   if ( mem == NULL ) {
      return 1;
      printf("Malloc Failed\n");
   }

   rce = new RceG3CpuSim(mem,buffSize*buffCount);
   if ( ! rce->open() ) {
      printf("Failed to open rce\n");
      return 1;
   }
   master = rce->getMaster(0x40000000);

   rce->setVerbose(0);

   dma = new AxiStreamDmaSim(master,0x60000000,0x60010000,mem,buffSize*buffCount,buffSize);

   txSize = 512;

   for (x=0; x < txSize; x++) txData[x] = x;
   txData[0] = 0;
   txData[1] = 0;
   txData[2] = 0;
   txData[3] = 0;

   rcount = 0;
   wcount = 0;
   err = 0;

   while (1) {

      if ( dma->write(txData,txSize) > 0 ) {
         printf("Write Frame. Size=%i\n",txSize);
         wcount++;
      }

      if ( (wcount - rcount) > 22 ) rxSize = dma->read(rxData,buffSize);
      else rxSize = 0;

      if ( rxSize > 0 ) {
         rcount++;
         err = 0;

         printf("Read Frame. Size=%i\n",rxSize);

         if ( rxSize != txSize ) {
            printf("Rx Size mismatch. Got %i, Exp %i\n",rxSize,txSize);
            err = 1;
         }

         if ( *((uint *)rxData) != *((uint *)txData) ) {
            printf("First word mismatch. Got 0x%08x, Exp 0x%08x\n",*((uint *)rxData),*((uint *)txData));
            err = 1;
         }

         for (y=4; y < rxSize; y++) {
            if (rxData[y] != txData[y]) {
               printf("Rx data mismatch. Size=%i, Pos %i, Got %i, Exp %i\n", txSize,y,(uint)rxData[y],(uint)txData[y]);
               err = 1;
            }
         }
      }
      if (err > 0 ) return(1);
   }
}

