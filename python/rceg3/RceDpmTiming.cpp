//-----------------------------------------------------------------------------
// File          : RceDpmTiming.h
// Author        : Ryan Herbst <rherbst@slac.stanford.edu>
// Created       : 06/19/2014
// Project       : 
//-----------------------------------------------------------------------------
// Description :
//    DPM timing registers for the RCE
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
#include <RceDpmTiming.h>
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
RceDpmTiming::RceDpmTiming ( uint32_t linkConfig, uint32_t baseAddress, uint32_t index, Device *parent ) : 
                        Device(linkConfig,baseAddress,"RceDpmTiming",index,parent) {
  
   Variable     * v;
   RegisterLink * rl;

   // Description
   desc_ = "RCE DPM Timing Registers.";

   addRegister(new Register("ClkReset", baseAddress_ + 0x000));

   addRegisterLink(rl = new RegisterLink("RxDelay0", baseAddress_ + 0x008, Variable::Configuration));
   rl->getVariable()->setDescription("Delay Value For Rx Data 0 input");
   rl->getVariable()->setComp(0,1,0,"");
   rl->getVariable()->setRange(0,31);

   addRegisterLink(rl = new RegisterLink("RxStatus0", baseAddress_ + 0x00C, 1, 2,
                                         "RxErrors0", Variable::Status, 16, 0xFFFF,
                                         "RxIdle0",   Variable::Status,  0, 0xFFFF ));

   rl->getVariable(0)->setDescription("RxErrors Value For Input 0");
   rl->getVariable(0)->setComp(0,1,0,"");
   rl->getVariable(1)->setDescription("RxIdle Value For Input 0");
   rl->getVariable(1)->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegisterLink(rl = new RegisterLink("RxDelay1", baseAddress_ + 0x018, Variable::Configuration));
   rl->getVariable()->setDescription("Delay Value For Rx Data 1 input");
   rl->getVariable()->setComp(0,1,0,"");
   rl->getVariable()->setRange(0,31);

   addRegisterLink(rl = new RegisterLink("RxStatus1", baseAddress_ + 0x01C, 1, 2,
                                         "RxErrors1", Variable::Status, 16, 0xFFFF,
                                         "RxIdle1",   Variable::Status,  0, 0xFFFF ));

   rl->getVariable(0)->setDescription("RxErrors Value For Input 1");
   rl->getVariable(0)->setComp(0,1,0,"");
   rl->getVariable(1)->setDescription("RxIdle Value For Input 1");
   rl->getVariable(1)->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegister(new Register("CountReset", baseAddress_ + 0x020));

   addRegisterLink(rl = new RegisterLink("RxCount0", baseAddress_ + 0x024, Variable::Status));
   rl->getVariable()->setDescription("RxCount Value For Input 0");
   rl->getVariable()->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegisterLink(rl = new RegisterLink("RxCount1", baseAddress_ + 0x028, Variable::Status));
   rl->getVariable()->setDescription("RxCount Value For Input 1");
   rl->getVariable()->setComp(0,1,0,"");
   rl->setPollEnable(true);

   addRegisterLink(rl = new RegisterLink("TxCount", baseAddress_ + 0x02C, Variable::Status));
   rl->getVariable()->setDescription("TxCount Value");
   rl->getVariable()->setComp(0,1,0,"");
   rl->setPollEnable(true);

   v = getVariable("Enabled");
   v->set("True");
   v->setHidden(true);
}

// Deconstructor
RceDpmTiming::~RceDpmTiming ( ) { }

//! Hard Reset
void RceDpmTiming::hardReset () {
   Register *r;

   REGISTER_LOCK
   r = getRegister("ClkReset");
   r->set(0x1);
   writeRegister(r, true);
   REGISTER_UNLOCK
   Device::hardReset();
}

//! Count Reset
void RceDpmTiming::countReset () {
   Register *r;

   REGISTER_LOCK
   r = getRegister("CountReset");
   r->set(0x1);
   writeRegister(r, true);
   REGISTER_UNLOCK
   Device::countReset();
}

