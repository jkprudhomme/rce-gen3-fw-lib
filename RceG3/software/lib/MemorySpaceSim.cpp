#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <iostream>
#include <iomanip>
#include <queue>
#include "MemorySpaceSim.h"
using namespace std;
 
MemorySpaceSim::MemorySpaceSim () {
   _readReq   = 0;
   _readAck   = 0;
   _readAddr  = 0;
   _readData  = 0;
   _writeReq  = 0;
   _writeAck  = 0;
   _writeAddr = 0;
   _writeData = 0;
   _runEnable = false;

   _memorySpace = (uint *)malloc(MemorySize*4);

   if ( _memorySpace == NULL ) cout << "Bad allocation!" << endl;
}

MemorySpaceSim::~MemorySpaceSim () {
   this->close();
}

// Open the port
bool MemorySpaceSim::open () {
   uint x;

   // Setup config space
   _configShared = sim_open ( (char *)"SimAxiMaster", 1, -1 );

   // Setup shared spaces
   for (x=0; x < 5; x++) {
      _memThread[x].ptr = this;    
      _memThread[x].idx = x;
   }
   _memThread[0].mem = sim_open ( (char *)"SimAxiSlave",  2, -1 );
   _memThread[1].mem = sim_open ( (char *)"SimAxiSlave",  3, -1 );
   _memThread[2].mem = sim_open ( (char *)"SimAxiSlave",  4, -1 );
   _memThread[3].mem = sim_open ( (char *)"SimAxiSlave",  5, -1 );
   _memThread[4].mem = sim_open ( (char *)"SimAxiSlave",  6, -1 );

   _runEnable = true;

   // Start threads
   pthread_create(&_configThread,NULL,staticConfigRun,this);

   for (x=0; x < 5; x++) {
      pthread_create(&(_memThread[x].writeThread),NULL,staticMemoryWriteRun,&(_memThread[x]));
      pthread_create(&(_memThread[x].writeThread),NULL,staticMemoryReadRun,&(_memThread[x]));
   }

   // Sucess
   return(true);
}

// Close the port
void MemorySpaceSim::close () {
   uint x;

   _runEnable = false;
   usleep(1000);

   pthread_join(_configThread, NULL);

   for (x=0; x < 5; x++) {
      pthread_join(_memThread[x].writeThread,NULL);
      pthread_join(_memThread[x].writeThread,NULL);
   }

   sim_close(_configShared);

   for (x=0; x < 5; x++) sim_close(_memThread[x].mem);
}

// Config base software
uint MemorySpaceSim::cfgBaseHw () {
   return(ConfigBase);
}

// Memory base software
uint MemorySpaceSim::memBaseHw () {
   return(0);
}

// Write config register
void MemorySpaceSim::writeConfig ( uint base, uint offset, uint value ) {
   _writeAddr = ConfigBase + base + offset*4;
   _writeData = value;
   _writeReq++;

   while ( _writeReq != _writeAck ) usleep(100);
}

// Read config register
uint MemorySpaceSim::readConfig ( uint base, uint offset ) {
   _readAddr = ConfigBase + base + offset*4;
   _readReq++;

   while ( _readReq != _readAck ) usleep(100);
   return(_readData);
}

// Write memory location
void MemorySpaceSim::writeMemory32 ( uint offset, uint value ) {
   _memorySpace[offset/4] = value;
}

void MemorySpaceSim::writeMemory8 ( uint offset, uchar value ) {
   switch (offset & 0x3) {
      case 0:
         _memorySpace[offset/4] &= 0xFFFFFF00;
         _memorySpace[offset/4] |= (value & 0xFF);
         break;
      case 1:
         _memorySpace[offset/4] &= 0xFFFF00FF;
         _memorySpace[offset/4] |= ((value << 8) & 0xFF00);
         break;
      case 2:
         _memorySpace[offset/4] &= 0xFF00FFFF;
         _memorySpace[offset/4] |= ((value << 16) & 0xFF0000);
         break;
      case 3:
         _memorySpace[offset/4] &= 0x00FFFFFF;
         _memorySpace[offset/4] |= ((value << 24) & 0xFF000000);
         break;
      default: break;
   }
}


