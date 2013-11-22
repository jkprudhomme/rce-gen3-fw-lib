
# Create net list
set netList [get_nets "                       \
      ${modulePath}/arbReq*                   \
      ${modulePath}/arbGnt*                   \
      ${modulePath}/arbSelect*                \
      ${modulePath}/arbSelectFilt*            \
      ${modulePath}/regReadToCntrl*           \
      ${modulePath}/aFifoWr                   \
      ${modulePath}/aFifoRd                   \
      ${modulePath}/aFifoDin*                 \
      ${modulePath}/aFifoDout*                \
      ${modulePath}/aFifoValid                \
      ${modulePath}/aFifoPFull                \
      ${modulePath}/rdata*                    \
      ${modulePath}/rlast                     \
      ${modulePath}/rvalid*                   \
      ${modulePath}/rresp*                    \
      ${modulePath}/axiReadToCntrl*req*       \
      ${modulePath}/axiReadToCntrl*avalid*    \
      ${modulePath}/axiReadToCntrl*id*        \
      ${modulePath}/axiReadToCntrl*length*    \
      ${modulePath}/axiReadToCntrl*afull*     \
      ${modulePath}/axiReadFromCntrl*gnt*     \
      ${modulePath}/axiReadFromCntrl*afull*   \
      ${modulePath}/axiReadFromCntrl*rdata*   \
      ${modulePath}/axiReadFromCntrl*rvalid*  \
      ${modulePath}/axiReadFromCntrl*rresp*   \
      ${modulePath}/axiSlaveReadToArm*        \
      ${modulePath}/axiSlaveReadFromArm*      \
   "]

# Create and setup 
set probeName [create_debug_port ${ilaName} probe]
set_property port_width [llength ${netList}] ${probeName}

# Connect nets
connect_debug_port ${probeName} ${netList}

