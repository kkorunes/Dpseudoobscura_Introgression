#!/usr/bin/perl -w
#####################################################################################
#
# A step in the process to get intronic pi for each gene.
# Use the list of longest transcripts to make sure we're using the introns for
# only one transcript (the longest) of each gene.
#
# USAGE: perl introndiversity_step2.pl All_Intron_Coords/ LongestTranscriptList
#
# ###################################################################################
use strict;

my $dir = "$ARGV[0]";
my $list = "$ARGV[1]";
my @positionsFiles = <$dir/*.txt>;

my %transcripts = ();
open (LIST, $list) or die "file not found: $!\n";
while (<LIST>){
	chomp();
	my $line = $_;
	my @names = split /\s+/, $line;
	my $gene = "$names[0]";
	my $transcript = "$names[1]";
	$transcripts{$transcript} = $gene;
}
close(LIST);

my $chr;
foreach my $positions (@positionsFiles){
	if ($positions =~ m/chr(.*)_dpse/){
		$chr = $1;
	} else {
		print "warning, couldn't identify chromosome for: $positions\n";
		next;
	}
	my $out;
	if ($positions =~ /(.*).txt/){
		my $filename = $1;
		$out = "$filename"."_longestIsoforms.txt";
	}
	open (OUT, ">$out") or die "file not found: $!\n";
	open (POS, $positions) or die "file not found:$!\n";
	while (<POS>){
		chomp();
		my $line = $_;
		my @fields = split /\s+/, $line;
		my $geneids = "$fields[0]";
		my @ids = split /,/, $geneids;
		my $keep = 1; #true/false, keep this intron or not
		foreach my $id (@ids){
			if (exists $transcripts{$id}){
				$keep = 0;
			}
		}
		if ($keep == 0){
			print OUT "$line\n";
		}
	}
	close(POS);
	close(OUT);
}

exit;
