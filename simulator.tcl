#
# Make stim run through a series of trials to create multiple movies
#

package require stimctrl
package require dlsh
load_Impro
set host localhost

proc dump_all_trials { n } {
    global state
    
    for { set i 0 } { $i < $n } { incr i } {
	set wait_time 30000
	
	rmt_send $::host "nexttrial; show 0"
	#rmt_send $::host ::action::simulation::open_center_gate
	set state running
	after $wait_time set state done
	vwait state
	puts "$i completed"
	rmt_send $::host "endtrial 0; clearscreen"
    }
}


proc raw_to_mp4 { folder prefix } {
    set files [glob [file join $folder $prefix]*.raw]
    foreach filename $files {
	set img [img_load $filename]
	set outfile [file root $filename].png
	img_writePNG $img $outfile
	img_delete $img
    }
    set framerate 60
    scan [file tail $outfile] "t%3d_f%4d.png" trial frame
    #puts "$trial $frame"
    set format_string %04d

    set inpattern [format $prefix%03d_f $trial]
    set infile [file join $folder $inpattern${format_string}.png]
    set outpattern [format ${prefix}%03d.mp4 $trial]
    set outfile [file join $folder $outpattern]
    #puts " exec ffmpeg -hide_banner -nostats -loglevel panic -y -r $framerate -i $infile -c:v libx264 -pix_fmt yuv420p $outfile "
    exec ffmpeg -hide_banner -nostats -loglevel panic -y -r $framerate -i $infile -c:v libx264 -pix_fmt yuv420p $outfile

    # could clean up .png and .raw files here
}


#if { $argc > 1 } { 
#    raw_to_mp4 [lindex $argv 0] [lindex $argv 1]
#}


dump_all_trials 12

#for { set i 0 } { $i < 12 } { incr i } { 
#    raw_to_mp4 C:/Users/lab/tmp/raw/hyundai/$i t
#}

	

