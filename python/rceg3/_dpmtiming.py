#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : RCE Gen3 Version Register space
#-----------------------------------------------------------------------------
# File       : _RceVersion.py
# Created    : 2017-02-25
#-----------------------------------------------------------------------------
# This file is part of the RCE GEN3 firmware platform. It is subject to 
# the license terms in the LICENSE.txt file found in the top-level directory 
# of this distribution and at: 
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
# No part of the rogue RCE GEN3 firmware platform, including this file, may be 
# copied, modified, propagated, or distributed except according to the terms 
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------
import pyrogue as pr
import collections

class RceVersion(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(
            description="RCE Version and BSI register.", **kwargs)

    self.add(pyrogue.variable(name='fpgaVersion', description='Fpga firmware version number',
                              offset=0x80000000, bitsize=32, bitoffset=0, base='hex', mode='RO'))

    self.add(pyrogue.variable(name='scratchPad', description='Scratchpad Register',
                              offset=0x80000004, bitsize=32, bitoffset=0, base='hex', mode='RW'))

    self.add(pyrogue.variable(name='rceVersion', description='RCE registers version number',
                              offset=0x80000008, bitsize=32, bitoffset=0, base='hex', mode='RO'))

    self.add(pyrogue.variable(name='deviceDna', description='Xilinx Device DNA Value',
                              offset=0x80000020, bitsize=64, bitoffset=0, base='hex', mode='RO'))

    self.add(pyrogue.variable(name='eFuseValue', description='Xilinx E-Fuse Value',
                              offset=0x80000030, bitsize=32, bitoffset=0, base='hex', mode='RO'))

    self.add(pyrogue.variable(name='ethMode', description='Ethernet Mode',
                              offset=0x80000034, bitsize=32, bitoffset=0, base='hex', mode='RO'))

    self.add(pyrogue.variable(name='heartBeat', description='A constantly incrementing value',
                              offset=0x80000038, bitsize=32, bitoffset=0, base='hex', mode='RO'))

    dev.add(pyrogue.Variable(name='gitHash', description='GIT SHA-1 Hash',
                             offset=0x80000040, bitSize=160, bitOffset=0, base='hex', mode='RO'))

    dev.add(pyrogue.Variable(name='buildStamp', description='Firmware build string',
                             offset=0x80001000, bitSize=256*8, bitOffset=0, base='string', mode='RO'))

    dev.add(pyrogue.Variable(name='serialNumber', description='Serial Number',
                             offset=0x84000140, bitSize=64, bitOffset=0, base='hex', mode='RO'))

    dev.add(pyrogue.Variable(name='atcaSlot', description='ATCA Slot',
                             offset=0x84000148, bitSize=8, bitOffset=16, base='hex', mode='RO'))

    dev.add(pyrogue.Variable(name='cobBay', description='COB Bay',
                             offset=0x84000148, bitSize=8, bitOffset=8, base='hex', mode='RO'))

    dev.add(pyrogue.Variable(name='cobElement', description='COB Element',
                             offset=0x84000148, bitSize=8, bitOffset=0, base='hex', mode='RO'))



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