// Read memory register
uint MemorySpaceSim::readMemory32 ( uint offset ) {
   return(_memorySpace[offset/4]);
}

uchar MemorySpaceSim::readMemory8 ( uint offset ) {
   switch(offset & 0x3) {
      case 0: return((_memorySpace[offset/4]      ) & 0xFF); break;
      case 1: return((_memorySpace[offset/4] >>  8) & 0xFF); break;
      case 2: return((_memorySpace[offset/4] >> 16) & 0xFF); break;
      case 3: return((_memorySpace[offset/4] >> 24) & 0xFF); break;
      default: return(0); break;
   }
}

void * MemorySpaceSim::staticConfigRun(void *t) {
   MemorySpaceSim *ti;
   ti = (MemorySpaceSim *)t;
   ti->configRun();
   pthread_exit(NULL);
}

void MemorySpaceSim::configRun() {
   AxiWriteAddr writeAddr;
   AxiWriteData writeData;
   AxiWriteComp writeComp;
   AxiReadAddr  readAddr;
   AxiReadData  readData;

   while (_runEnable) {

      // New write request
      if ( _writeReq != _writeAck ) {

         // Generate write address
         writeAddr.awaddr  = _writeAddr;
         writeAddr.awid    = 0;
         writeAddr.awlen   = 0;
         writeAddr.awsize  = 2;
         writeAddr.awburst = 0;
         writeAddr.awlock  = 0;
         writeAddr.awcache = 0;
         writeAddr.awprot  = 0;

         // Post addr
         setWriteAddr (_configShared, &writeAddr );

         // Wait for ack
         while ( !readyWriteAddr(_configShared) ) usleep(1);

         // Post write data
         writeData.wdataH = 0;
         writeData.wdataL = _writeData;
         writeData.wlast  = 1;
         writeData.wid    = 0;
         writeData.wstrb  = 0xF;

         // Post data
         setWriteData (_configShared, &writeData );

         // Wait for ack
         while ( !readyWriteData(_configShared) ) usleep(1);

         // Wait for completion
         while ( !getWriteComp (_configShared, &writeComp ) ) usleep(1);

         _writeAck = _writeReq;

         //cout << "Write to config space,"
              //<< " Addr=0x" << hex << setw(8) << setfill('0') << _writeAddr
              //<< " Data=0x" << hex << setw(8) << setfill('0') << _writeData
              //<< endl;
      }

      // New read request
      else if ( _readReq != _readAck ) {

         // Generate read address
         readAddr.araddr  = _readAddr;
         readAddr.arid    = 0;
         readAddr.arlen   = 0;
         readAddr.arsize  = 2;
         readAddr.arburst = 0;
         readAddr.arlock  = 0;
         readAddr.arprot  = 0;
         readAddr.arcache = 0;

         // Post addr
         setReadAddr (_configShared, &readAddr );

         // Wait for ack
         while ( !readyReadAddr(_configShared) ) usleep(1);

         // Wait for read to finish
         while ( !getReadData (_configShared, &readData ) ) usleep(1);

         if ( ! readData.rlast ) cout << "!!!!!!!!!!! Error: Invalid last value on read !!!!!!!!!!" << endl;

         _readData = readData.rdataL;
         _readAck = _readReq;

         //cout << "Read frm config space,"
              //<< " Addr=0x" << hex << setw(8) << setfill('0') << _readAddr
              //<< " Data=0x" << hex << setw(8) << setfill('0') << _readData
              //<< endl;
      }
      else usleep(10);
   }
}

void * MemorySpaceSim::staticMemoryReadRun(void *t) {
   ThreadData     *p1;
   MemorySpaceSim *p2;
   
   p1 = (ThreadData *)t; 
   p2 = (MemorySpaceSim *)p1->ptr;

   p2->memoryReadRun(p1);
   pthread_exit(NULL);
}

