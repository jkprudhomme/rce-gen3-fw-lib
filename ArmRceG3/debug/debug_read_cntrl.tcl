
# Create net list
set netList [get_nets "                  \
      ${modulePath}/arbReq*              \
      ${modulePath}/arbGnt*              \
      ${modulePath}/arbSelect*           \
      ${modulePath}/arbSelectFilt*       \
      ${modulePath}/regReadToCntrl*      \
      ${modulePath}/aFifoWr              \
      ${modulePath}/aFifoRd              \
      ${modulePath}/aFifoDin*            \
      ${modulePath}/aFifoDout*           \
      ${modulePath}/aFifoValid           \
      ${modulePath}/aFifoPFull           \
      ${modulePath}/rdata*               \
      ${modulePath}/rlast                \
      ${modulePath}/rvalid*              \
      ${modulePath}/rresp*               \
   "]

# Create and setup 
set probeName [create_debug_port ${ilaName} probe]
set_property port_width [llength ${netList}] ${probeName}

# Connect nets
connect_debug_port ${probeName} ${netList}

