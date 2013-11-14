#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <sys/mman.h>
#include <iostream>
#include "DmaSpace.h"
#include "MemorySpace.h"

DmaSpace::DmaSpace (MemorySpace *mspace) {
   _mspace = mspace;
}

DmaSpace::~DmaSpace () { }

// Get single DMA space base address (hardware address)
uint DmaSpace::getDmaBase() {
   return(_mspace->memBaseHw());
}

// Get the two 32-bit values from a particular memory channel
void DmaSpace::getSingleDma ( uint channel, uint *upper, uint *lower ) {
   uint offset;

   offset = (SingleOffset + channel * 2) * 4;

   *lower = _mspace->readMemory32(offset+0);
   *upper = _mspace->readMemory32(offset+4);
}

// Get Header offset for a channel
uint DmaSpace::getIbHeaderOffset(uint channel, uint idx) {
   return(IbHeaderOffset + channel * IbHeaderSize);
}

// Get Header offset for a channel
uint DmaSpace::getObHeaderOffset(uint channel, uint idx) {
   return(ObHeaderOffset + channel * ObHeaderSize);
}

// Get pointer to inbound PPI space
uint DmaSpace::getIbPpiOffset(uint channel, uint idx) {
   return(IbPpiOffset + channel * IbPpiSize+8);
}

// Get pointer to outbound PPI space
uint DmaSpace::getObPpiOffset(uint channel, uint idx) {
   return(ObPpiOffset + channel * ObPpiSize+8);
}

// Copy data
void DmaSpace::ibCopy32 ( uint *ptr, uint offset, uint size ) {
   uint x;
   uint addr = offset;

   for (x=0; x < size; x++) ptr[x] = _mspace->readMemory32(addr+(x*4));
}

void DmaSpace::ibCopy8 ( uchar *ptr, uint offset, uint size ) {
   uint x;
   uint addr = offset;

   for (x=0; x < size; x++) ptr[x] = _mspace->readMemory8(addr+x);
}

// Copy data
void DmaSpace::obCopy32 ( uint *ptr, uint offset, uint size ) {
   uint x;
   uint addr = offset;

   for (x=0; x < size; x++) _mspace->writeMemory32(addr+(x*4),ptr[x]);
}

void DmaSpace::obCopy8 ( uchar *ptr, uint offset, uint size ) {
   uint x;
   uint addr = offset;

   for (x=0; x < size; x++) _mspace->writeMemory8(addr+x,ptr[x]);
}

void DmaSpace::clear8 ( uint offset, uint size ) {
   uint x;
   uint addr = offset;

   for (x=0; x < size; x++) _mspace->writeMemory8(addr+x,0);
}


