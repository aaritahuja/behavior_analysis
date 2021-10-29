proc show_trials { g } {
    set ::activator::execcmd "show_trial $g %n"
    activator::setup
}

proc show_trial { g trial { show_saccades 1 } } {
    set w [get_world $g $trial]
    clearwin
    
    # Setup the viewport to be the middle of the original display
    setwindow -16 -12 16 12
    
    set stimon [dl_get $g:stimon $trial]
    set response [dl_get $g:response $trial]
    
    dl_local valid_sacs [dl_between $g:sactimes:$trial $stimon $response]
    dl_local sactos [dl_select $g:sactos:$trial $valid_sacs]
    dl_local sac_x1 [dl_unpack [dl_choose $sactos [dl_llist 0]]]
    dl_local sac_y1 [dl_unpack [dl_choose $sactos [dl_llist 1]]]
    #dl_local sac_x1 [dl_select $sac_1 [dl_between $sac_2 -12 12]]
    #dl_local sac_y1 [dl_select $sac_2 [dl_between $sac_2 -12 12]]
    
    set w [dg_copySelected $w [dl_not [dl_oneof $w:name [dl_slist gate_center b_wall l_wall r_wall]]]]
    show_world $w

    if { $show_saccades } {
	dlg_lines $sac_x1 $sac_y1 -lwidth 100
	dlg_markers $sac_x1 $sac_y1 -marker fcircle -size 1x -color $::colors(cyan)
	dlg_text $sac_x1 $sac_y1 [dl_series 1 [dl_length $sac_x1]] \
	-color $::colors(black)
    } else {
	dl_local ems [get_ems_pre_response $g]
	dlg_markers $ems:0:$trial $ems:1:$trial -marker fcircle -color $::colors(cyan)
    }
}

proc get_world { dg trial } {
    set w [dg_create]
    foreach l [dg_tclListnames $dg] {
	if { [regexp "world" $l m] == 1 } {
	    set name [split $l {}]
	    set name [lrange $name 6 end]
	    set name [join $name {}]
	    dl_set $w:$name $dg:$l:$trial
	}
    }
    return $w
}


proc show_world { w } {
    global nworld floor blocks sphere
    set nbodies [dl_length $w:type]
    
    for { set i 0 } { $i < $nbodies } { incr i } {
	set sx [dl_get $w:sx $i]
	set sy [dl_get $w:sy $i]
	set sz [dl_get $w:sz $i]
	set tx [dl_get $w:tx $i]
	set ty [dl_get $w:ty $i]
	set tz [dl_get $w:tz $i]
	set color_r [dl_get $w:color_r $i]
	set color_g [dl_get $w:color_g $i]
	set color_b [dl_get $w:color_b $i]
	set spin [dl_get $w:spin $i]
	set mass [dl_get $w:mass $i]
	set dynamic [dl_get $w:dynamic $i]
	set elasticity [dl_get $w:elasticity $i]
	set show [dl_get $w:show $i]
	set name [dl_get $w:name $i]
	
	if { [dl_get $w:type $i] == "box" } {
	    set body [show_box $name $tx $ty $tz $sx $sy $sz $spin 0 0 1]
	} elseif { [dl_get $w:type $i] == "sphere" } {
	    set r [expr int($color_r*256)]
	    set g [expr int($color_g*256)]
	    set b [expr int($color_b*256)]
	    set color [dlg_rgbcolor $r $g $b]
	    set body [show_sphere $tx $ty $tz $sx $sy $sz $color]
	}
    }
}

proc get_ems_pre_response { g } {
    set sample_interval 5
    # Create indices of interest (between stimon and response)
    dl_local start_inds [dl_div $g:stimon $sample_interval]
    dl_local stop_inds [dl_div $g:response $sample_interval]
    dl_local inds [dl_fromto $start_inds $stop_inds]

    # Get horizontal ems
    dl_local h_ems [dl_unpack [dl_choose $g:ems [dl_llist 1]]]
    dl_local selected_h_ems [dl_choose $h_ems $inds]

    dl_local v_ems [dl_unpack [dl_choose $g:ems [dl_llist 2]]]
    dl_local selected_v_ems [dl_choose $v_ems $inds]

    dl_return [dl_llist $selected_h_ems $selected_v_ems]
}
