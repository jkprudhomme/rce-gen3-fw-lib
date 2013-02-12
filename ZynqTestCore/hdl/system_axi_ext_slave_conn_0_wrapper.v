//-----------------------------------------------------------------------------
// system_axi_ext_slave_conn_0_wrapper.v
//-----------------------------------------------------------------------------

(* x_core_info = "axi_ext_slave_conn_v1_00_a" *)
module system_axi_ext_slave_conn_0_wrapper
  (
    ACLK,
    ARESETN,
    S_AXI_AWID,
    S_AXI_AWADDR,
    S_AXI_AWLEN,
    S_AXI_AWSIZE,
    S_AXI_AWBURST,
    S_AXI_AWLOCK,
    S_AXI_AWCACHE,
    S_AXI_AWPROT,
    S_AXI_AWREGION,
    S_AXI_AWQOS,
    S_AXI_AWUSER,
    S_AXI_AWVALID,
    S_AXI_AWREADY,
    S_AXI_WID,
    S_AXI_WDATA,
    S_AXI_WSTRB,
    S_AXI_WLAST,
    S_AXI_WUSER,
    S_AXI_WVALID,
    S_AXI_WREADY,
    S_AXI_BID,
    S_AXI_BRESP,
    S_AXI_BUSER,
    S_AXI_BVALID,
    S_AXI_BREADY,
    S_AXI_ARID,
    S_AXI_ARADDR,
    S_AXI_ARLEN,
    S_AXI_ARSIZE,
    S_AXI_ARBURST,
    S_AXI_ARLOCK,
    S_AXI_ARCACHE,
    S_AXI_ARPROT,
    S_AXI_ARREGION,
    S_AXI_ARQOS,
    S_AXI_ARUSER,
    S_AXI_ARVALID,
    S_AXI_ARREADY,
    S_AXI_RID,
    S_AXI_RDATA,
    S_AXI_RRESP,
    S_AXI_RLAST,
    S_AXI_RUSER,
    S_AXI_RVALID,
    S_AXI_RREADY,
    M_AXI_AWID,
    M_AXI_AWADDR,
    M_AXI_AWLEN,
    M_AXI_AWSIZE,
    M_AXI_AWBURST,
    M_AXI_AWLOCK,
    M_AXI_AWCACHE,
    M_AXI_AWPROT,
    M_AXI_AWREGION,
    M_AXI_AWQOS,
    M_AXI_AWUSER,
    M_AXI_AWVALID,
    M_AXI_AWREADY,
    M_AXI_WID,
    M_AXI_WDATA,
    M_AXI_WSTRB,
    M_AXI_WLAST,
    M_AXI_WUSER,
    M_AXI_WVALID,
    M_AXI_WREADY,
    M_AXI_BID,
    M_AXI_BRESP,
    M_AXI_BUSER,
    M_AXI_BVALID,
    M_AXI_BREADY,
    M_AXI_ARID,
    M_AXI_ARADDR,
    M_AXI_ARLEN,
    M_AXI_ARSIZE,
    M_AXI_ARBURST,
    M_AXI_ARLOCK,
    M_AXI_ARCACHE,
    M_AXI_ARPROT,
    M_AXI_ARREGION,
    M_AXI_ARQOS,
    M_AXI_ARUSER,
    M_AXI_ARVALID,
    M_AXI_ARREADY,
    M_AXI_RID,
    M_AXI_RDATA,
    M_AXI_RRESP,
    M_AXI_RLAST,
    M_AXI_RUSER,
    M_AXI_RVALID,
    M_AXI_RREADY
  );
  input ACLK;
  input ARESETN;
  input [11:0] S_AXI_AWID;
  input [31:0] S_AXI_AWADDR;
  input [7:0] S_AXI_AWLEN;
  input [2:0] S_AXI_AWSIZE;
  input [1:0] S_AXI_AWBURST;
  input [1:0] S_AXI_AWLOCK;
  input [3:0] S_AXI_AWCACHE;
  input [2:0] S_AXI_AWPROT;
  input [3:0] S_AXI_AWREGION;
  input [3:0] S_AXI_AWQOS;
  input [0:0] S_AXI_AWUSER;
  input S_AXI_AWVALID;
  output S_AXI_AWREADY;
  input [11:0] S_AXI_WID;
  input [31:0] S_AXI_WDATA;
  input [3:0] S_AXI_WSTRB;
  input S_AXI_WLAST;
  input [0:0] S_AXI_WUSER;
  input S_AXI_WVALID;
  output S_AXI_WREADY;
  output [11:0] S_AXI_BID;
  output [1:0] S_AXI_BRESP;
  output [0:0] S_AXI_BUSER;
  output S_AXI_BVALID;
  input S_AXI_BREADY;
  input [11:0] S_AXI_ARID;
  input [31:0] S_AXI_ARADDR;
  input [7:0] S_AXI_ARLEN;
  input [2:0] S_AXI_ARSIZE;
  input [1:0] S_AXI_ARBURST;
  input [1:0] S_AXI_ARLOCK;
  input [3:0] S_AXI_ARCACHE;
  input [2:0] S_AXI_ARPROT;
  input [3:0] S_AXI_ARREGION;
  input [3:0] S_AXI_ARQOS;
  input [0:0] S_AXI_ARUSER;
  input S_AXI_ARVALID;
  output S_AXI_ARREADY;
  output [11:0] S_AXI_RID;
  output [31:0] S_AXI_RDATA;
  output [1:0] S_AXI_RRESP;
  output S_AXI_RLAST;
  output [0:0] S_AXI_RUSER;
  output S_AXI_RVALID;
  input S_AXI_RREADY;
  output [11:0] M_AXI_AWID;
  output [31:0] M_AXI_AWADDR;
  output [7:0] M_AXI_AWLEN;
  output [2:0] M_AXI_AWSIZE;
  output [1:0] M_AXI_AWBURST;
  output [1:0] M_AXI_AWLOCK;
  output [3:0] M_AXI_AWCACHE;
  output [2:0] M_AXI_AWPROT;
  output [3:0] M_AXI_AWREGION;
  output [3:0] M_AXI_AWQOS;
  output [0:0] M_AXI_AWUSER;
  output M_AXI_AWVALID;
  input M_AXI_AWREADY;
  output [11:0] M_AXI_WID;
  output [31:0] M_AXI_WDATA;
  output [3:0] M_AXI_WSTRB;
  output M_AXI_WLAST;
  output [0:0] M_AXI_WUSER;
  output M_AXI_WVALID;
  input M_AXI_WREADY;
  input [11:0] M_AXI_BID;
  input [1:0] M_AXI_BRESP;
  input [0:0] M_AXI_BUSER;
  input M_AXI_BVALID;
  output M_AXI_BREADY;
  output [11:0] M_AXI_ARID;
  output [31:0] M_AXI_ARADDR;
  output [7:0] M_AXI_ARLEN;
  output [2:0] M_AXI_ARSIZE;
  output [1:0] M_AXI_ARBURST;
  output [1:0] M_AXI_ARLOCK;
  output [3:0] M_AXI_ARCACHE;
  output [2:0] M_AXI_ARPROT;
  output [3:0] M_AXI_ARREGION;
  output [3:0] M_AXI_ARQOS;
  output [0:0] M_AXI_ARUSER;
  output M_AXI_ARVALID;
  input M_AXI_ARREADY;
  input [11:0] M_AXI_RID;
  input [31:0] M_AXI_RDATA;
  input [1:0] M_AXI_RRESP;
  input M_AXI_RLAST;
  input [0:0] M_AXI_RUSER;
  input M_AXI_RVALID;
  output M_AXI_RREADY;

  axi_ext_slave_conn
    #(
      .C_S_AXI_ID_WIDTH ( 12 ),
      .C_S_AXI_ADDR_WIDTH ( 32 ),
      .C_S_AXI_DATA_WIDTH ( 32 ),
      .C_S_AXI_AWUSER_WIDTH ( 1 ),
      .C_S_AXI_ARUSER_WIDTH ( 1 ),
      .C_S_AXI_WUSER_WIDTH ( 1 ),
      .C_S_AXI_RUSER_WIDTH ( 1 ),
      .C_S_AXI_BUSER_WIDTH ( 1 )
    )
    axi_ext_slave_conn_0 (
      .ACLK ( ACLK ),
      .ARESETN ( ARESETN ),
      .S_AXI_AWID ( S_AXI_AWID ),
      .S_AXI_AWADDR ( S_AXI_AWADDR ),
      .S_AXI_AWLEN ( S_AXI_AWLEN ),
      .S_AXI_AWSIZE ( S_AXI_AWSIZE ),
      .S_AXI_AWBURST ( S_AXI_AWBURST ),
      .S_AXI_AWLOCK ( S_AXI_AWLOCK ),
      .S_AXI_AWCACHE ( S_AXI_AWCACHE ),
      .S_AXI_AWPROT ( S_AXI_AWPROT ),
      .S_AXI_AWREGION ( S_AXI_AWREGION ),
      .S_AXI_AWQOS ( S_AXI_AWQOS ),
      .S_AXI_AWUSER ( S_AXI_AWUSER ),
      .S_AXI_AWVALID ( S_AXI_AWVALID ),
      .S_AXI_AWREADY ( S_AXI_AWREADY ),
      .S_AXI_WID ( S_AXI_WID ),
      .S_AXI_WDATA ( S_AXI_WDATA ),
      .S_AXI_WSTRB ( S_AXI_WSTRB ),
      .S_AXI_WLAST ( S_AXI_WLAST ),
      .S_AXI_WUSER ( S_AXI_WUSER ),
      .S_AXI_WVALID ( S_AXI_WVALID ),
      .S_AXI_WREADY ( S_AXI_WREADY ),
      .S_AXI_BID ( S_AXI_BID ),
      .S_AXI_BRESP ( S_AXI_BRESP ),
      .S_AXI_BUSER ( S_AXI_BUSER ),
      .S_AXI_BVALID ( S_AXI_BVALID ),
      .S_AXI_BREADY ( S_AXI_BREADY ),
      .S_AXI_ARID ( S_AXI_ARID ),
      .S_AXI_ARADDR ( S_AXI_ARADDR ),
      .S_AXI_ARLEN ( S_AXI_ARLEN ),
      .S_AXI_ARSIZE ( S_AXI_ARSIZE ),
      .S_AXI_ARBURST ( S_AXI_ARBURST ),
      .S_AXI_ARLOCK ( S_AXI_ARLOCK ),
      .S_AXI_ARCACHE ( S_AXI_ARCACHE ),
      .S_AXI_ARPROT ( S_AXI_ARPROT ),
      .S_AXI_ARREGION ( S_AXI_ARREGION ),
      .S_AXI_ARQOS ( S_AXI_ARQOS ),
      .S_AXI_ARUSER ( S_AXI_ARUSER ),
      .S_AXI_ARVALID ( S_AXI_ARVALID ),
      .S_AXI_ARREADY ( S_AXI_ARREADY ),
      .S_AXI_RID ( S_AXI_RID ),
      .S_AXI_RDATA ( S_AXI_RDATA ),
      .S_AXI_RRESP ( S_AXI_RRESP ),
      .S_AXI_RLAST ( S_AXI_RLAST ),
      .S_AXI_RUSER ( S_AXI_RUSER ),
      .S_AXI_RVALID ( S_AXI_RVALID ),
      .S_AXI_RREADY ( S_AXI_RREADY ),
      .M_AXI_AWID ( M_AXI_AWID ),
      .M_AXI_AWADDR ( M_AXI_AWADDR ),
      .M_AXI_AWLEN ( M_AXI_AWLEN ),
      .M_AXI_AWSIZE ( M_AXI_AWSIZE ),
      .M_AXI_AWBURST ( M_AXI_AWBURST ),
      .M_AXI_AWLOCK ( M_AXI_AWLOCK ),
      .M_AXI_AWCACHE ( M_AXI_AWCACHE ),
      .M_AXI_AWPROT ( M_AXI_AWPROT ),
      .M_AXI_AWREGION ( M_AXI_AWREGION ),
      .M_AXI_AWQOS ( M_AXI_AWQOS ),
      .M_AXI_AWUSER ( M_AXI_AWUSER ),
      .M_AXI_AWVALID ( M_AXI_AWVALID ),
      .M_AXI_AWREADY ( M_AXI_AWREADY ),
      .M_AXI_WID ( M_AXI_WID ),
      .M_AXI_WDATA ( M_AXI_WDATA ),
      .M_AXI_WSTRB ( M_AXI_WSTRB ),
      .M_AXI_WLAST ( M_AXI_WLAST ),
      .M_AXI_WUSER ( M_AXI_WUSER ),
      .M_AXI_WVALID ( M_AXI_WVALID ),
      .M_AXI_WREADY ( M_AXI_WREADY ),
      .M_AXI_BID ( M_AXI_BID ),
      .M_AXI_BRESP ( M_AXI_BRESP ),
      .M_AXI_BUSER ( M_AXI_BUSER ),
      .M_AXI_BVALID ( M_AXI_BVALID ),
      .M_AXI_BREADY ( M_AXI_BREADY ),
      .M_AXI_ARID ( M_AXI_ARID ),
      .M_AXI_ARADDR ( M_AXI_ARADDR ),
      .M_AXI_ARLEN ( M_AXI_ARLEN ),
      .M_AXI_ARSIZE ( M_AXI_ARSIZE ),
      .M_AXI_ARBURST ( M_AXI_ARBURST ),
      .M_AXI_ARLOCK ( M_AXI_ARLOCK ),
      .M_AXI_ARCACHE ( M_AXI_ARCACHE ),
      .M_AXI_ARPROT ( M_AXI_ARPROT ),
      .M_AXI_ARREGION ( M_AXI_ARREGION ),
      .M_AXI_ARQOS ( M_AXI_ARQOS ),
      .M_AXI_ARUSER ( M_AXI_ARUSER ),
      .M_AXI_ARVALID ( M_AXI_ARVALID ),
      .M_AXI_ARREADY ( M_AXI_ARREADY ),
      .M_AXI_RID ( M_AXI_RID ),
      .M_AXI_RDATA ( M_AXI_RDATA ),
      .M_AXI_RRESP ( M_AXI_RRESP ),
      .M_AXI_RLAST ( M_AXI_RLAST ),
      .M_AXI_RUSER ( M_AXI_RUSER ),
      .M_AXI_RVALID ( M_AXI_RVALID ),
      .M_AXI_RREADY ( M_AXI_RREADY )
    );

endmodule

