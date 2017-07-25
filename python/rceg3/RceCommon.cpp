//-----------------------------------------------------------------------------
// File          : RceCommon.h
// Author        : Ryan Herbst <rherbst@slac.stanford.edu>
// Created       : 06/19/2014
// Project       : 
//-----------------------------------------------------------------------------
// Description :
//    Common registers for the RCE
//-----------------------------------------------------------------------------
// This file is part of 'SLAC Generic DAQ Software'.
// It is subject to the license terms in the LICENSE.txt file found in the 
// top-level directory of this distribution and at: 
//    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
// No part of 'SLAC Generic DAQ Software', including this file, 
// may be copied, modified, propagated, or distributed except according to 
// the terms contained in the LICENSE.txt file.
// Proprietary and confidential to SLAC.
//-----------------------------------------------------------------------------
// Modification history :
// 06/19/2014: created
//-----------------------------------------------------------------------------
#include <RceCommon.h>
#include <Register.h>
#include <RegisterLink.h>
#include <Variable.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
#include <MappedMemory.h>
using namespace std;

// Constructor
RceCommon::RceCommon ( uint32_t linkConfig, uint32_t index, Device *parent ) : 
                        Device(linkConfig,0x0,"RceCommon",index,parent) {
  
   RegisterLink *rl;
   Variable     *v;

   // Description
   desc_ = "RCE Common Registers.";
   pollEnable(true);

   addRegisterLink(rl = new RegisterLink("FpgaVersion", 0x80000000, Variable::Status));
   rl->getVariable()->setDescription("FPGA Version");

   addRegisterLink(rl = new RegisterLink("RceVersion", 0x80000008, Variable::Status));
   rl->getVariable()->setDescription("RCE Version");

   addRegisterLink(rl = new RegisterLink("DeviceDna", 0x80000020, 2, Variable::Status));
   rl->getVariable()->setDescription("Xilinx Device DNA Value");

   addRegisterLink(rl = new RegisterLink("EFuseValue", 0x80000030, Variable::Status));
   rl->getVariable()->setDescription("E-Fuse Value");

   addRegisterLink(rl = new RegisterLink("EthMode", 0x80000034, Variable::Status));
   rl->getVariable()->setDescription("Eth Mode Value");

   addRegisterLink(rl = new RegisterLink("Heartbeat", 0x80000038, Variable::Status));
   rl->getVariable()->setDescription("A constantly incrementing counter.");
   rl->setPollEnable(true);

   addRegisterLink(rl = new RegisterLink("BuildString", 0x80001000, 64, Variable::Status));
   rl->getVariable()->setDescription("FPGA Build String");
   rl->getVariable()->setString();

   addRegisterLink(rl = new RegisterLink("SerialNumber",0x84000140, 2, Variable::Status));
   rl->getVariable()->setDescription("Serial Number");

   addRegisterLink(rl = new RegisterLink("Cluster", 0x84000148, 1, 3,
                                         "AtcaSlot",   Variable::Status, 16, 0xFF,
                                         "CobBay",     Variable::Status, 8, 0xFF,
                                         "CobElement", Variable::Status, 0, 0xFF));
            
   rl->getVariable(0)->setDescription("ATCA Slot Number");
   rl->getVariable(1)->setDescription("COB Bay Numer");
   rl->getVariable(2)->setDescription("COB Element Numer");


   // Set and hide enabled
   v = getVariable("Enabled");
   v->set("True");
   v->setHidden(true);
}

// Deconstructor
RceCommon::~RceCommon ( ) { }

//! Static method to return bay/element for memory mapped RCE
void RceCommon::getRcePosition ( uint32_t *slot, uint32_t *bay, uint32_t *element ) {
   MappedMemory *mem = new MappedMemory (1, 0x84000000, 0x00001000);
   mem->open();

   uint32_t cluster = mem->read(0x84000148);

   *slot = (cluster >> 16) & 0xFF;
   *bay = (cluster >> 8) & 0xFF;
   *element = cluster & 0xFF;

   // Slot = 0 is invalid, no BSI, return DTM
   if ( *slot == 0 ) {
      *slot    = 1;
      *bay     = 4;
      *element = 0;
   }

   mem->close();
   delete mem;
}

