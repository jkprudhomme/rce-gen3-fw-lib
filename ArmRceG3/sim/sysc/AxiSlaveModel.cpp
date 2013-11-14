#include "AxiSlaveModel.h"
#include <iomanip>
using namespace std;

void AxiSlaveModel::slaveThread(void) {
   AxiWriteAddr writeAddr;
   AxiWriteData writeData;
   AxiWriteComp writeComp;
   AxiReadAddr  readAddr;
   AxiReadData  readData;
   bool         writeAddrBusy;
   bool         writeDataBusy;
   bool         writeCompBusy;
   bool         readAddrBusy;
   bool         readDataBusy;
   AxiSharedMem *smem;

   // Get id
   uint id       = masterId.read().to_uint();
   string system = "SimAxiSlave";

   // Open shared memory
   smem = AxiSharedMem::open(system, id);

   // Error
   if ( smem == NULL ) {
      cout << "!!!!!!!!!!!!!! Failed to open shared memory !!!!!!!!!!!!!!!!!" << endl;
      return;
   }

   // Init shared memory
   smem->init();

   // Debug
   cout << "Opened shared memory system=" << system << ", id=" << dec << id << endl;

   // Init
   writeAddrBusy = false;
   writeDataBusy = false;
   writeCompBusy = false;
   readAddrBusy  = false;
   readDataBusy  = false;

   // Init
   axiClkRst.write(SC_LOGIC_0);
   racount.write(0);
   rcount.write(0);
   wacount.write(0);
   wcount.write(0);
   awready.write(SC_LOGIC_0);
   wready.write(SC_LOGIC_0);
   bvalid.write(SC_LOGIC_0);
   bresp.write(0);
   bid.write(0);
   rvalid.write(SC_LOGIC_0);
   rdataH.write(0);
   rdataL.write(0);
   rlast.write(SC_LOGIC_0);
   rid.write(0);
   rresp.write(0);

   // Run forever
   while (1) {

      // Clock Edge
      wait();

      // Update clock count
      smem->incrClkCnt();

      //---------------------------------
      // Write Address
      //---------------------------------

      // Valid is asserted
      if ( (!writeAddrBusy) && awvalid.read() == 1 ) {
         writeAddr.awaddr  = awaddr.read().to_uint();
         writeAddr.awid    = awid.read().to_uint();
         writeAddr.awlen   = awlen.read().to_uint();
         writeAddr.awsize  = awsize.read().to_uint();
         writeAddr.awburst = awburst.read().to_uint();
         writeAddr.awlock  = awlock.read().to_uint();
         writeAddr.awcache = awcache.read().to_uint();
         writeAddr.awprot  = awprot.read().to_uint();
         writeAddr.awqos   = awqos.read().to_uint();
         writeAddr.awuser  = awuser.read().to_uint();
         smem->setWriteAddr(&writeAddr);
         writeAddrBusy = true;
      }

      //---------------------------------
      // Write Data
      //---------------------------------

      // Valid is asserted
      if ( (!writeDataBusy) && wvalid.read() == 1 ) {
         writeData.wdataH = wdataH.read().to_uint();
         writeData.wdataL = wdataL.read().to_uint();
         writeData.wlast  = (wlast.read() == 1);
         writeData.wid    = wid.read().to_uint();
         writeData.wstrb  = wstrb.read().to_uint();
         smem->setWriteData(&writeData);
         writeDataBusy = true;
      }

      //---------------------------------
      // Write Completion
      //---------------------------------

      // Wait for ready
      if ( writeCompBusy ) {

         // ready is asserted
         if ( bready.read() == 1 ) {
            writeCompBusy = false;
            bvalid.write(SC_LOGIC_0);
         }
      }

      // Ready for next transaction
      else {

         // Software has posted a transaction
         if ( smem->getWriteComp(&writeComp) ) {
            bvalid.write(SC_LOGIC_1);
            bresp.write(writeComp.bresp);
            bid.write(writeComp.bid);
            writeCompBusy = true;
         }
      }

      //---------------------------------
      // Read Address
      //---------------------------------

      // Valid is asserted
      if ( (!readAddrBusy) && arvalid.read() == 1 ) {
         readAddr.araddr  = araddr.read().to_uint();
         readAddr.arid    = arid.read().to_uint();
         readAddr.arlen   = arlen.read().to_uint();
         readAddr.arsize  = arsize.read().to_uint();
         readAddr.arburst = arburst.read().to_uint();
         readAddr.arlock  = arlock.read().to_uint();
         readAddr.arcache = arcache.read().to_uint();
         readAddr.arprot  = arprot.read().to_uint();
         readAddr.arqos   = arqos.read().to_uint();
         readAddr.aruser  = aruser.read().to_uint();
         smem->setReadAddr(&readAddr);
         readAddrBusy = true;
      }

      //---------------------------------
      // Read Data   
      //---------------------------------

      // Wait for ready
      if ( readDataBusy ) {

         // ready is asserted
         if ( rready.read() == 1 ) {
            readDataBusy = false;
            rvalid.write(SC_LOGIC_0);
         }
      }

      // Ready for next transaction
      else {

         // Software has posted a transaction
         if ( smem->getReadData(&readData) ) {
            rvalid.write(SC_LOGIC_1);
            rdataH.write(readData.rdataH);
            rdataL.write(readData.rdataL);
            rlast.write(readData.rlast?SC_LOGIC_1:SC_LOGIC_0);
            rid.write(readData.rid);
            rresp.write(readData.rresp);
            readDataBusy = true;
         }
      }

      //---------------------------------
      // Handshaking
      //---------------------------------
      usleep(1000);

      if ( smem->readyWriteAddr() ) {
         awready.write(SC_LOGIC_1);
         writeAddrBusy = false;
      }
      else awready.write(SC_LOGIC_0);

      if ( smem->readyWriteData() ) {
         wready.write(SC_LOGIC_1);
         writeDataBusy = false;
      } else wready.write(SC_LOGIC_0);

      if ( smem->readyReadAddr() ) {
         arready.write(SC_LOGIC_1);
         readAddrBusy = false;
      } else arready.write(SC_LOGIC_0);
   }
}
