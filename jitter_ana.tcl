# get jittered difficulty for boards

set env(DLSH_LIBRARY) /usr/local/lib/dlsh
package require dlsh
package require loaddata
set datadir /shared/lab/projects/encounter/data

source sim_ana.tcl

proc do_test { nreps scale } {
    set g [load_data -verbose 0 h20_simulation_0*]
    dl_local wrong_sidewalls [dl_and [dl_or [dl_regmatch $g:world#name target_left*] [dl_regmatch $g:world#name target_right*]] [dl_eq $g:side 1]]
    dl_local invert [dl_replace [dl_replicate [dl_llist [dl_ones 21]] [dl_length $g:ids]] $wrong_sidewalls -1]
    dl_set $g:world#tx [dl_mult $g:world#tx $invert]
    try_jitter_combinations $g $nreps $scale
}

if { $argc > 0 } {
    set scale [lindex $argv 0]
} else {
    set scale 5
}

set nreps 500
do_test $nreps $scale
