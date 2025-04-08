#!/usr/bin/perl
# -*- perl -*- Forces EMacs to use perl-mode 

use Getopt::Std; 

&getopts('s:o:');
if(!$opt_s || !$opt_o) {
    die "
pt_postprocessor.pl  -s <input SDF file>
                     -o <output SFD file>

This perl script modifes an SDF file created by Synopsys PrimeTime.  
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

#set the following variable to 1 to suppress negative delays in the
#interconnect section of sdf

$RUNNING_INTERNAL_QA = 0;


%bmux=();
open(INPUT, $IN_FILE) || 
    die printf("Sorry, Could not open file %s\n",$IN_FILE);

open(OUTPUT, ">" . $OUT_FILE) ||
    die printf("Sorry, Could not open file %s\n",$OUT_FILE);

# this list describes the valid IOPATHS for each cell that has conditional
# path delays.  All COND IOPATHS are not modified.

%cells = (
	  XOR2 => {
	      inputs => "",
	      outputs=> ""
	      },
          CLKXOR2 => {
              inputs => "",
              outputs=> ""
              },
	  XNOR2 => {
	      inputs => "",
	      outputs=> ""
	      },
	  XOR3 => {
	      inputs => "",
	      outputs=> ""
	      },
	  XNOR3 => {
	      inputs => "",
	      outputs=> ""
	      },
	  MX2 => {
	      inputs => "A B",
	      outputs=> "Y Y"
	      },
	  CLKMX2 => {
	      inputs => "A B",
	      outputs=> "Y Y"
	      },
	  MXI2 => {
	      inputs => "A B",
	      outputs=> "Y Y"
	      },
	  MX3 => {
	      inputs => "A B C",
	      outputs=> "Y Y Y"
	      },
	  MXI3 => {
	      inputs => "A B C",
	      outputs=> "Y Y Y"
	      },
	  MX4 => {
	      inputs => "A B C D",
	      outputs=> "Y Y Y Y"
	      },
	  MXI4 => {
	      inputs => "A B C D",
	      outputs=> "Y Y Y Y"
	      },
	  ADDH => {
	      inputs => "A B",
	      outputs=> "CO CO"
	      },
	  ADDF => {
	      inputs => "CI",
	      outputs=> "CO"
	      },
	  ADDFH => {
	      inputs => "CI",
	      outputs=> "CO"
	      },
	  ACHCIN => {
	      inputs => "CIN",
	      outputs=> "CO"
	      },
	  ACHCON => {
	      inputs => "CI",
	      outputs=> "CON"
	      },
	  AFHCIN => {
	      inputs => "CIN",
	      outputs=> "CO"
	      },
	  AFHCON => {
	      inputs => "CI",
	      outputs=> "CON"
	      },
	  AHHCIN => {
	      inputs => "A CIN",
	      outputs=> "CO CO"
	      },
	  AHCSHCIN => {
	      inputs => "A CIN",
	      outputs=> "CO CO"
	      },
	  AHCSHCON => {
	      inputs => "A CI",
	      outputs=> "CON CON"
	      },
	  AHHCON => {
	      inputs => "A CI",
	      outputs=> "CON CON"
	      },
	  CMPR22 => {
	      inputs => "A B",
	      outputs=> "CO CO"
	      },
	  CMPR32 => {
	      inputs => "C",
	      outputs=> "CO"
	      },
	  BENC => {
	      inputs => "M0 M1 M2 M0 M1 M2",
	      outputs=> "S S S A A A"
	      },
	  AFCSHCIN => {
	      inputs => "CI0N CI1N",
	      outputs=> "CO0 CO1"
	      },      
	  AFCSHCON => {
	      inputs => "CI0 CI1",
	      outputs=> "CO0N CO1N"
	      },      
	  AFCSIHCON => {
	      inputs => "A A B B CS",
	      outputs=> "CO0N CO1N CO0N CO1N S"
	      },      
	  ACCSHCIN => {
	      inputs => "CI0N CI1N",
	      outputs=> "CO0 CO1"
	      },      
	  ACCSHCON => {
	      inputs => "CI0 CI1",
	      outputs=> "CO0N CO1N"
	      },      
	  BMX => {
	      inputs => "",
	      outputs=> ""
	      },      
	  BMXI => {
	      inputs => "",
	      outputs=> ""
	      },      
	  CMPR42 => {
	      inputs => "C D ICI",
	      outputs=> "ICO CO CO"
	      }      
	  );

$inDelay=0;
$inAbsolute=0;
while (<INPUT>) {
    chop;
    @var = split;
#
# The following code strips out the unnecessary IOPATHS that are created by
# PrimeTime for cells with conditional path delays
#
    if (@var[0] eq "(DELAY"){
        $inDelay=1;
    }
    if (@var[0] eq "(ABSOLUTE"){
        $inAbsolute=1;
    }
    if (@var[0] eq "(INTERCONNECT"){
	#suppress the negative delays
	if( $RUNNING_INTERNAL_QA = 1 ){
	    $_=~s/\-([0-9]+\.[0-9]+e\-[0-9]+|[0-9]+\.[0-9]+|[0-9]+)/0.000/g;
	}
    }
    if (@var[0] eq "(CELLTYPE"){
	$cell_name = @var[1];
	$cell_name =~ s/[\"\)]//g;
# Took out the removal of _core as it is tools responsibility to put correct CELLTYPE.
# We are not changing the SDF if that occurs.
	#$_=~s/[_]core//g;
	foreach $key (keys %cells){
	    if (@var[1] =~ /^\"$key[X][L0-9]/){
		$in_cell = 1;
		$cell_type = $key;
	    }
	}
	printf OUTPUT "%s\n",$_;
    }
    elsif ( $in_cell ){
	if (@var[0] eq "(IOPATH"){
	    @inputs = split(/ /,$cells{$cell_type}{inputs});
	    @outputs = split(/ /,$cells{$cell_type}{outputs});
	    for ($i=0; $i<=$#inputs; $i++){
		if ((@var[1] eq @inputs[$i]) && (@var[2] eq @outputs[$i])){
		    printf OUTPUT "%s\n",$_;
		}
	    }
	}
	elsif (@var[0] eq "(IOPATH"){
	}
	elsif (@var[0] eq ")") {
	    $in_cell = 0;
	    printf OUTPUT "%s\n",$_;
	}
	else {
	    printf OUTPUT "%s\n",$_;
	}
    }
#
# The following code removes the posedge and negedge statements that are mysteriously
# inserted in the IOPATH section of sequential cells
#
    elsif (($cell_name =~ /^(RF[12]R[12]W|DFF|EDFF|MDFF|JKFF|SDFF|SDRFF|SEDFF|SMDFF|TLAT|TTLAT|RSLAT|LAT|M2DFF|M2SDFF|A2DFF|A2SDFF|ESDFF|EDFF|RLAT|DRFF|SDRFF|A2DRFF|A2SDRFF|M2DRFF|M2SDRFF|EDRFF|ESDRFF)/) && 
	   (@var[0] eq "(IOPATH" || @var[2] eq "(IOPATH") && ($_ =~ /edge/) ){
	$_ =~ s/\(POSEDGE //i;
	$_ =~ s/\(NEGEDGE //i;
	$_ =~ s/\)//;
	printf OUTPUT "%s\n",$_;
    }
#
# The following code removes the word "core" that mysteriously appears in the SDF
# It also strips out the escaped [ and ] that appears in the INTERCONNECT statement
#
    elsif (@var[0] eq "(INTERCONNECT") {
# Took out the removal of core, we are not fixing for the tools errors as this is deleting real
# Data, when customer have intentionally names having core. BZ: 16262
        #$_=~s/[\/]core//g;
        $_=~s/\\\[/\[/g;
        $_=~s/\\\]/\]/g;
        printf OUTPUT "%s\n",$_;
    }
    elsif (@var[0] eq "(INSTANCE") {
# Took out the removal of core, we are not fixing for the tools errors as this is deleting real
# Data, when customer have intentionally names having core. BZ: 16262
        #$_=~s/[\/]core//g;
        printf OUTPUT "%s\n",$_;
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
# The following code removes the posedge statements that are mysteriously
# inserted in the IOPATH section of memories.  It also removes the escaped character
# from bus pins.
#
    elsif ( ($_ =~ /IOPATH/) && ($_ =~ /posedge/) ){
	$_=~s/\\\[/\[/g;
	$_=~s/\\\]/\]/g;
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
	printf OUTPUT "%s\n",$_;
    }
    #
    # The following code prints out both posedge and negedge statements after
    # Design Compiler combined them because they are the same.
    #
    elsif ( ((@var[0] eq "(SETUP") || (@var[0] eq "(HOLD")) && 
	    ((@var[2] eq "(posedge") || (@var[2] eq "(negedge")) ){
	@var[1]=~s/\\\[/\[/g;
	@var[1]=~s/\\\]/\]/g;
	printf OUTPUT "    %s (posedge %s) %s %s %s\n",@var[0],@var[1],@var[2],@var[3],@var[4];
	printf OUTPUT "    %s (negedge %s) %s %s %s\n",@var[0],@var[1],@var[2],@var[3],@var[4];
    }
    else{
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
	$_=~s/\\\[/\[/g;
	$_=~s/\\\]/\]/g;
	printf OUTPUT "%s\n",$_;
    }
}
