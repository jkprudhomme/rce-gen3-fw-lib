#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <sys/mman.h>
#include <iostream>
#include <iomanip>
#include "MemorySpaceMap.h"
 
MemorySpaceMap::MemorySpaceMap () {
   _devFd            = -1;
   _memMappedBase = NULL;
   _cfgMappedBase = NULL;
}

MemorySpaceMap::~MemorySpaceMap () {
   this->close();
}

void * MemorySpaceMap::getConfigSpace() {
   return(_cfgMappedBase);
}

// Open the port
bool MemorySpaceMap::open () {

   if ( _devFd > 0 ) return(true);

   // Open devmem
   _devFd = ::open("/dev/mem", O_RDWR | O_SYNC);
   if (_devFd == -1) {
      std::cout << "Can't open /dev/mem." << std::endl;
      return(false);
   }

   // Map register space 
   _cfgMappedBase = mmap(0, ConfigMapSize, PROT_READ | PROT_WRITE, MAP_SHARED, _devFd, ConfigBase);
   if (_cfgMappedBase == (void *) -1) {
      std::cout << "Can't map the config memory to user space." << std::endl;
      ::close(_devFd);
      _devFd = -1;
      return(false);
   }

   // Map memory space 
   _memMappedBase = mmap(0, MemoryMapSize, PROT_EXEC | PROT_READ | PROT_WRITE, MAP_SHARED, _devFd, MemoryBase);
   if (_memMappedBase == (void *) -1) {
      std::cout << "Can't map the dma memory to user space." << std::endl;
      ::close(_devFd);
      _devFd = -1;
      return(false);
   }

   std::cout << "Mapped config hw address 0x" << std::hex << ConfigBase
             << " to sw address 0x" << std::hex << _cfgMappedBase << std:: endl;

   std::cout << "Mapped memory hw address 0x" << std::hex << MemoryBase
             << " to sw address 0x" << std::hex << _memMappedBase << std:: endl;

   // Sucess
   return(true);
}

// Close the port
void MemorySpaceMap::close () {
   if ( _devFd > 0 ) {
      ::close(_devFd);
      _devFd = -1;
   }
}

// Config base software
uint MemorySpaceMap::cfgBaseHw () {
   return(ConfigBase);
}

// Memory base software
uint MemorySpaceMap::memBaseHw () {
   return(MemoryBase);
}

// Write config register
void MemorySpaceMap::writeConfig ( uint base, uint offset, uint value ) {
   if ( _devFd > 0 && offset < ConfigMapSize ) {
      volatile uint *ptr = (uint *)_cfgMappedBase;
      ptr[base/4+offset] = value;
   }
}

// Read config register
uint MemorySpaceMap::readConfig ( uint base, uint offset ) {
   if ( _devFd > 0 && offset < ConfigMapSize ) {
      volatile uint *ptr = (uint *)_cfgMappedBase;

      uint idx = base/4 + offset;
      uint value = ptr[idx];

      //uint *p  = &(ptr[idx]);
      //std::cout << "Read Base: " << std::hex << base
                //<< " Offset: " << std::hex << offset
                //<< " Idx: " << std::hex << idx
                //<< " Ptr: " << std::hex << p 
                //<< " Value: " << std::hex << value   << std::endl;

      return(value);
   }
   else return(0);
}

// Write memory location
void MemorySpaceMap::writeMemory32 ( uint offset, uint value ) {
   if ( _devFd > 0 && offset < MemoryMapSize ) {

      volatile uint *ptr = (uint *)_memMappedBase;

      //std::cout << "Writing32 to address 0x" 
                //<< std::hex << (ptr+(offset/4)) 
                //<< " Data 0x" 
                //<< std::hex << value 
                //<< std::endl;

      ptr[offset/4] = value;
   }
   else {
      std::cout << "Write32 memory offset out of range = " << std::dec << offset << std::endl;
      exit(1);
   }
}

