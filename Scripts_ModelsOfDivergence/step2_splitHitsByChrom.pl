#!/usr/bin/perl -w
########################################################################
# For the D. pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019
# This script splits Dmir regions hit by Dpse genes by chromosome.
#
## USAGE: perl step2_splitbychrom.pl all-DmirHitByDpseGene.txt
########################################################################
use strict;

my $input = "$ARGV[0]";
my $id = $input;
if ($input =~ /(.*).txt/){
	$id = $1;
}
my $out2 = "chr2_$id.txt";
my $out3 = "chr3_$id.txt";
my $out4 = "chr4_$id.txt";
my $outXL = "chrXL_$id.txt";
my $outXR = "chrXR_$id.txt";
my $outOther = "chrOther_$id.txt";


open (IN, $input) or die "file not found: $!\n";
open (OUT2, ">$out2");
open (OUT3, ">$out3");
open (OUT4, ">$out4");
open (OUTXL, ">$outXL");
open (OUTXR, ">$outXR");
open (OUTOTHER, ">$outOther");

while(<IN>) {
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $chr = "$fields[0]";
	#Print to appropriate output file:
	if ($chr =~ /NC_030304\.1/){
		print OUT2 "$line\n";
	}
	elsif ($chr =~ /NC_030305\.1/){
                print OUT3 "$line\n";
	}
	elsif ($chr =~ /NC_030306\.1/){
                print OUT4 "$line\n";
	}
	elsif ($chr =~ /NC_030302\.1/){
                print OUTXL "$line\n";
	}
	elsif ($chr =~ /NC_030303\.1/){
                print OUTXR "$line\n";
	}
	else{
		print OUTOTHER "$line\n";
	}
}

close(IN);
close(OUT2);
close(OUT3);
close(OUT4);
close(OUTXL);
close(OUTXR);
close(OUTOTHER);
print "Done splitting file by chromosomes\n";

exit;
