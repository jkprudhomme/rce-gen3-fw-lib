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
import pyrogue
import pyrogue as pr
import collections

class RceVersion(pr.Device):
    def __init__(self, **kwargs):
        super(self.__class__, self).__init__(
            description="RCE Version and BSI register.", **kwargs)

        self.add(pyrogue.Variable(name='fpgaVersion', description='Fpga firmware version number',
                                  offset=0x80000000, bitsize=32, bitoffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='scratchPad', description='Scratchpad Register',
                                  offset=0x80000004, bitsize=32, bitoffset=0, base='hex', mode='RW'))

        self.add(pyrogue.Variable(name='rceVersion', description='RCE registers version number',
                                  offset=0x80000008, bitsize=32, bitoffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='deviceDna', description='Xilinx Device DNA Value',
                                  offset=0x80000020, bitsize=64, bitoffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='eFuseValue', description='Xilinx E-Fuse Value',
                                  offset=0x80000030, bitsize=32, bitoffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='ethMode', description='Ethernet Mode',
                                  offset=0x80000034, bitsize=32, bitoffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='heartBeat', description='A constantly incrementing value',
                                  offset=0x80000038, bitsize=32, bitoffset=0, 
                                  pollInterval=1, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='gitHash', description='GIT SHA-1 Hash',
                                 offset=0x80000040, bitSize=160, bitOffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='buildStamp', description='Firmware build string',
                                 offset=0x80001000, bitSize=256*8, bitOffset=0, base='string', mode='RO'))

        self.add(pyrogue.Variable(name='serialNumber', description='Serial Number',
                                 offset=0x84000140, bitSize=64, bitOffset=0, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='atcaSlot', description='ATCA Slot',
                                  offset=0x84000148, bitSize=8, bitOffset=16, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='cobBay', description='COB Bay',
                                  offset=0x84000148, bitSize=8, bitOffset=8, base='hex', mode='RO'))

        self.add(pyrogue.Variable(name='cobElement', description='COB Element',
                                  offset=0x84000148, bitSize=8, bitOffset=0, base='hex', mode='RO'))

