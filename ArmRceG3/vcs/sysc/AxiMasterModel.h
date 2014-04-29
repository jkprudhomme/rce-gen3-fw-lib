#ifndef __AXI_MASTER_MODEL_H__
#define __AXI_MASTER_MODEL_H__
#include <systemc.h>
#include <sys/types.h>
#include "../../software/lib//AxiSharedMem.h"
using namespace std;

// Module declaration
SC_MODULE(AxiMasterModel) {

   // Channel id
   sc_in    <sc_lv<8>  > masterId;

   // Clock and reset
   sc_in    <sc_logic  > axiClk;
   sc_out   <sc_logic  > axiClkRst;

   // Read address channel
   sc_out   <sc_logic  > arvalid;
   sc_in    <sc_logic  > arready;
   sc_out   <sc_lv<32> > araddr;
   sc_out   <sc_lv<12> > arid;
   sc_out   <sc_lv<4>  > arlen;
   sc_out   <sc_lv<3>  > arsize;
   sc_out   <sc_lv<2>  > arburst;
   sc_out   <sc_lv<2>  > arlock;
   sc_out   <sc_lv<3>  > arprot;
   sc_out   <sc_lv<4>  > arcache;
   sc_out   <sc_lv<4>  > arqos;
   sc_out   <sc_lv<5>  > aruser;

   // Read data channel
   sc_out   <sc_logic  > rready;
   sc_in    <sc_lv<32> > rdataH;
   sc_in    <sc_lv<32> > rdataL;
   sc_in    <sc_logic  > rlast;
   sc_in    <sc_logic  > rvalid;
   sc_in    <sc_lv<12> > rid;
   sc_in    <sc_lv<2>  > rresp;

   // Read Control 
   sc_out   <sc_logic  > rdissuecap1_en;

   // Read Status
   sc_in    <sc_lv<3>  > racount;
   sc_in    <sc_lv<8>  > rcount;

   // Write address channel
   sc_out   <sc_logic  > awvalid;
   sc_in    <sc_logic  > awready;
   sc_out   <sc_lv<32> > awaddr;
   sc_out   <sc_lv<12> > awid;
   sc_out   <sc_lv<4>  > awlen;
   sc_out   <sc_lv<3>  > awsize;
   sc_out   <sc_lv<2>  > awburst;
   sc_out   <sc_lv<2>  > awlock;
   sc_out   <sc_lv<4>  > awcache;
   sc_out   <sc_lv<3>  > awprot;
   sc_out   <sc_lv<4>  > awqos;
   sc_out   <sc_lv<5>  > awuser;

   // Write data channel
   sc_in    <sc_logic  > wready;
   sc_out   <sc_lv<32> > wdataH;
   sc_out   <sc_lv<32> > wdataL;
   sc_out   <sc_logic  > wlast;
   sc_out   <sc_logic  > wvalid;
   sc_out   <sc_lv<12> > wid;
   sc_out   <sc_lv<8>  > wstrb;

   // Write ack channel
   sc_out   <sc_logic  > bready;
   sc_in    <sc_lv<2>  > bresp;
   sc_in    <sc_logic  > bvalid;
   sc_in    <sc_lv<12> > bid;

   // Control
   sc_out   <sc_logic  > wrissuecap1_en;

   // Status
   sc_in    <sc_lv<6>  > wacount;
   sc_in    <sc_lv<8>  > wcount;

   // Master thread
   void masterThread(void);

   // Constructor
   SC_CTOR(AxiMasterModel):
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
      SC_CTHREAD(masterThread,axiClk.pos());
   }
};

#endif
