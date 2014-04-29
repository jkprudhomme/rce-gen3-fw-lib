#include "AxiMasterModel.h"
#include <iomanip>
using namespace std;

void AxiMasterModel::masterThread(void) {
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

   // Init
   writeAddrBusy = false;
   writeDataBusy = false;
   writeCompBusy = false;
   readAddrBusy  = false;
   readDataBusy  = false;

   // Get id
   uint id       = masterId.read().to_uint();
   string system = "SimAxiMaster";

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
   axiClkRst.write(SC_LOGIC_0);
   bready.write(SC_LOGIC_0);
   rready.write(SC_LOGIC_0);
   rdissuecap1_en.write(SC_LOGIC_0);
   wrissuecap1_en.write(SC_LOGIC_0);
   awvalid.write(SC_LOGIC_0);
   awaddr.write(0);
   awid.write(0);
   awlen.write(0);
   awsize.write(0);
   awburst.write(0);
   awlock.write(0);
   awcache.write(0);
   awprot.write(0);
   wvalid.write(SC_LOGIC_0);
   wdataH.write(0);
   wdataL.write(0);
   wlast.write(SC_LOGIC_0);
   wid.write(0);
   wstrb.write(0);
   bready.write(SC_LOGIC_0);
   arvalid.write(SC_LOGIC_0);
   araddr.write(0);
   arid.write(0);
   arlen.write(0);
   arsize.write(0);
   arburst.write(0);
   arlock.write(0);
   arprot.write(0);
   arcache.write(0);
   rready.write(SC_LOGIC_0);

   // Run forever
   while (1) {

      // Clock Edge
      wait();

      // Update clock count
      smem->incrClkCnt();

      //---------------------------------
      // Write Address
      //---------------------------------

      // Wait for ready
      if ( writeAddrBusy ) {

         // ready is asserted
         if ( awready.read() == 1 ) {
            writeAddrBusy = false;
            awvalid.write(SC_LOGIC_0);
         }
      }

      // Ready for next transaction
      else {

         // Software has posted a transaction
         if ( smem->getWriteAddr(&writeAddr) ) {
            awvalid.write(SC_LOGIC_1);
            awaddr.write((writeAddr.awaddr));
            awid.write((writeAddr.awid));
            awlen.write((writeAddr.awlen));
            awsize.write((writeAddr.awsize));
            awburst.write((writeAddr.awburst));
            awlock.write((writeAddr.awlock));
            awcache.write((writeAddr.awcache));
            awprot.write((writeAddr.awprot));
            writeAddrBusy = true;
         }
      }

      //---------------------------------
      // Write Data
      //---------------------------------

      // Wait for ready
      if ( writeDataBusy ) {

         // ready is asserted
         if ( wready.read() == 1 ) {
            writeDataBusy = false;
            wvalid.write(SC_LOGIC_0);
         }
      }

      // Ready for next transaction
      else {

         // Software has posted a transaction
         if ( smem->getWriteData(&writeData) ) {
            wvalid.write(SC_LOGIC_1);
            wdataH.write(writeData.wdataH);
            wdataL.write(writeData.wdataL);
            wlast.write(writeData.wlast?SC_LOGIC_1:SC_LOGIC_0);
            wid.write(writeData.wid);
            wstrb.write(writeData.wstrb);
            writeDataBusy = true;
         }
      }

      //---------------------------------
      // Write Completion
      //---------------------------------

      // Valid is asserted
      if ( !writeCompBusy && bvalid.read() == 1 ) {
         writeComp.bresp = bresp.read().to_uint();
         writeComp.bid   = bid.read().to_uint();
         smem->setWriteComp(&writeComp);
         writeCompBusy = true;
      }

      //---------------------------------
      // Read Address
      //---------------------------------

      // Wait for ready
      if ( readAddrBusy ) {

         // ready is asserted
         if ( arready.read() == 1 ) {
            readAddrBusy = false;
            arvalid.write(SC_LOGIC_0);
         }
      }

      // Ready for next transaction
      else {

         // Software has posted a transaction
         if ( smem->getReadAddr(&readAddr) ) {
            arvalid.write(SC_LOGIC_1);
            araddr.write(readAddr.araddr);
            arid.write(readAddr.arid);
            arlen.write(readAddr.arlen);
            arsize.write(readAddr.arsize);
            arburst.write(readAddr.arburst);
            arlock.write(readAddr.arlock);
            arprot.write(readAddr.arprot);
            arcache.write(readAddr.arcache);
            readAddrBusy = true;
         }
      }

      //---------------------------------
      // Read Data
      //---------------------------------

      // Valid is asserted
      if ( !readDataBusy && rvalid.read() == 1 ) {
         readData.rdataH = rdataH.read().to_uint();
         readData.rdataL = rdataL.read().to_uint();
         readData.rlast  = (rlast.read() == 1);
         readData.rid    = rid.read().to_uint();
         readData.rresp  = rresp.read().to_uint();
         smem->setReadData(&readData);
         readDataBusy = true;
      }

      //---------------------------------
      // Handshaking
      //---------------------------------
      usleep(1000);

      if ( smem->readyWriteComp() ) {
         bready.write(SC_LOGIC_1);
         writeCompBusy = false;
      }
      else bready.write(SC_LOGIC_0);

      if ( smem->readyReadData()  ) {
         rready.write(SC_LOGIC_1);
         readDataBusy = false;
      }
      else rready.write(SC_LOGIC_0);
   }
}
