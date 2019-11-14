#!/usr/bin/perl -w
########################################################################
# For the D.pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019:
## This script splits the intergenic regions into 2 non-overlapping sets of loci 
#
## USAGE: perl step4_randomlyDivide.pl intergenicWindows.txt
########################################################################
use strict;

my $input = "$ARGV[0]";
my $id = $input;
if ($input =~ /(.*).txt/){
	$id = $1;
}
my $out1 = "$id"."_set1.txt";
my $out2 = "$id"."_set2.txt";
my $out3 = "$id"."_set3.txt";


open (IN, $input) or die "file not found: $!\n";
open (OUT1, ">$out1");
open (OUT2, ">$out2");
open (OUT3, ">$out3");

my $counter = 1;
while(<IN>) {
	chomp();
	my $line = $_;
	print "$counter\n";
	if ($counter == 1){
		print OUT1 "$line\n";
	}
	elsif ($counter == 2){
                print OUT2 "$line\n";
	}
	elsif ($counter == 3){
                print OUT3 "$line\n";
		$counter=0;
	}
	$counter++;
}

close(IN);
close(OUT1);
close(OUT2);
close(OUT3);

print "Done splitting file\n";

exit;
