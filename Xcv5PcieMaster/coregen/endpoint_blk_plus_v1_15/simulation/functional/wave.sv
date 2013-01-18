#
# preferences
#
preferences set default-time-units ns
preferences set signal-type-colors {
        group #0000FF
        overlay #0000FF
        input #FFFF00
        output #FFA500
        inout #00FFFF
        internal #00FF00
        fiber #FF99FF
        errorsignal #FF0000
        assertion #FF0000
        unknown #FFFFFF
}
preferences set schematic-color-highlight #ff0000
preferences set sb-editor-command {xterm -e vi +%L %F}
preferences set sb-module-only 0
preferences set verilog-colors {
        HiZ #ff9900
        StrX #ff0000
        Sm #00ff99
        Me #0000ff
        We #00ffff
        La #ff00ff
        Pu #9900ff
        St #00ff00
        Su #ff0099
        0 #00ff00
        1 #00ff00
        X #ff0000
        Z #ff9900
        other #ffff00
}
preferences set waveform-height 14
preferences set sfb-colors {
        register #beded1
        variable #beded1
        assignStmt gray85
        force #faa385
}
preferences set sb-syntax-types {
    {
        -name "VHDL/VHDL-AMS" -dacname "vhdl" -extensions {.vhd .vhdl}
        -ignorecase 1 -multiline {} -singleline {--} -singlechar {} -onechar {'}
        -keywords {
            \{ abs access after alias all
            and architecture array assert attribute
            begin block body buffer bus
            case component configuration constant disconnect
            downto else elsif end entity
            exit file for function generate
            generic group guarded if impure
            in inertial inout is label
            library linkage literal loop map
            mod nand new next nor
            not null of on open
            or others out package port
            postponed procedure process pure range
            record register reject rem report
            return rol ror select severity
            signal shared sla sll sra
            srl subtype then to transport
            type unaffected units until use
            variable wait when while xnor
            xor `base `left `right `high
            `low `ascending `image `value `pos
            `val `succ `pred `leftof `rightof
            `range `reverse_range `length `delayed `stable
            `quiet `transaction `event `last_event `last_active
            `last_value `driving `driving_value `simple_name `instance_name
            `path_name
            across break nature noise quantity procedural
            reference spectrum subnature terminal through
            tolerance \}
        }
    }
    {
        -name "Verilog/Verilog-AMS" -dacname "verilog" -extensions {.v .vams .vms .va}
        -multiline {/* */} -singleline {//} -singlechar {}
        -keywords {
            \{ always and assign attribute begin
            buf bufif0 bufif1 case casex
            casez cmos deassign default defparam
            disable edge else end endattribute
            endcase endmodule endfunction endprimitive endspecify
            endtable endtask event for force
            forever fork function highz0 highz1
            if initial inout input integer
            join large macromodule medium module
            nand negedge nmos nor not
            notif0 notif1 or output parameter
            pmos posedge primitive pull0 pull1
            pullup pulldown rcmos reg release
            repeat rnmos rpmos rtran rtranif0
            rtranif1 scalared small specify specparam
            strength strong0 strong1 supply0 supply1
            table task time tran tranif0
            tranif1 tri tri0 tri1 triand
            trior trireg use vectored wait
            wand weak0 weak1 while wire
            wor xnor xor
            nature endnature abstol access ddt_nature idt_nature
            units flow potential discipline enddiscipline domain
            discrete continuous branch genvar analog generate
            cross above timer initial_step final_step ddt
            idt idtmod absdelay transition slew laplace_zd
            laplace_zp laplace_nd laplace_np last_crossing zi_zp
            zi_zd zi_np zi_nd ac_stim white_noise flicker_noise
            noise_table analysis ln log exp sqrt min max abs pow
            ceil floor sin cos tan asin acos atan atan2 sinh cosh
            tanh asinh acosh atanh hypot driver_update connectrules
            endconnectrules connectmodule connect resolveto split
            merged inf from exclude ground wreal dynamicparam \}
        }
    }
    {
        -name "C" -dacname "c" -extensions {.c}
        -multiline {/* */} -singleline {}
        -keywords {
            \{ asm auto break case catch
            cdecl char class const continue
            default define delete do double
            else enum extern far float
            for goto huge if include
            inline int interrupt long near
            operator pascal register return short
            signed sizeof static struct switch
            typedef union unsigned void volatile
            while \}
        }
    }
    {
        -name "C++" -dacname "c++" -extensions {.h .hpp .cc .cpp .CC}
        -multiline {/* */} -singleline {//}
        -keywords {
            \{ asm auto break case catch
            cdecl char class const continue
            default define delete do double
            else enum extern far float
            for friend goto huge if
            include inline int interrupt long
            near new operator pascal private
            protected public register return short
            signed sizeof static struct switch
            template this typedef union unsigned
            virtual void volatile while \}
        }
    }
    {
        -name "SystemC" -dacname "systemc" -extensions {.h .hpp .cc .cpp .CC}
        -multiline {/* */} -singleline {//}
        -keywords {
            \{ asm auto break case catch
            cdecl char class const continue
            default define delete do double
            else enum extern far float
            for friend goto huge if
            include inline int interrupt long
            near new operator pascal private
            protected public register return short
            signed sizeof static struct switch
            template this typedef union unsigned
            virtual void volatile while \}
        }
    }
}
preferences set toolbar-txe_waveform_toggle-WaveWindow {
  usual
  position -pos 1
}
preferences set toolbar-Windows-SrcBrowser {
  usual
  hide icheck
}
preferences set key-bindings {
        Edit>Undo "Ctrl+Z"
        Edit>Redo "Ctrl+Y"
        Edit>Copy "Ctrl+C"
        Edit>Cut "Ctrl+X"
        Edit>Paste "Ctrl+V"
        Edit>Delete "Del"
        openDB "Ctrl+O"
        View>Zoom>InX "Alt+I"
        View>Zoom>OutX "Alt+O"
        View>Zoom>FullX "Alt+="
        View>Zoom>InX_widget "I"
        View>Zoom>OutX_widget "O"
        View>Zoom>FullX_widget "="
        View>Zoom>Cursor-Baseline "Alt+Z"
        View>Center "Alt+C"
        View>ExpandSequenceTime>AtCursor "Alt+X"
        View>CollapseSequenceTime>AtCursor "Alt+S"
        Edit>Create>Group "Ctrl+G"
        Edit>Ungroup "Ctrl+Shift+G"
        Edit>Create>Marker "Ctrl+M"
        Edit>Create>Condition "Ctrl+E"
        Edit>Create>Bus "Ctrl+W"
        Explore>NextEdge "Ctrl+\]"
        Explore>PreviousEdge "Ctrl+\["
        ScrollRight "Right arrow"
        ScrollLeft "Left arrow"
        ScrollUp "Up arrow"
        ScrollDown "Down arrow"
        PageUp "PageUp"
        PageDown "PageDown"
        TopOfPage "Home"
        BottomOfPage "End"
}
preferences set toolbar-Windows-WaveWindow {
  usual
  hide icheck
  position -pos 3
}
preferences set toolbar-Windows-WatchList {
  usual
  hide icheck
}
preferences set vhdl-colors {
        U #9900ff
        X #ff0000
        0 #00ff00
        1 #00ff00
        Z #ff9900
        W #ff0000
        L #00ffff
        H #00ffff
        - #0000ff
}
preferences set sb-syntax-highlight 0

#
# groups
#

if {[catch {group new -name {DSPORT TRN signals} -overlay 0}] != ""} {
    group using {DSPORT TRN signals}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :dsport_inst:trn_clk \
    :dsport_inst:trn_reset_n \
    :dsport_inst:trn_lnk_up_n \
    :dsport_inst:trn_td \
    :dsport_inst:trn_tsof_n \
    :dsport_inst:trn_teof_n \
    :dsport_inst:trn_tsrc_rdy_n \
    :dsport_inst:trn_tdst_rdy_n \
    :dsport_inst:trn_rd \
    :dsport_inst:trn_rsof_n \
    :dsport_inst:trn_reof_n \
    :dsport_inst:trn_rsrc_rdy_n \
    :dsport_inst:trn_rdst_rdy_n

if {[catch {group new -name {PIO TRN signals} -overlay 0}] != ""} {
    group using {PIO TRN signals}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
    :ep_inst:trn_clk_c \
    :ep_inst:trn_reset_n_c \
    :ep_inst:trn_lnk_up_n_c \
    :ep_inst:trn_td_c \
    :ep_inst:trn_tsof_n_c \
    :ep_inst:trn_teof_n_c \
    :ep_inst:trn_tsrc_rdy_n_c \
    :ep_inst:trn_tdst_rdy_n_c \
    :ep_inst:trn_rd_c \
    :ep_inst:trn_rsof_n_c \
    :ep_inst:trn_reof_n_c \
    :ep_inst:trn_rsrc_rdy_n_c \
    :ep_inst:trn_rdst_rdy_n_c \
    :ep_inst:trn_rbar_hit_n_c

if {[catch {group new -name {SYS signals} -overlay 0}] != ""} {
    group using {SYS signals}
    group set -overlay 0
    group set -comment {}
    group clear 0 end
}
group insert \
   :cor_sys_reset_n \
   :cor_sys_clk_p \
   :cor_sys_clk_n \
   :cor_pci_exp_txn \
   :cor_pci_exp_txp \
   :cor_pci_exp_rxn \
   :cor_pci_exp_rxp 


#
# mmaps
#
mmap new -reuse -name {Boolean as Logic} -contents {
{%c=FALSE -edgepriority 1 -linecolor #00ff00 -shape low}
{%c=TRUE -edgepriority 1 -linecolor #00ff00 -shape high}
}
mmap new -reuse -name {Example Map} -contents {
{%b=11???? -bgcolor orange -label REG:%x -linecolor yellow -shape bus}
{%x=1F -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=2C -bgcolor red -label ERROR -linecolor white -shape EVENT}
{%x=* -label %x -linecolor gray -shape bus}
}

#
# Design Browser windows
#
if {[catch {window new WatchList -name "Design Browser 1" -geometry 1031x500+562+0}] != ""} {
    window geometry "Design Browser 1" 1031x500+562+0
}
window target "Design Browser 1" on
browser using {Design Browser 1}
browser set \
    -scope :STM
browser yview see :STM
browser timecontrol set -lock 0

#
# Waveform windows
#
if {[catch {window new WaveWindow -name "Waveform 1" -geometry 1205x726+208+114}] != ""} {
    window geometry "Waveform 1" 1205x726+208+114
}
window target "Waveform 1" on
waveform using {Waveform 1}
waveform sidebar visibility partial
waveform set \
    -primarycursor TimeA \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using TimeA -time 3,362,000ps
waveform baseline set -time 0

set groupId [waveform add -groups {{SYS signals}}]

set groupId [waveform add -groups {{DSPORT TRN signals}}]

set groupId [waveform add -groups {{PIO TRN signals}}]


waveform xview limits 0 1500us

simcontrol run -time 1500us
