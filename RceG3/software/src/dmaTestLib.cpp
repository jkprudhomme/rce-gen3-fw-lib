//////////////////////////////////////////////////////////////////////////////
// This file is part of 'SLAC RCE Core'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'SLAC RCE Core', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
//////////////////////////////////////////////////////////////////////////////
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

   rce->setVerbose(true);
   sleep(5);
   rce->write(0x88000480,1);
   sleep(100);

   dma = new AxiStreamDmaSim(master,0x60000000,0x60010000,mem,buffSize*buffCount,buffSize);

   for (txSize=120; txSize < 260; txSize++) {
      printf("Transmit Size %i\n",txSize);

      for (x=0; x < txSize; x++) txData[x] = x;
      txData[0] = 0;
      txData[1] = 0;
      txData[2] = 0;
      txData[3] = 0;

      // transmit 4 frames
      for (x=0; x < 4; x++) dma->write(txData,txSize);

      printf("Done\n");

      printf("Receive Size %i\n",txSize);

      // receive 4 frames
      for (x=0; x < 4; x++) {
         do {
            rxSize = dma->read(rxData,buffSize);
            usleep(100);
         } while (rxSize == 0);

         if ( rxSize != txSize ) {
            printf("Rx Size mismatch. Got %i, Exp %i\n",rxSize,txSize);
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