// Memory read 
void MemorySpaceSim::memoryReadRun(ThreadData *ptr) {
   AxiReadData            readData;
   AxiReadAddr          * nextAddr;
   AxiReadAddr          * currAddr;
   queue<AxiReadAddr *>   readQueue;
   uint                   length;
   uint                   addr;
   uint                   x;
   uint                   id;

   AxiSharedMem *slaveShared = ptr->mem;

   nextAddr = new AxiReadAddr; 

   while (_runEnable) {

      // Wait for read address
      if ( getReadAddr(slaveShared,nextAddr) ) {

         cout << "Read Start,  " 
              << " Thread=" << ptr->idx 
              << " Id=" << id
              << " Addr=0x" << hex << setw(8) << setfill('0') << nextAddr->araddr
              << endl;

         readQueue.push(nextAddr);
         nextAddr = new AxiReadAddr;
      }

      // Queue has an entry
      if ( ! readQueue.empty() ) {

         // Get entry
         currAddr = readQueue.front();

         // Extract address and length
         length = (currAddr->arlen + 1) * 2;
         addr   = currAddr->araddr/4;
         id     = currAddr->arid;

         if ( addr + length >= MemorySize ) {
            cout << "!!!!!!!!!!! Error Bad Read Memory Address, "
                 << " Thread=" << ptr->idx 
                 << " Id=" << id
                 << " Addr=0x" << hex << setw(8) << setfill('0') << (addr*4)
                 << endl;
            return;
         }

         // Send out data
         for (x=0; x < length;) {

            // Verify hardware is ready
            while ( !readyReadData(slaveShared) ) usleep(1);

            // Format and output data
            readData.rdataL = _memorySpace[addr];

            cout << "Memory read, " 
                 << " Thread=" << ptr->idx 
                 << " Id=" << id
                 << " Addr=0x" << hex << setw(8) << setfill('0') << (addr*4)
                 << " Data=0x" << hex << setw(8) << setfill('0') << readData.rdataL
                 << endl;

            addr++;
            x++;

            readData.rdataH = _memorySpace[addr];

            cout << "Memory read, " 
                 << " Thread=" << ptr->idx 
                 << " Id=" << id
                 << " Addr=0x" << hex << setw(8) << setfill('0') << (addr*4)
                 << " Data=0x" << hex << setw(8) << setfill('0') << readData.rdataH
                 << endl;

            addr++;
            x++;

            readData.rlast  = (x == length);
            readData.rid    = currAddr->arid;
            readData.rresp  = 0;


            setReadData(slaveShared,&readData);
         }

         readQueue.pop();
         delete currAddr;
      }
      else usleep(10);
   }
}

void * MemorySpaceSim::staticMemoryWriteRun(void *t) {
   ThreadData     *p1;
   MemorySpaceSim *p2;
   
   p1 = (ThreadData *)t; 
   p2 = (MemorySpaceSim *)p1->ptr;

   p2->memoryWriteRun(p1);
   pthread_exit(NULL);
}

