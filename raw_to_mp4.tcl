#
# NAME
#  raw_to_mp4.tcl
#
# DESCRIPTION
#  Tcl script to series of raw files dumped from stim to mp4 video
#
# DETAILS
#  Uses Impro tools from tcl and ffmpeg to convert series of raw files to
#  png and then to mp4.  Expects ffmpeg to be on path and currently assumes
#  files are numbered 000, 001, 002, etc. (matching %04cdd)
#
#  USAGE
#   tclsh8.6 raw_to_mp4.tcl foldername fileprefix
#  
#   C:\usr\local\bin\tclsh86 L:\projects\analysis\aarit\raw_to_mp4.tcl C:\Users\lab\tmp\raw t
#     (would convert series of images C:\Users\lab\tmp\raw t*0.raw, etc. to trial.mp4)


package require dlsh
load_Impro

proc raw_to_mp4 { folder prefix } {
    set files [glob [file join $folder $prefix]*.raw]
    foreach filename $files {
	set img [img_load $filename]
	set outfile [file root $filename].png
	img_writePNG $img $outfile
	img_delete $img
    }
    set framerate 100
    scan [file tail $outfile] "t%3d_f%4d.png" trial frame
    puts "$trial $frame"
    set format_string %04d

    set inpattern [format $prefix%03d_f $trial]
    set infile [file join $folder $inpattern${format_string}.png]
    set outpattern [format ${prefix}%03d.mp4 $trial]
    set outfile [file join $folder $outpattern]
    #puts " exec ffmpeg -hide_banner -nostats -loglevel panic -y -r $framerate -i $infile -c:v libx264 -pix_fmt yuv420p $outfile "
    exec ffmpeg -hide_banner -nostats -loglevel panic -y -r $framerate -i $infile -c:v libx264 -pix_fmt yuv420p $outfile

    # could clean up .png and .raw files here
}

if { $argc > 1 } { 
    raw_to_mp4 [lindex $argv 0] [lindex $argv 1]
}
