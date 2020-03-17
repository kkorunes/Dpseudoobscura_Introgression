#!/usr/bin/perl -w
#######################################################################
# Apply Tajima's Relative Rate Test described in Tajima 1993 to compare 
# the relative subsitition rates between each pair of lines, using
# the outgroup D. lowei.
#
# The variant file should be tab-delimited, generated with GATK's 
# VariantsToTable tool.
# 
# USAGE: perl pairwise_ratecomparison.pl input_VariantsToTable.txt 
#######################################################################
use strict;

my $variants = "$ARGV[0]";
my $regionStart;
my $regionEnd;
my $chrom;
if ($variants =~ /chr(.*)_/){
	$chrom = $1;
	print "working on chrom $chrom\n"; 
} else {
	print "trouble parsing boundaries for $variants\n";
}	
my $output = "chr$chrom"."_CompareRates.txt";
open (OUT, ">$output") or die "unable to open: $!\n"; 

open (VAR, "$variants") or die "file not found: $!\n";
my %snps; #foreach pairwise comparison, add a key. value = array (same-count, different-count)
my $header = (<VAR>);
my @columns = split /\s+/, $header;
my @names = @columns[ 4 .. $#columns];
my $nameCount = scalar(@names);
my $lowNum;
for (my $i = 1; $i <= $nameCount; $i++){
	my $number = ($i - 1);
	my $name = "$names[$number]";
	if ("$name" eq "lowei.GT"){
		$lowNum = $number;
		print "Found outgroup Lowei at GT column $number\n";
	}
}

foreach my $col(@names){
	foreach my $col2(@names){
		my $comparison = "$col"."-X-"."$col2";
		my @counts = (0,0);
		$snps{$comparison} = \@counts;
	}
}


while(<VAR>){
	chomp();
	my $line = $_;
	my @allFields = split /\s+/, $line;
	my @GTs = @allFields[ 4 .. $#allFields];
	my $length = scalar(@GTs);

	#Get the outgroup genotype:
	my $low;
	my $gtLow = "$GTs[$lowNum]";	
	if (($gtLow =~ /\./) || ($gtLow =~ /\*/)){  # skip where lowei is missing data
		next;
	}
 	my @lowAllele = split /[\|\/]/, $gtLow;	
	if ("$lowAllele[0]" eq "$lowAllele[1]"){
		$low = "$lowAllele[0]";
	} else {
		next; #skip the sites where lowei is heterozygous
	}

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
				my @gt1Alleles = split /[\|\/]/, $gt1;		
				my @gt2Alleles = split /[\|\/]/, $gt2;
				#only use the homozygous sites:
				if (("$gt1Alleles[0]" eq "$gt1Alleles[1]")&&("$gt2Alleles[0]" eq "$gt2Alleles[1]")){	
					if ("$gt1Alleles[0]" eq "$gt2Alleles[0]"){
						next;
					} 			
					#print "@gt1Alleles, @gt2Alleles\n";

					#now these GT1 and GT2 should both be homozygous and GT1 != GT2
					#Which one matches the outgroup?
					my $newm1 = 0;
					my $newm2 = 0;
					if ("$gt1Alleles[0]" eq "$low"){
						$newm2 = 1;
					}elsif ("$gt2Alleles[0]" eq "$low"){
						$newm1 = 1;
					} else {
						next;
					}
					#print "GTs: $gt1,$gt2, LOW: $low, m1=$newm1, m2=$newm2\n";
					my @get = @{$snps{$pair}};
					my $m1 = "$get[0]";
					my $m2 = "$get[1]";
					my @new = (($m1+$newm1),($m2+$newm2));	
					$snps{$pair} = \@new;
				}
			}
		}	
	}
}	
close(VAR);

print OUT "Line1\tLine2\tm1\tm2\tchisquared\n";
foreach my $pairwise (keys %snps){
	my $shortname1;
	my $shortname2;
	my @snpcounts = @{$snps{$pairwise}};
	my $m1 = "$snpcounts[0]";
	my $m2 = "$snpcounts[1]";
	#set up the chisquared test:
	my $chi2 = 0;
	if (($m1+$m2)>0){
		$chi2 = (($m1-$m2)**2)/($m1+$m2);
	}
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
	print OUT "$shortname1\t$shortname2\t$m1\t$m2\t$chi2\n";
}
close(OUT);
