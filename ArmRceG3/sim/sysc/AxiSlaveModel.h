#ifndef __AXI_SLAVE_MODEL_H__
#define __AXI_SLAVE_MODEL_H__
#include <systemc.h>
#include <sys/types.h>
#include "../../software/lib//AxiSharedMem.h"
using namespace std;

// Module declaration
SC_MODULE(AxiSlaveModel) {

   // Channel id
   sc_in    <sc_lv<8>  > masterId;

   // Clock and reset
   sc_in    <sc_logic  > axiClk;
   sc_out   <sc_logic  > axiClkRst;

   // Read address channel
   sc_in    <sc_logic  > arvalid;
   sc_out   <sc_logic  > arready;
   sc_in    <sc_lv<32> > araddr;
   sc_in    <sc_lv<12> > arid;
   sc_in    <sc_lv<4>  > arlen;
   sc_in    <sc_lv<3>  > arsize;
   sc_in    <sc_lv<2>  > arburst;
   sc_in    <sc_lv<2>  > arlock;
   sc_in    <sc_lv<3>  > arprot;
   sc_in    <sc_lv<4>  > arcache;
   sc_in    <sc_lv<4>  > arqos;
   sc_in    <sc_lv<5>  > aruser;

   // Read data channel
   sc_in    <sc_logic  > rready;
   sc_out   <sc_lv<32> > rdataH;
   sc_out   <sc_lv<32> > rdataL;
   sc_out   <sc_logic  > rlast;
   sc_out   <sc_logic  > rvalid;
   sc_out   <sc_lv<12> > rid;
   sc_out   <sc_lv<2>  > rresp;

   // Read Control 
   sc_in    <sc_logic  > rdissuecap1_en;

   // Read Status
   sc_out   <sc_lv<3>  > racount;
   sc_out   <sc_lv<8>  > rcount;

   // Write address channel
   sc_in    <sc_logic  > awvalid;
   sc_out   <sc_logic  > awready;
   sc_in    <sc_lv<32> > awaddr;
   sc_in    <sc_lv<12> > awid;
   sc_in    <sc_lv<4>  > awlen;
   sc_in    <sc_lv<3>  > awsize;
   sc_in    <sc_lv<2>  > awburst;
   sc_in    <sc_lv<2>  > awlock;
   sc_in    <sc_lv<4>  > awcache;
   sc_in    <sc_lv<3>  > awprot;
   sc_in    <sc_lv<4>  > awqos;
   sc_in    <sc_lv<5>  > awuser;

   // Write data channel
   sc_out   <sc_logic  > wready;
   sc_in    <sc_lv<32> > wdataH;
   sc_in    <sc_lv<32> > wdataL;
   sc_in    <sc_logic  > wlast;
   sc_in    <sc_logic  > wvalid;
   sc_in    <sc_lv<12> > wid;
   sc_in    <sc_lv<8>  > wstrb;

   // Write ack channel
   sc_in    <sc_logic  > bready;
   sc_out   <sc_lv<2>  > bresp;
   sc_out   <sc_logic  > bvalid;
   sc_out   <sc_lv<12> > bid;

   // Control
   sc_in    <sc_logic  > wrissuecap1_en;

   // Status
   sc_out   <sc_lv<6>  > wacount;
   sc_out   <sc_lv<8>  > wcount;

   // Slave thread
   void slaveThread(void);

   // Constructor
   SC_CTOR(AxiSlaveModel):
      masterId("masterId"),
      axiClk("axiClk"),
      axiClkRst("axiClkRst"),
      arvalid("arvalid"),
      arready("arready"),
      araddr("araddr"),
      arid("arid"),
      arlen("arlen"),
      arsize("arsize"),
      arburst("arburst"),
      arlock("arlock"),
      arprot("arprot"),
      arcache("arcache"),
      arqos("arqos"),
      aruser("aruser"),
      rready("rready"),
      rdataH("rdataH"),
      rdataL("rdataL"),
      rlast("rlast"),
      rvalid("rvalid"),
      rid("rid"),
      rresp("rresp"),
      rdissuecap1_en("rdissuecap1_en"),
      racount("racount"),
      rcount("rcount"),
      awvalid("awvalid"),
      awready("awready"),
      awaddr("awaddr"),
      awid("awid"),
      awlen("awlen"),
      awsize("awsize"),
      awburst("awburst"),
      awlock("awlock"),
      awcache("awcache"),
      awprot("awprot"),
      awqos("awqos"),
      awuser("awuser"),
      wready("wready"),
      wdataH("wdataH"),
      wdataL("wdataL"),
      wlast("wlast"),
      wvalid("wvalid"),
      wid("wid"),
      wstrb("wstrb"),
      bready("bready"),
      bresp("bresp"),
      bvalid("bvalid"),
      bid("bid"),
      wrissuecap1_en("wrissuecap1_en"),
      wacount("wacount"),
      wcount("wcount")
   {

      // Setup threads
      SC_CTHREAD(slaveThread,axiClk.pos());
   }
};

#endif
