//-----------------------------------------------------------------------------
// File          : RceDtmTiming.h
// Author        : Ryan Herbst <rherbst@slac.stanford.edu>
// Created       : 06/19/2014
// Project       : 
//-----------------------------------------------------------------------------
// Description :
//    DTM timing registers for the RCE
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
#include <RceDtmTiming.h>
#include <Register.h>
#include <Variable.h>
#include <RegisterLink.h>
#include <Command.h>
#include <sstream>
#include <iostream>
#include <string>
#include <iomanip>
using namespace std;

// Constructor
RceDtmTiming::RceDtmTiming ( uint32_t linkConfig, uint32_t baseAddress, uint32_t index, Device *parent ) : 
                        Device(linkConfig,baseAddress,"RceDtmTiming",index,parent) {
  
   char           buffer1[50];
   char           buffer2[50];
   char           buffer3[50];
   uint32_t       x;
   Variable     * v;
   RegisterLink * rl;
   Command      * c;

   // Description
   desc_ = "RCE DTM Timing Registers.";

   for (x=0; x < 8; x++) {
      sprintf(buffer1,"FbDelay%i",x);
   
      addRegisterLink(rl = new RegisterLink(buffer1, baseAddress_ + 0x100 + (x*4), Variable::Configuration));
      rl->getVariable()->setDescription("FbDelay Value For Dpm");
      rl->getVariable()->setComp(0,1,0,"");
      rl->getVariable()->setRange(0,31);

      sprintf(buffer1,"FbStatus%i",x);
      sprintf(buffer2,"FbErrors%i",x);
      sprintf(buffer3,"FbIdle%i",x);

      addRegisterLink(rl = new RegisterLink(buffer1, baseAddress_ + 0x200 + (x*4), 1, 2,
                                            buffer2, Variable::Status, 16, 0xFFFF,
                                            buffer3, Variable::Status,  0, 0xFFFF ));

      rl->getVariable(0)->setDescription("FbErrors Value For Dpm");
      rl->getVariable(0)->setComp(0,1,0,"");
      rl->getVariable(1)->setDescription("FbIdle Value For Dpm");
      rl->getVariable(1)->setComp(0,1,0,"");
      rl->setPollEnable(true);

      sprintf(buffer1,"RxCount%i",x);
      addRegisterLink(rl = new RegisterLink(buffer1, baseAddress_ + 0x500 + (x*4), Variable::Status));
      rl->getVariable()->setDescription("Rx Data Count For Dpm");
      rl->getVariable()->setComp(0,1,0,"");
      rl->setPollEnable(true);
   }

   addRegister(new Register("TxData0", baseAddress_ + 0x400));
   addRegister(new Register("TxData1", baseAddress_ + 0x410));

   addRegisterLink(rl = new RegisterLink("TxCount0", baseAddress_ + 0x414, Variable::Status));
   rl->getVariable()->setDescription("TX Data 0 Counter");
   rl->getVariable()->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegisterLink(rl = new RegisterLink("TxCount1", baseAddress_ + 0x418, Variable::Status));
   rl->getVariable()->setDescription("TX Data 1 Counter");
   rl->getVariable()->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegister(new Register("CountReset", baseAddress_ + 0x41C));

   addCommand(c = new Command("TxData0"));
   c->setDescription("Transmit Data On Channel 0");
   c->setHasArg(true);

   addCommand(c = new Command("TxData1"));
   c->setDescription("Transmit Data On Channel 1");
   c->setHasArg(true);

   v = getVariable("Enabled");
   v->set("True");
   v->setHidden(true);
}

// Deconstructor
RceDtmTiming::~RceDtmTiming ( ) { }

// Process Commands
void RceDtmTiming::command(string name, string arg) {
   Register *r;
   uint32_t ret;

   // Command is local
   if ( name == "TxData0" ) {
      REGISTER_LOCK
      r = getRegister("TxData0");
      ret = (uint32_t)strtoul(arg.c_str(),NULL,0);
      r->set(ret);
      writeRegister(r, true);
      REGISTER_UNLOCK
   }
   else if ( name == "TxData1" ) {
      REGISTER_LOCK
      r = getRegister("TxData1");
      ret = (uint32_t)strtoul(arg.c_str(),NULL,0);
      r->set(ret);
      writeRegister(r, true);
      REGISTER_UNLOCK
   }
   else Device::command(name, arg);
}

//! Count Reset
void RceDtmTiming::countReset () {
   Register *r;

   REGISTER_LOCK
   r = getRegister("CountReset");
   r->set(0x1);
   writeRegister(r, true);
   REGISTER_UNLOCK
   Device::countReset();
}

