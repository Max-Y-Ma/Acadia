#!/usr/bin/perl
# -*- perl -*- Forces EMacs to use perl-mode 

use Getopt::Std; 

&getopts('s:o:');
if(!$opt_s || !$opt_o) {
    die "
dc_postprocessor.pl  -s <input SDF file>
                     -o <output SFD file>

This perl script modifes an SDF file created by Synopsys Design Compiler.  
The script creates a valid SDF that can be read by Artisan simulation models.


"
}

sub max {
    if ($_[0] < $_[1]){
        $_[1];
    } else {
        $_[0];
    }
}

$IN_FILE = $opt_s;
$OUT_FILE = $opt_o;

open(INPUT, $IN_FILE) || 
    die printf("Sorry, Could not open file %s\n",$IN_FILE);

open(OUTPUT, ">" . $OUT_FILE) ||
    die printf("Sorry, Could not open file %s\n",$OUT_FILE);

$inDelay=0;
$inAbsolute=0;

while (<INPUT>) {
#
# The following statement fixes the bus notation problem
#
    $_=~s/x(\d+)x/\[\1\]/g;

    @var = split;
    if (@var[0] eq "(DELAY"){
        $inDelay=1;
    }
    if (@var[0] eq "(ABSOLUTE"){
        $inAbsolute=1;
    }
    
#
# The following code prints out both posedge and negedge statements after
# Design Compiler combined them because they are the same.
#
    if ( ((@var[0] eq "(SETUP") || (@var[0] eq "(HOLD")) && 
	 ((@var[2] eq "(posedge") || (@var[2] eq "(negedge")) ){
	printf OUTPUT "    %s (posedge %s) %s %s %s\n",@var[0],@var[1],@var[2],@var[3],@var[4];
	printf OUTPUT "    %s (negedge %s) %s %s %s\n",@var[0],@var[1],@var[2],@var[3],@var[4];
    }
    # The following code collects the delays for arcs between MUX select inputs
    # TEN/BEN to MUX output. This data is stored in hash table, which is later
    # compressed to a single IOPATH statement in a conservative way.
    elsif (($_ =~ /IOPATH/) && (($_ =~ /negedge\s+TEN/) || ($_ =~ /negedge\s+ten/))){
        s/\(/ /g;
        s/\)/ /g;
        @line=split(" ",$_);
        $ten_negedge_r{$line[2]."_".$line[3]}=$line[4];
        $ten_negedge_f{$line[2]."_".$line[3]}=$line[5];
    }
    elsif (($_ =~ /IOPATH/) && (($_ =~ /posedge\s+TEN/) || ($_ =~ /posedge\s+ten/))){
        s/\(/ /g;
        s/\)/ /g;
        @line=split(" ",$_);
        $ten_posedge_r{$line[2]."_".$line[3]}=$line[4];
        $ten_posedge_f{$line[2]."_".$line[3]}=$line[5];
    }
    elsif (($_ =~ /IOPATH/) && (($_ =~ /negedge\s+BEN/) || ($_ =~ /negedge\s+ben/))){
        s/\(/ /g;
        s/\)/ /g;
        @line=split(" ",$_);
        $ben_negedge_r{$line[2]."_".$line[3]}=$line[4];
        $ben_negedge_f{$line[2]."_".$line[3]}=$line[5];
    }
    elsif (($_ =~ /IOPATH/) && (($_ =~ /posedge\s+BEN/) || ($_ =~ /posedge\s+ben/))){
        s/\(/ /g;
        s/\)/ /g;
        @line=split(" ",$_);
        $ben_posedge_r{$line[2]."_".$line[3]}=$line[4];
        $ben_posedge_f{$line[2]."_".$line[3]}=$line[5];
    }
#
# The following code removes the posedge statemnts from the
# IOPATH description.
#
    elsif ( ($_ =~ /IOPATH/) && ($_ =~ /posedge/) ){
        $_ =~ s/\(POSEDGE CLK\)/CLK/g;
        $_ =~ s/\(POSEDGE clk\)/clk/g;
        $_ =~ s/\(POSEDGE CLKA\)/CLKA/g;
        $_ =~ s/\(POSEDGE clka\)/clka/g;
        $_ =~ s/\(POSEDGE CLKB\)/CLKB/g;
        $_ =~ s/\(POSEDGE clkb\)/clkb/g;
        $_ =~ s/\(posedge CLK\)/CLK/g;
        $_ =~ s/\(posedge clk\)/clk/g;
        $_ =~ s/\(posedge CLKA\)/CLKA/g;
        $_ =~ s/\(posedge clka\)/clka/g;
        $_ =~ s/\(posedge CLKB\)/CLKB/g;
        $_ =~ s/\(posedge clkb\)/clkb/g;
	printf OUTPUT "%s",$_;
    }
#
# The following code removes the first COND statement from SETUP constraints
# which are used for contention checking in dual-port memories and 2 port
# register files.
#
    elsif ( (@var[0] eq "(SETUP") &&
	    (@var[1] eq "(COND") &&
	    ((@var[4] eq "CLKA))") || (@var[4] eq "CLKB))") || (@var[4] eq "clka))") || (@var[4] eq "clkb))"))){
	@var[4] =~ s/\)\)/\)/g;
	printf OUTPUT "    %s %s %s %s %s %s %s %s\n",@var[0],@var[3],@var[4],@var[5],@var[6],@var[7],@var[8],@var[9];
    }
    else {
        if ($inDelay==1 && $inAbsolute==1 && /^\s*\)\s*$/) {
            foreach $key (keys %ten_posedge_r ) {
                @key_split=split('_', $key);
                #Extract the IN and OUT pins for IOPATH
                $inpin=$key_split[0];
                $outpin=$key_split[1];
                @posedge_val_r=split(':', $ten_posedge_r{$key});
                @posedge_val_f=split(':', $ten_posedge_f{$key});
                @negedge_val_r=split(':', $ten_negedge_r{$key});
                @negedge_val_f=split(':', $ten_negedge_f{$key});
                printf OUTPUT "    (IOPATH %s %s (%.3f:%.3f:%.3f) (%.3f:%.3f:%.3f))\n", $inpin, $outpin, &max($posedge_val_r[0],$negedge_val_r[0]),  &max($posedge_val_r[1], $negedge_val_r[1]), &max($posedge_val_r[2], $negedge_val_r[2]), &max($posedge_val_f[0], $negedge_val_f[0]),  &max($posedge_val_f[1], $negedge_val_f[1]), &max($posedge_val_f[2], $negedge_val_f[2]);
            }
            foreach $key (keys %ben_posedge_r ) {
                @key_split=split('_', $key);
                $inpin=$key_split[0];
                $outpin=$key_split[1];
                @posedge_val_r=split(':', $ben_posedge_r{$key});
                @posedge_val_f=split(':', $ben_posedge_f{$key});
                @negedge_val_r=split(':', $ben_negedge_r{$key});
                @negedge_val_f=split(':', $ben_negedge_f{$key});
                printf OUTPUT "    (IOPATH %s %s (%.3f:%.3f:%.3f) (%.3f:%.3f:%.3f))\n", $inpin, $outpin, &max($posedge_val_r[0],$negedge_val_r[0]),  &max($posedge_val_r[1], $negedge_val_r[1]), &max($posedge_val_r[2], $negedge_val_r[2]), &max($posedge_val_f[0], $negedge_val_f[0]),  &max($posedge_val_f[1], $negedge_val_f[1]), &max($posedge_val_f[2], $negedge_val_f[2]);
            }
            $inDelay=0;
            $inAbsolute=0;
            %ten_posedge_r=();
            %ten_posedge_f=();
            %ten_negedge_r=();
            %ten_negedge_f=();
            %ben_posedge_r=();
            %ben_posedge_f=();
            %ben_negedge_r=();
            %ben_negedge_f=();
        }
	printf OUTPUT "%s",$_;
    }
}	
