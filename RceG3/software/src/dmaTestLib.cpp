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
   uint              txDest;
   uint              rxDest;
   uint              rxEofe;
   RceG3CpuSim     * rce;
   AxiMasterSim    * master;
   AxiStreamDmaSim * dma;

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

   //rce->setVerbose(true);
   //sleep(5);
   //rce->write(0x88000480,1);
   //sleep(100);

   dma = new AxiStreamDmaSim(master,0x60000000,0x60010000,mem,buffSize*buffCount,buffSize);

   txDest = 1;
   for (txSize=120; txSize < 260; txSize++) {
      printf("Transmit Size %i\n",txSize);

      for (x=0; x < txSize; x++) txData[x] = x;

      // transmit 4 frames
      for (x=0; x < 4; x++) dma->write(txData,txSize,txDest);

      printf("Done\n");

      printf("Receive Size %i\n",txSize);

      // receive 4 frames
      for (x=0; x < 4; x++) {
         do {
            rxSize = dma->read(rxData,buffSize,&rxDest,&rxEofe);
            usleep(100);
         } while (rxSize == 0);

         if ( rxSize != txSize ) {
            printf("Rx Size mismatch. Got %i, Exp %i\n",rxSize,txSize);
            return 1;
         }

         if ( rxDest != txDest ) {
            printf("Rx Dest mismatch. Got %i, Exp %i\n",rxDest,txDest);
            return 1;
         }

         if ( rxEofe != 0 ) {
            printf("Rx EOFE\n");
            return 1;
         }

         for (y=0; y < rxSize; y++) {
            if (rxData[y] != txData[y]) {
               printf("Rx data mismatch. Size=%i, Pos %i, Got %i, Exp %i\n", txSize,y,(uint)rxData[y],(uint)txData[y]);
               return 1;
            }
         }
      }
      printf("Done\n");
   }

   cout << "Simulation Pass." << endl;
}

