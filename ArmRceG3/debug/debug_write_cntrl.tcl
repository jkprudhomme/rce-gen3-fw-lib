
# Create net list
set netList [get_nets "                       \
      ${modulePath}/arbReq*                   \
      ${modulePath}/arbGnt*                   \
      ${modulePath}/preGnt*                   \
      ${modulePath}/preSelect*                \
      ${modulePath}/arbValid*                 \
      ${modulePath}/arbSelect*                \
      ${modulePath}/arbSelectFilt*            \
      ${modulePath}/regWriteToCntrl*          \
      ${modulePath}/aFifoWr                   \
      ${modulePath}/aFifoRd                   \
      ${modulePath}/aFifoDin*                 \
      ${modulePath}/aFifoDout*                \
      ${modulePath}/aFifoValid                \
      ${modulePath}/aFifoPFull                \
      ${modulePath}/dFifoWr                   \
      ${modulePath}/dFifoRd                   \
      ${modulePath}/dFifoDin*                 \
      ${modulePath}/dFifoDout*                \
      ${modulePath}/dFifoValid                \
      ${modulePath}/dFifoPFull                \
      ${modulePath}/dSize*                    \
      ${modulePath}/dValid*                   \
      ${modulePath}/bresp*                    \
      ${modulePath}/bvalid*                   \
      ${modulePath}/axiWriteToCntrl*req*      \
      ${modulePath}/axiWriteToCntrl*avalid*   \
      ${modulePath}/axiWriteToCntrl*id*       \
      ${modulePath}/axiWriteToCntrl*length*   \
      ${modulePath}/axiWriteToCntrl*dvalid*   \
      ${modulePath}/axiWriteToCntrl*dstrobe*  \
      ${modulePath}/axiWriteToCntrl*last*     \
      ${modulePath}/axiWriteFromCntrl*gnt*    \
      ${modulePath}/axiWriteFromCntrl*afull*  \
      ${modulePath}/axiWriteFromCntrl*bresp*  \
      ${modulePath}/axiWriteFromCntrl*bvalid* \
      ${modulePath}/axiSlaveWriteToArm*       \
      ${modulePath}/axiSlaveWriteFromArm*     \
   "]

# Create and setup 
set probeName [create_debug_port ${ilaName} probe]
set_property port_width [llength ${netList}] ${probeName}

# Connect nets
connect_debug_port ${probeName} ${netList}

