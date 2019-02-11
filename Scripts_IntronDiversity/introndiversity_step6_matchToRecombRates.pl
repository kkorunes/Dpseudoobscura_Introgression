#!/usr/bin/perl -w
#######################################################################################
#
# Match four fold degenerate site pi for each gene to the recombination rate
# for that gene
# 
#
# USAGE: perl klk_matchToRecombRates.pl intronpifile RecRateFile gene_span_starts.txt
#
# #######################################################################################
use strict;

my $introndata = "$ARGV[0]";
my $recdata = "$ARGV[1]";
my $starts = "$ARGV[2]";
my $chr;
if ($recdata =~ /recombmap_chr(.*?)_byBIN/){
	$chr = $1;
} else {
	print "trouble parsing name of $introndata\n";
}
		
#store tab-delimited: chr gene intron# avg_pi intron_length recombrate startPosition
my $output = "chr"."$chr"."_intronpi_and_recombrates\.txt";
open (OUT, ">$output") or die "file not found $!";
print OUT "CHR\tGENE\tAVG_PI\tPOSITIONS_COUNTED\tREC_RATE\tGENE_START\n";

my %recRates;
my $lastend = 0;
my $lastrec = 0;
open (STARTS, $starts) or die "unable to open $starts\n";
while (<STARTS>){
	chomp();
	my $line = $_;
	my @startfields = split /\s+/, $line;
	my $gene = "$startfields[0]";
	my $startchr = "$startfields[1]";
	my $genestart = "$startfields[2]";

	open (REC, $recdata) or die "file not found $!\n";
	while (<REC>){
		chomp();
		my $line = $_;
		my @recfields = split (/\s+/, $line);
		my $start = "$recfields[0]";
		my $end = "$recfields[1]";
		my $rate = "$recfields[2]";	
		if (($genestart >= $start) && ($genestart <= $end)){
			if (exists $recRates{$gene}){
				print "WARNING: multiple entries for $gene\n";
			} else {
				my @save = ($genestart, $rate);
				$recRates{$gene}=[@save];
			}
			last;
		}
		if (($genestart > $lastend) && ($genestart < $start)){
			my $avg = (($rate + $lastrec)/2);
			if (exists $recRates{$gene}){
				print "WARNING: multiple entries for $gene\n";
			} else {
				my @save = ($genestart, $avg);
				$recRates{$gene}=[@save];
			}
		}	
		$lastend = $end;
		$lastrec = $rate;
	}
	close(REC);
}
close (STARTS);
	

open (INTRON, $introndata) or die "file not found $!";
while (<INTRON>){
	chomp();
	my $line = $_;
	my @fields = split (/\s+/, $line);
	my $pichr = "$fields[0]";
	my $geneName = "$fields[1]";
	my $intronPi = "$fields[2]";	
	my $intronLen = "$fields[3]";
	my $recRate;
	my $start;
	if (exists ($recRates{$geneName})){
		my @saved = @{$recRates{$geneName}};
		$start = "$saved[0]";
		$recRate = "$saved[1]";
	} else {
		print "missing rec data for $geneName\n";
		$start = "NA";
		$recRate = "NA";
		next;		
	}
	print OUT "$pichr\t$geneName\t$intronPi\t$intronLen\t$recRate\t$start\n";
}
close (INTRON);

close OUT;

exit;
