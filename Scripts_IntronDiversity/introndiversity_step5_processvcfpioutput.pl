#!/usr/bin/perl -w
#################################################################
#
# A step in the process to get intronic pi for each gene.
# uses the output from the previous step (running  
# vcftools --site-pi) factor on the invariant positions 
# (positions not in the vcf files) and get avg pi across
# all sites in each intron
#
# USAGE: perl processvcfoutput_getpi.pl vcfoutputdir/ chr#
#
# ##############################################################
use strict;

my $vcfdir = "$ARGV[0]";
my $chr = "$ARGV[1]";
my @piFiles = <$vcfdir/*_pi.txt.sites.pi>;

#store tab-delimited: gene intron# avg_pi intron_length
my $output = "chr"."$ARGV[1]"."intronpi\.txt";
open (OUT, ">$output") or die "file not found $!";

my %genes;

my $geneID;
my $intronstart;
foreach my $pi_file (@piFiles){
	#count the number of positions
	my $position_count = 0;
	my $pi_sum = 0;
	if ($pi_file =~ m/FB(.*)intron(.*?)_pi/){
		my $id = $1;
		$intronstart = $2;
		my @names = split /,/, $id;
		$geneID = "FB"."$names[0]";
		#print "File: $pi_file\nStart: $intronstart\nGene: $geneID\n";
	} else {
		print "had trouble parsing names: $pi_file\n";
		next;
	}	
	open (PI, $pi_file) or die "file not found $!\n";
	while (<PI>){
		my $line = $_;
		if (($line =~ m/^CHROM/)||($line =~ /nan/)){
			#header, so skip
			next;
		} else {
			$position_count++;
			my @fields = split (/\s+/, $line);
			my $pi = $fields[2];
			#print "$pi\n";
			$pi_sum = ($pi_sum + $pi);
		}
	}
	close (PI);

	#see if there's already an intron stored for this gene
	if (exists $genes{$geneID}){
		#add this data to the already stored data
		my @savedinfo = @{$genes{$geneID}};
		my $newpi = ("$savedinfo[0]" + $pi_sum);
		my $newpositions = ("$savedinfo[1]" + $position_count);
		my @newinfo = ($newpi, $newpositions);
		$genes{$geneID} = \@newinfo;
	} else{
		my @piposition = ($pi_sum, $position_count);
		$genes{$geneID} = \@piposition;
	}
}	
foreach my $key (keys %genes){
	my @totals = @{$genes{$key}};
	my $pi_total = "$totals[0]";
	my $position_total = "$totals[1]";
	#now get avg pi from all sites
	my $avg_pi;
	if ($pi_total == 0){
		$avg_pi = 0;
	} else {
		$avg_pi = ($pi_total/$position_total);
	}
	#output: chr gene intron# avg_pi intron_length
	print OUT "$chr\t$key\t$avg_pi\t$position_total\n";
}
close OUT;

exit;
