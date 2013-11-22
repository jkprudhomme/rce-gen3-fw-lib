
set topPath U_EvalCore

# Create net list
set netList [get_nets "                                 \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*req*      \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*avalid*   \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*id*       \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*length*   \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*dvalid*   \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*dstrobe*  \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteToCntrl*last*     \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteFromCntrl*gnt*    \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteFromCntrl*afull*  \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteFromCntrl*bresp*  \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/axiWriteFromCntrl*bvalid* \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadToCntrl*req*       \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadToCntrl*avalid*    \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadToCntrl*id*        \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadToCntrl*length*    \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadToCntrl*afull*     \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadFromCntrl*gnt*     \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadFromCntrl*afull*   \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadFromCntrl*rdata*   \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadFromCntrl*rvalid*  \
      ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/axiReadFromCntrl*rresp*   \
      ${topPath}/U_ArmRceG3Top/axiAcpSlaveWriteFromArm*                               \
      ${topPath}/U_ArmRceG3Top/axiAcpSlaveWriteToArm*                                 \
      ${topPath}/U_ArmRceG3Top/axiAcpSlaveReadToArm*                                  \
      ${topPath}/U_ArmRceG3Top/axiAcpSlaveReadFromArm*                                \
   "]

# Create and setup 
set probeName [create_debug_port ${ilaName} probe]
set_property port_width [llength ${netList}] ${probeName}

# Connect nets
connect_debug_port ${probeName} ${netList}

# Debug ACP Write Controller
set modulePath ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_ObCntrl/U_ReadCntrl
source ${TOP_DIR}/modules/ArmRceG3/debug/debug_read_cntrl.tcl

# Debug ACP Write Controller
set modulePath ${topPath}/U_ArmRceG3Top/U_ArmRceG3DmaCntrl/U_IbCntrl/U_WriteCntrl
source ${TOP_DIR}/modules/ArmRceG3/debug/debug_write_cntrl.tcl

