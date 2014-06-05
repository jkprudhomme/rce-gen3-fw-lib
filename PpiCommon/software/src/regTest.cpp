#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <sys/mman.h>
#include <iostream>
#include <iomanip>
#include "../lib/IbHeaderFifo.h"
#include "../lib/ObHeaderFifo.h"
#include "../lib/QuadWordFifo.h"
#include "../lib/ObPpiFifo.h"
#include "../lib/IbPpiFifo.h"
#include "../lib/ConfigSpace.h"
#include "../lib/DmaSpace.h"
#include "../lib/MemorySpaceSim.h"
using namespace std;
 
int main(int argc, char **argv) {
   uint      x;
   uint      i;
   ObPpiDesc ob[4];
   IbPpiDesc ib[4];
   uint      * txData;
   uint      * rxData;

   for (i=0; i < 4; i++) {
      ob[i].alloc = 1024;
      ob[i].data = (uchar *)malloc(ob[i].alloc);

      ib[i].alloc = 1024;
      ib[i].data = (uchar *)malloc(ib[i].alloc);
   }

   // Memory space object
   MemorySpaceSim mspace;
   mspace.open();

   // Config space
   ConfigSpace cspace(&mspace); 

   // Dma space
   DmaSpace dspace(&mspace); 

   cspace.setWriteDmaCache ( 0xF );
   cspace.setReadDmaCache ( 0xF );
   cspace.setPpiWriteDmaCache ( 0x0 );
   cspace.setPpiReadDmaCache ( 0x0 );
   cspace.setMemBaseAddress (dspace.getDmaBase());
   cout << "Dma base=0x" << hex << setw(8) << setfill('0') << dspace.getDmaBase() << endl;

   // Setup Ppi FIFOs
   ObPpiFifo * ofifo[4];
   IbPpiFifo * ififo[4];
   for (x=0; x < 4; x++) {
      ofifo[x] = new ObPpiFifo(&cspace,&dspace,x);
      ififo[x] = new IbPpiFifo(&cspace,&dspace,x);
      ififo[x]->setEnable(true);
      ofifo[x]->setEnable(true);
   }

   // Generate read
   ob[3].psize   = 0;
   ob[3].boffset = 0;
   ib[3].boffset = 0;
   ob[3].hsize   = 24;
   //ob[3].hsize   = 8;

   txData = (uint *)ob[3].data;
   rxData = (uint *)ib[3].data;
   txData[0] = 0x80000000;
   txData[1] = 0x02000800;
   //txData[1] = 0x02000000;
   txData[2] = 0x11111111;
   txData[3] = 0xa5a5a5a5;
   txData[4] = 0x33333333;


   cout << "Sending outbound data " 
        << " hsize=" << dec << ob[3].hsize 
        << " psize=" << dec << ob[3].psize;
   for (x=0; x < (ob[3].hsize)/4; x++) cout << " d" << dec << x << "=0x" << hex << txData[x];
   cout << endl;

   ofifo[3]->pushEntry(&(ob[3]));

   cout << "Register request sent" << endl;

   while ( ififo[3]->popEntry(&(ib[3])) == 0 ) usleep(100);

   cout << "Got inbound data idx " 
        << " hsize=" << dec << ib[3].hsize 
        << " psize=" << dec << ib[3].psize;

   for (x=0; x < (ib[3].hsize)/4; x++) cout << " d" << dec << x << "=0x" << hex << rxData[x];
   cout << endl;
   
}