// Memory write
void MemorySpaceSim::memoryWriteRun(ThreadData *ptr) {
   AxiWriteAddr          * nextAddr;
   AxiWriteAddr          * currAddr;
   queue<AxiWriteAddr *>   writeQueue[8];
   AxiWriteData            writeData;
   AxiWriteComp            writeComp;
   uint                    aid;
   uint                    id;
   uint                    length;
   uint                    addr[8];
   bool                    valid[8];
   uint                    x;
   uint                    temp;
   uint                    tempMask;
   uint                    writeMask;

   AxiSharedMem *slaveShared = ptr->mem;

   nextAddr = new AxiWriteAddr; 
   currAddr = NULL;
   for (x=0; x < 8; x++) valid[x] = false;

   while (_runEnable) {

      // Wait for read address
      while ( getWriteAddr(slaveShared,nextAddr) ) {
         aid = nextAddr->awid;

         cout << "Write Start, " 
              << " Thread=" << ptr->idx 
              << " Id=" << aid
              << " Addr=0x" << hex << setw(8) << setfill('0') << nextAddr->awaddr
              << endl;

         writeQueue[aid].push(nextAddr);
         nextAddr = new AxiWriteAddr; 
      }

      // Wait for write data
      if ( getWriteData(slaveShared,&writeData) ) {
         id = writeData.wid;

         // ID is not valid, search for record
         if ( !valid[id] ) {
            if ( writeQueue[id].empty() ) {
               cout << "!!!!!!!!!!! Error Bad Write ID, "
                    << " Thread=" << ptr->idx 
                    << " Id=" << id
                    << endl;
               return;
            }
            else {

               // Get entry
               currAddr = writeQueue[id].front();

               // Extract values
               id        = currAddr->awid;
               length    = (currAddr->awlen + 1) * 2;
               addr[id]  = currAddr->awaddr/4;
               valid[id] = true;

               if ( addr[id] + length >= MemorySize ) {
                  cout << "!!!!!!!!!!! Error Bad Write Memory Address, "
                       << " Thread=" << ptr->idx 
                       << " Id=" << id
                       << " Addr=0x" << hex << setw(8) << setfill('0') << (addr[id]*4)
                       << endl;
                  return;
               }

               writeQueue[id].pop();
               delete currAddr;
            }
         }

         tempMask  = 0xFFFFFFFF;
         writeMask = 0x0;
         if ( writeData.wstrb & 0x1 ) { tempMask &= 0xFFFFFF00; writeMask |= 0x000000FF; }
         if ( writeData.wstrb & 0x2 ) { tempMask &= 0xFFFF00FF; writeMask |= 0x0000FF00; }
         if ( writeData.wstrb & 0x4 ) { tempMask &= 0xFF00FFFF; writeMask |= 0x00FF0000; }
         if ( writeData.wstrb & 0x8 ) { tempMask &= 0x00FFFFFF; writeMask |= 0xFF000000; }

         temp = _memorySpace[addr[id]] & tempMask;
         _memorySpace[addr[id]] = temp | (writeData.wdataL & writeMask); 

         cout << "Memory write," 
              << " Thread=" << ptr->idx 
              << " Id=" << id
              << " Addr=0x" << hex << setw(8) << setfill('0') << (addr[id]*4)
              << " Data=0x" << hex << setw(8) << setfill('0') << writeData.wdataL
              << " Mask=0x" << hex << setw(1) << setfill('0') << (writeData.wstrb & 0xF)
              << endl;

         addr[id]++;

         tempMask  = 0xFFFFFFFF;
         writeMask = 0x0;
         if ( writeData.wstrb & 0x10 ) { tempMask &= 0xFFFFFF00; writeMask |= 0x000000FF; }
         if ( writeData.wstrb & 0x20 ) { tempMask &= 0xFFFF00FF; writeMask |= 0x0000FF00; }
         if ( writeData.wstrb & 0x40 ) { tempMask &= 0xFF00FFFF; writeMask |= 0x00FF0000; }
         if ( writeData.wstrb & 0x80 ) { tempMask &= 0x00FFFFFF; writeMask |= 0xFF000000; }

         temp = _memorySpace[addr[id]] & tempMask;
         _memorySpace[addr[id]] = temp | (writeData.wdataH & writeMask); 

         cout << "Memory write," 
              << " Thread=" << ptr->idx 
              << " Id=" << id
              << " Addr=0x" << hex << setw(8) << setfill('0') << (addr[id]*4)
              << " Data=0x" << hex << setw(8) << setfill('0') << writeData.wdataH
              << " Mask=0x" << hex << setw(1) << setfill('0') << ((writeData.wstrb >> 4) & 0xF)
              << endl;

         addr[id]++;

         // Last
         if ( writeData.wlast ) {

            // Verify hardware is ready
            while ( !readyWriteComp(slaveShared) ) usleep(1);

            // Continue
            writeComp.bresp = 0;
            writeComp.bid = id;
            setWriteComp(slaveShared,&writeComp);
            valid[id] = false;
         } 
      } else usleep(1);
   }
}