// Write memory location
void MemorySpaceMap::writeMemory8 ( uint offset, uchar value ) {
   if ( _devFd > 0 && offset < MemoryMapSize ) {
      volatile uint *ptr = (uint *)_memMappedBase;

      switch (offset & 0x3) {
         case 0:
            ptr[offset/4] &= 0xFFFFFF00;
            ptr[offset/4] |= (value & 0xFF);
            break;
         case 1:
            ptr[offset/4] &= 0xFFFF00FF;
            ptr[offset/4] |= ((value << 8) & 0xFF00);
            break;
         case 2:
            ptr[offset/4] &= 0xFF00FFFF;
            ptr[offset/4] |= ((value << 16) & 0xFF0000);
            break;
         case 3:
            ptr[offset/4] &= 0x00FFFFFF;
            ptr[offset/4] |= ((value << 24) & 0xFF000000);
            break;
         default: break;
      }

#if 0
      std::cout << "Writing8 to address 0x" 
                << std::hex << ((uint)ptr+offset)
                << " Raw  0x" << std::setw(8) << std::setfill('0') << std::hex << ptr[offset/4]
                << " Data 0x" << std::setw(2) << std::setfill('0') << std::hex << (int)value 
                << std::endl;
#endif

   }
   else {
      std::cout << "Write8 memory offset out of range = " << std::dec << offset << std::endl;
      exit(1);
   }
}

// Read memory register
uint MemorySpaceMap::readMemory32 ( uint offset ) {

   if ( _devFd > 0 && offset < MemoryMapSize ) {
      volatile uint *ptr = (uint *)_memMappedBase;

      uint idx = offset/4;
      uint value = ptr[idx];

      //std::cout << "readMemory32 Offset 0x" << std::hex << std::setw(8) << std::setfill('0') << idx
                //<< " Value 0x" << std::hex << std::setw(8) << std::setfill('0') << value << std::endl;

      return(value);
   }
   else {
      std::cout << "Read32 memory offset out of range = " << std::dec << offset << std::endl;
      exit(1);
      return(0);
   }
}

uchar MemorySpaceMap::readMemory8 ( uint offset ) {
   uchar ret;

   if ( _devFd > 0 && offset < MemoryMapSize ) {
      volatile uint *ptr = (uint *)_memMappedBase;

      switch(offset & 0x3) {
         case 0: ret = (ptr[offset/4]      ) & 0xFF; break;
         case 1: ret = (ptr[offset/4] >>  8) & 0xFF; break;
         case 2: ret = (ptr[offset/4] >> 16) & 0xFF; break;
         case 3: ret = (ptr[offset/4] >> 24) & 0xFF; break;
         default: ret =  0; break;
      }

#if 0
      std::cout << "Reading8 from address 0x" 
                << std::hex << ((uint)ptr+offset)
                << " Raw 0x"  << std::setw(8) << std::setfill('0') << std::hex << ptr[offset/4]
                << " Data 0x" << std::setw(2) << std::setfill('0') << std::hex << (uint)ret
                << std::endl;
#endif

      return(ret);

   }
   else {
      std::cout << "Read8 memory offset out of range = " << std::dec << offset << std::endl;
      exit(1);
      return(0);
   }
}

void MemorySpaceMap::dumpMemory ( uint base, uint size ) {
   uint x;
   uint *addr;

   addr = (uint *)_memMappedBase;
   addr += base;

   std::cout << "Dumping memory space" << std::endl;
   for (x=0; x < size; x++) {
      std::cout << "Idx=" << std::dec << std::setw(4) << std::setfill(' ') << x
                << " Addr=0x" << std::hex << std::setw(8) << std::setfill('0') << addr 
                << " Data=0x" << std::hex << std::setw(8) << std::setfill('0') << *addr
                << std::endl;
      addr++;
   }
}

void MemorySpaceMap::dumpConfig ( uint base, uint size ) {
   uint x;
   uint *addr;

   addr = (uint *)_cfgMappedBase;
   addr += base;

   std::cout << "Dumping config space" << std::endl;
   for (x=0; x < size; x++) {
      std::cout << "Idx=" << std::dec << std::setw(4) << std::setfill(' ') << x
                << " Addr=0x" << std::hex << std::setw(8) << std::setfill('0') << addr 
                << " Data=0x" << std::hex << std::setw(8) << std::setfill('0') << *addr
                << std::endl;
      addr++;
   }
}

