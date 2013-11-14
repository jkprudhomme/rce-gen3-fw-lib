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
#include "../lib/MemorySpaceMap.h"
using namespace std;
 
int main(int argc, char **argv) {
   uint      x;
   uint      i;
   ObPpiDesc ob[4];
   IbPpiDesc ib[4];
   uint      val;
   uint      psize;
   uint      iboffset;
   uint      oboffset;
   uint      maxLane;
   bool      err;
   bool      stop;

   for (i=0; i < 4; i++) {
      ob[i].alloc = 1024;
      ob[i].data = (uchar *)malloc(ob[i].alloc);

      ib[i].alloc = 1024;
      ib[i].data = (uchar *)malloc(ib[i].alloc);
   }

   // Memory space object
   MemorySpaceMap mspace;
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
   val     = 0;
   stop    = false;
   maxLane = 4;

   for ( psize = 160; psize < 168; psize++ ) {
      for ( oboffset = 0; oboffset < 8; oboffset++ ) {
         for ( iboffset = 0; iboffset < 8; iboffset++ ) {

            //psize    = 0;
            //psize    = 162;
            //oboffset = 0;
            //iboffset = 0;

            cout << "------------------------------------------------------" << endl;
            cout << "Start" << endl;
            cout << "ob psize   =" << dec << psize    << endl;
            cout << "ob boffset =" << dec << oboffset << endl;
            cout << "ib boffset =" << dec << iboffset << endl;

            for (i=0; i < maxLane; i++) {
               ob[i].psize   = psize;
               ob[i].boffset = oboffset;
               ib[i].boffset = iboffset;
               ob[i].hsize   = 40;  // 10 words

               for (x=0; x < ob[i].hsize+ob[i].psize; x++) {
                  ob[i].data[x] = val;
               val++;
            }
               ofifo[i]->pushEntry(&(ob[i]));
            }

            for ( i=0; i < maxLane; i++ ) {
               cout << "------" << endl;
               cout << "Read lane " << dec << i << endl;
               cout << "------" << endl;
               while ( ififo[i]->popEntry(&(ib[i])) == 0 ) usleep(100);

               cout << "Got inbound data idx " << dec << i 
                    << " hsize=" << dec << ib[i].hsize 
                    << " psize=" << dec << ib[i].psize << endl;

               if ( ob[i].psize != ib[i].psize ) {
                  cout << "Payload size mismatch" << endl;
                  return(1);
               }

               err = false;
               for (x=4; x < ib[i].hsize+ib[i].psize; x++) {
                  if ( ib[i].data[x] != ob[i].data[x] ) err = true;
               }

               if ( err ) {
                  cout << "Data mismatch lane " << dec << i << endl;
                  for (x=4; x < ib[i].hsize+ib[i].psize; x++) {
                     cout << "Offset 0x" << hex << setw(4) << setfill('0') << x 
                          << " Exp 0x" << hex << setw(2) << setfill('0') << (uint)ob[i].data[x]
                          << " Got 0x" << hex << setw(2) << setfill('0') << (uint)ib[i].data[x];
                     if (  ob[i].data[x] != ib[i].data[x] ) cout << "   ***";
                     cout << endl;
                  }
                  cout << "Data mismatch lane " << dec << i << endl;
                  stop = true;
               }

               cout << "Done idx " << dec << i << endl;
               cout << "ob psize   =" << dec << ob[i].psize   << endl;
               cout << "ob boffset =" << dec << ob[i].boffset << endl;
               cout << "ib boffset =" << dec << ib[i].boffset << endl;
            }

            if ( stop ) return(1);
            //cout << "Sleep" << endl; sleep(5);
         }
      }
   }

   cout << "Test Pass." << endl;
}

