#!/usr/bin/perl -w
########################################################################
# For the D. pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019:
#
# For each window in the input file:
# 	draw one pair Dper
# 	draw one pair Dpsebog
# 	draw 1 of each
#
# 	for each of the 3 pairs above, count segregating sites, and
# 	calculate relative mutation rate.
#
### USAGE: perl step6_forInput-DiffsAndRelativeRates.pl intergenciWindows_infoforIIM.txt
# where windows.txt is a tab-delimited file of "chr start-coord x1 x2 x3 dist1 dist2 dist3"
########################################################################
use strict;

my $input = "$ARGV[0]";
my $name;
if ($input =~ /(.*)\.txt/){
	$name = $1;
}
my $output = "$name"."_RatesForIIM.txt";
open (OUT, ">$output") or die "unable to open $!\n";
open (IN, "$input") or die "unable to open $!\n";
	
my @all = ();
my @allR1 = ();
my @allR2 = ();
my @allR3 = ();
my $counted = 0;
while(<IN>) {
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $dist1 = "$fields[5]"; #this is the avg dist for Dper-Dmir over this window		
	my $dist2 = "$fields[6]";	# dbog-dmir	
	my $dist3 = "$fields[7]";	#dper/dbog - dmir	
	my $avgDist = (($dist1 + $dist2 + $dist3)/3); # add dists and divide by 3. will divide by the avg across all loci to get the relative rate
	push(@all, $avgDist);
	push(@allR1, $dist1);
	push(@allR2, $dist2);
	push(@allR3, $dist3);
	$counted++;
}
close(IN);

#Now use the avg of all loci to get the relative rates
my $avgAll = avg(\@all);
my $avgR1 = avg(\@allR1);
my $avgR2 = avg(\@allR2);
my $avgR3 = avg(\@allR3);
print "Found avg dist of $avgAll over $counted loci\n";
open (IN, "$input") or die "unable to open $!\n";
while(<IN>) {
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $key = "$fields[0]";
	my $start = "$fields[1]";
	my $dperCount = "$fields[2]";
	my $dbogCount = "$fields[3]";
	my $bothCount = "$fields[4]";
	my $dist1 = "$fields[5]"; #this is the avg dist for Dper-outgroup over this window		
	my $dist2 = "$fields[6]";	# dbog-outgroup	
	my $dist3 = "$fields[7]";	#dper/dbog (drew 1 of each) to outgroup	
	# add dists and divide by 3. 
	my $avgDist = (($dist1 + $dist2 + $dist3)/3);
	#divide by the avg across all loci to get the relative rate
	my $rel = ($avgDist/$avgAll);
	my $r1 = ($dist1/$avgR1);
	my $r2 = ($dist2/$avgR2);
	my $r3 = ($dist3/$avgR3);
	print OUT "$key\t$start\t$dperCount\t$dbogCount\t$bothCount\t$r1\t$r2\t$r3\t$rel\n";					
}
close(IN);
close (OUT);
exit;


#############################################################################
sub compare {
	my $concat = shift;
	my @compare = split /[\|\/]/, $concat;

	my @keep;
	foreach my $rawGT (@compare){
		if (($rawGT =~ /\./) || ($rawGT =~ /\*/)){
			next;
		} else {
			push (@keep, $rawGT);
		}
	}
	my $seg = 0;
	if (scalar @keep > 1){
		my $val1 = "$keep[0]";
		foreach my $val (@keep){
			if ($val eq "$val1"){
				next;
			} else {
				$seg = 1;
			}
		}
	}
	return $seg;
}

sub avg {
	my @vals = @{$_[0]};
	my $length = (scalar @vals);
	my $sum = 0;
	foreach my $val (@vals){
		$sum = ($sum + $val);
	}
	my $avg = 0;
	if ($length > 0){
		$avg = $sum/$length	
	}
	#print "averaged @vals \t to get $avg\n";
	return $avg;
}
