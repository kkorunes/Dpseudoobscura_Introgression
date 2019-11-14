#!/usr/bin/perl -w
########################################################################
# For the D. pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019:
# This script finds 500bp intergenic sequences spaced at least 2kb apart.
#
### USAGE: perl step3_identifyIntergenic.pl all-DmirHitByDpseGene.txt
########################################################################
use strict;

my $input = "$ARGV[0]";
my $id = $input;
if ($input =~ /(.*).txt/){
	$id = $1;
}
my $in2 = "chr2_$id.txt";
my $in3 = "chr3_$id.txt";
my $in4 = "chr4_$id.txt";
my $inXL = "chrXL_$id.txt";
my $inXR = "chrXR_$id.txt";
my @chrIn = ($in2, $in4, $inXL, $inXR);

foreach my $in (@chrIn){
	open (IN, $in) or die "file not found: $!\n";
	my $chr;
	if ($in =~ /(.*)_/){
		$chr = $1;
	}
	my $out = "intergenic_coords_$chr".".txt";
	open (OUT, ">$out");
	
	my %genic; #store all the coords that matched genes
	while(<IN>) {
		chomp();
		my $line = $_;
		my @fields = split /\s+/, $line;
		my $start;
		my $end;
		my $coord1 = "$fields[1]";
		my $coord2 = "$fields[2]";
		if ($coord1 > $coord2){
			$start = $coord2;
			$end = $coord1;
		}else{
			$start = $coord1;
			$end = $coord2;
		}
		for (my $i = $start; $i <= $end; $i++){
			$genic{$i} = 0; #add this coord to the hash of coords to avoid
		}
	}
	close(IN);

	#now walk through 500bp windows and avoid any that overlap with %genic
	# Total assembly lengths:
	my $length;
	my $genicWindows = 0;	
	my $intergenicWindows = 0;
	if ($chr =~ /XL/){
		$length = 22123056;
	} elsif ($chr =~ /XR/){
		$length = 30136903;
	} elsif ($chr =~ /2/){
		$length = 33007066;
	} elsif ($chr =~ /3/){
		$length = 20862834;
	} elsif ($chr =~ /4/){
		$length = 28826359;
	} else {
		print "warning: trouble matching $chr\n";
	}
	print "searching $chr of length $length\n";

	my $lastEnd = 0; #make sure windows are 2kb apart
	for (my $s = 1; $s < ($length - 500); $s += 500){
		my $e = ($s + 499); #end of the window
		if (($s - $lastEnd) < 2000){ #windows should be at least 2kb apart
			next;
		} 
		my $overlap = 0; #overlap = false
		for (my $x = $s; $x <= $e; $x++){
			if (exists $genic{$x}){ #this coord in the window could be in a gene
				$overlap = 1;
			}
		}
		if ($overlap == 0) { #no coords in genes
			$intergenicWindows++;
			$lastEnd = $e; #the next window should be >=2kb from here
			print OUT "$chr\t$s\t$e\n";
		} else {
			$genicWindows++;
		}

	}
	print "found $intergenicWindows intergenic windows and $genicWindows genic windows\n";
	close(OUT);
}	

exit;
