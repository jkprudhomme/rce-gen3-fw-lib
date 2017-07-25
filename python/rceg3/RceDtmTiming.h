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
#ifndef __RCE_DTM_TIMING_H__
#define __RCE_DTM_TIMING_H__

#include <Device.h>
#include <stdint.h>
using namespace std;

//! Class to contain RceDtmTiming
class RceDtmTiming : public Device {

   public:

      //! Constructor
      /*! 
       * \param linkConfig Device linkConfig
       * \param index       Device index
       * \param baseAddress Device base address
       * \param parent      Parent device
      */
      RceDtmTiming ( uint32_t linkConfig, uint32_t baseAddress, uint32_t index, Device *parent );

      //! Deconstructor
      ~RceDtmTiming ( );

      //! Command processing
      void command(string name, string arg);

      //! Count Reset
      void countReset ();
};

#endif
