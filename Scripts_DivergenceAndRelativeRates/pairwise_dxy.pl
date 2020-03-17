#!/usr/bin/perl -w
#######################################################################
# After building the matrix of depths for each line at each position, 
# calculate pairwise divergence between each pair of lines.
#
# The variant file should be tab-delimited, generated with GATK's 
# VariantsToTable tool.
# 
# USAGE: perl pairwise_dxy.pl input_VariantsToTable.txt depthfile
use strict;

my $variants = "$ARGV[0]";
my $depths = "$ARGV[1]";
my $regionStart;
my $regionEnd;
my $chrom;
if ($depths =~ /chr(.*)_(\d+).txt/){
	$chrom = $1;
	$regionEnd = ($2 * 500000);
	$regionStart = ($regionEnd - 500000);
	print "working on $depths, chrom $chrom from $regionStart to $regionEnd\n"; 
} else {
	print "trouble parsing boundaries for $depths\n";
}	
my $output = "chr$chrom"."_$regionStart"."-$regionEnd"."_divergence.txt";
open (OUT, ">$output") or die "unable to open: $!\n"; 

open (VAR, "$variants") or die "file not found: $!\n";
my %snps; #foreach pairwise comparison, add a key. value = array (same-count, different-count)
my $header = (<VAR>);
my @columns = split /\s+/, $header;
my @names = @columns[ 4 .. $#columns];
foreach my $col(@names){
	foreach my $col2(@names){
		my $comparison = "$col"."-X-"."$col2";
		my @counts = (0,0);
		$snps{$comparison} = \@counts;
	}
}

my %positions; #keep track of whether positions are accounted for
while(<VAR>){
	chomp();
	my $line = $_;
	my @allFields = split /\s+/, $line;
	my $pos = "$allFields[1]";
	if (($pos <= $regionStart) || ($pos > $regionEnd)){
		next;
	}
	$positions{$pos} = 1; #this position exists in the filtered SNPS
	my @GTs = @allFields[ 4 .. $#allFields];
	my $length = scalar(@GTs);
	for (my $i = 1; $i <= $length; $i++){
		my $number = ($i - 1);
		my $gt1 = "$GTs[$number]";
		my $name1 = "$names[$number]";
		for (my $x = 1; $x <= $length; $x++){
			my $number2 = ($x -1);
			my $gt2 = "$GTs[$number2]";
			my $name2 = "$names[$number2]";
			my $pair = "$name1"."-X-"."$name2";
			if (($gt1 =~ /\./) || ($gt2 =~ /\./) || ($gt1 =~ /\*/) || ($gt2 =~ /\*/)){  #missing data
				next;
			} else {
				my @get = @{$snps{$pair}};
				my $same = "$get[0]";
				my $different = "$get[1]";
				my @gt1Alleles = split /\//, $gt1;		
				my @gt2Alleles = split /\//, $gt2;
				if ("$gt1" eq "$gt2"){
					$same = ($same + 1 );	
				} elsif ("$gt1Alleles[0]" eq "$gt1Alleles[1]"){		
					if ("$gt2Alleles[0]" eq "$gt2Alleles[1]"){ #both pairs are homozygous but different	
						$different = ($different + 1);	
					} elsif (("$gt1Alleles[0]" eq "$gt2Alleles[0]") || ("$gt1Alleles[0]" eq "$gt2Alleles[1]")){ #pair2 is het; half match to pair1
						$same = ($same + 0.5);
						$different = ($different + 0.5);
					} else { #pair2 is het, neither allele matches pair1
						$different = ($different + 1);
					}
				} elsif (("$gt1Alleles[0]" eq "$gt2Alleles[0]") || ("$gt1Alleles[1]" eq "$gt2Alleles[0]")){ #pair1 is het; half match to pair2
					$same = ($same + 0.5);
					$different = ($different + 0.5);
				} elsif (("$gt1Alleles[0]" eq "$gt2Alleles[1]") || ("$gt1Alleles[1]" eq "$gt2Alleles[1]")){ #check the 2nd half to pair2
					$same = ($same + 0.5);
					$different = ($different + 0.5);	
				} else {
					$different = ($different + 1);	
				}
				my @new = ($same,$different);	
				$snps{$pair} = \@new;
			}
		}	
	}
}	
close(VAR);

my %refdepth; #for non snps, count where both strains of a pair have data at 10x
open (DP, "$depths") or die "file not found: $!\n";
my $dpheader = (<DP>);
my @dpcols = split /\s+/, $dpheader;
my @dpnames = @dpcols[ 2 .. $#dpcols];
foreach my $dpcol(@dpnames){
	foreach my $dpcol2(@dpnames){
		my $comparison = "$dpcol"."-X-"."$dpcol2";
		$refdepth{$comparison} = 0; #sites where this pair has data
	}
}
while(<DP>){
	chomp();
	my $line = $_;
	my @dpFields = split /\s+/, $line;
	my $coord = "$dpFields[1]";
	if (exists $positions{$coord}){
		#already accounted for in variants file
		next;
	}
	my @dps = @dpFields[ 2 .. $#dpFields];
	my $dplength = scalar(@dps);
	for (my $i = 1; $i <= $dplength; $i++){
		my $num = ($i - 1);
		my $dp1 = "$dps[$num]";
		my $dpname1 = "$dpnames[$num]";
		for (my $x = 1; $x <= $dplength; $x++){
			my $num2 = ($x - 1);
			my $dp2 = "$dps[$num2]";
			my $dpname2 = "$dpnames[$num2]";
			my $pair = "$dpname1"."-X-"."$dpname2";
			#print "my numbers $num, $num2, have names $dpname1, $dpname2 - and depths $dp1, $dp2\n";
			if (($dp1 >= 10) && ($dp2 >= 10)){
				my $counted = $refdepth{$pair};
				my $newcount =($counted + 1);
				$refdepth{$pair} = $newcount;	
				#print "For $pair, depths passed: $dp1, $dp2. Counter from $counted to $newcount\n";
			}
		}
	}
}
close(DP);

print OUT "Line1\tLine2\tDIVERGENCE\tTOTALSITES\n";
foreach my $pairwise (keys %snps){
	my $shortname1;
	my $shortname2;
	my @snpcounts = @{$snps{$pairwise}};
	my $snpSame = "$snpcounts[0]";
	my $snpDiff = "$snpcounts[1]";
	if ($pairwise =~ /(.*).GT-X-(.*).GT/){
		$shortname1 = $1;
		$shortname2 = $2;
		if ($shortname1 =~ /SRA_(.*)/){
			$shortname1 = $1;
		}
		if ($shortname2 =~ /SRA_(.*)/){
			$shortname2 = $1;
		}
	}
	#use these names to find within the depth file header
	#print "$shortname1, $shortname2\n";
	my $refCount = 0;
	my $match = 0;
	foreach my $refkey (keys %refdepth){
		my $refname1;
		my $refname2;
		if ($refkey =~ /(.*).DP-X-(.*).DP/){
			$refname1 = $1;
			$refname2 = $2;
		} else {
			print "warning: trouble parsing $refkey\n";
		}
		if (($refname1 =~ /$shortname1/) && ($refname2 =~ /$shortname2/)){
			$refCount = $refdepth{$refkey};
			$match = 1;
		}
	}
	if ($match == 0){ 
		print "No corresponding pair in the reference depths for $pairwise\n";
		next;
	}

	my $shared = ($snpSame + $refCount);
	my $sites = ($snpDiff + $shared);
	my $d = ($snpDiff/$sites);
	print OUT "$shortname1\t$shortname2\t$d\t$sites\n";
}
close(OUT);
