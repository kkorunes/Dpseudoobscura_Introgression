#!/usr/bin/perl -w
##########################################################
#  Parse out Flybase CDSs by chromosome
# perl parsebychrom.pl input-all-intron.fasta
##########################################################
use strict;
use Bio::SeqIO;

my $input = "$ARGV[0]";
my $id = $input;
if ($input =~ /(.*).fasta/){
	$id = $1;
}
my $out = "chr2_$id.txt";
my $out2 = "chr3_$id.txt";
my $out3 = "chr4_group1_$id.txt";
my $out4 = "chr4_group2_$id.txt";
my $out5 = "chr4_group3_$id.txt";
my $out6 = "chr4_group4_$id.txt";
my $out7 = "chr4_group5_$id.txt";
my $out8 = "chrXL_group1a_$id.txt";
my $out9 = "chrXL_group1e_$id.txt";
my $out10 = "chrXL_group3a_$id.txt";
my $out11 = "chrXL_group3b_$id.txt";
my $out12 = "chrXR_group3a_$id.txt";
my $out13 = "chrXR_group5_$id.txt";
my $out14 = "chrXR_group6_$id.txt";
my $out15 = "chrXR_group8_$id.txt";
my $out16 = "chrUnknown_$id.txt";

open (OUT, ">$out");
open (OUT2, ">$out2");
open (OUT3, ">$out3");
open (OUT4, ">$out4");
open (OUT5, ">$out5");
open (OUT6, ">$out6");
open (OUT7, ">$out7");
open (OUT8, ">$out8");
open (OUT9, ">$out9");
open (OUT10, ">$out10");
open (OUT11, ">$out11");
open (OUT12, ">$out12");
open (OUT13, ">$out13");
open (OUT14, ">$out14");
open (OUT15, ">$out15");
open (OUT16, ">$out16");

my $seqio = Bio::SeqIO->new(-file => $input, '-format' => 'Fasta');
while(my $seq = $seqio->next_seq) {
	my $chr = "unknown";
	my $length = 0;
	my $start;
	my $stop;
	my $comp = "na"; #Is it on the complementary strand?
	my $gene;
	my $name = $seq->id;
	my $sequence = $seq->seq;  
	my $desc = $seq->desc; 
	if ($desc =~ /.*loc=(.*):(\d+)..(\d+);/){
		$chr = $1;
		$start = $2;
		$stop = $3;
        } elsif ($desc =~ /.*loc=(.*):complement\((\d+)..(\d+)\);/){
		$chr = $1;
		$start = $2;
		$stop = $3;
		$comp = "complementary";
	} else {
               	print "couldn't find chromosome for $name\n";
               	next;}
	if ($desc =~ /.*length=(\d+);.*/){
		$length = $1;
	} else {
		print "couldn't fine length for $name\n";
		next;}	
	if ($desc =~ /^.*parent=(.*?);\s/){
		$gene = $1;
	} else {
		print "couldn't find gene and/or transcript name for $desc\n";
	}
	#Print to appropriate output file:
	if ($chr eq 2){
		print OUT "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
		}
	elsif ($chr eq 3){
                print OUT2 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "4_group1"){
		print OUT3 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
		}
	elsif ($chr eq "4_group2"){
                print OUT4 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "4_group3"){
                print OUT5 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "4_group4"){
                print OUT6 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "4_group5"){
                print OUT7 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XL_group1a"){
                print OUT8 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XL_group1e"){
                print OUT9 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XL_group3a"){
                print OUT10 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XL_group3b"){
                print OUT11 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XR_group3a"){
                print OUT12 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XR_group5"){
                print OUT13 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XR_group6"){
                print OUT14 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	elsif ($chr eq "XR_group8"){
                print OUT15 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
                }
	else{
		print OUT16 "$gene\t$chr\t$start\t$stop\t$length\t$comp\n";
		}
}
print "Done splitting file by chromosomes\n";

exit;
