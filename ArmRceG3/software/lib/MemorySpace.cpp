#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <string>
#include <unistd.h>
#include <sys/mman.h>
#include <iostream>
#include "MemorySpace.h"
 
MemorySpace::MemorySpace () { }

MemorySpace::~MemorySpace () { }

// Open the port
bool MemorySpace::open () {return(false); }

// Close the port
void MemorySpace::close () { }

// Config base software
uint MemorySpace::cfgBaseHw () { return(0); }

// Memory base software
uint MemorySpace::memBaseHw () { return(0); }

// Write config register
void MemorySpace::writeConfig ( uint base, uint offset, uint value ) { }

// Read config register
uint MemorySpace::readConfig ( uint base, uint offset ) { return(0); }

// Write memory location
void MemorySpace::writeMemory32 ( uint offset, uint  value ) { }
void MemorySpace::writeMemory8  ( uint offset, uchar value ) { }

// Read memory register
uint  MemorySpace::readMemory32 ( uint offset ) { return(0); }
uchar MemorySpace::readMemory8  ( uint offset ) { return(0); }

