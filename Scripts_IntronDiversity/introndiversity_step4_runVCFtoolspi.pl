#!/usr/bin/perl -w
##############################################################################################
#
# A step in the process to get intronic pi for each gene.
# Runs vcftools --site-pi to get pi for each set of intron positions
#
# USAGE: perl introndiversity_step3_runVCFtoolspi.pl Intron_Coords_LongestIsoformOnly_Short/
#
# ############################################################################################
use strict;

my $dir = "$ARGV[0]";
my @positionsFiles = <$dir/*.txt>;

my $chr;
foreach my $positions (@positionsFiles){
	if ($positions =~ m/chr(.*)_dpse/){
		$chr = $1;
	} else {
		print "warning, couldn't identify chromosome for: $positions\n";
		next;
	}
	my $counter = 0;
	open (POS, $positions) or die "file not found:$!\n";
	while (<POS>){
		chomp();
		my $line = $_;
		my @fields = split /\s+/, $line;
		my $name = "$fields[0]";
		my @names = split /,/, $name;
		my $gene = "$names[0]";
		my $start = "$fields[2]";
		my $end = "$fields[3]";
		my $trimStart = $start+10;
		my $trimEnd = $end-10;
		$counter++;
		#use vcftools to get pi per site
		my $runscript = "$gene"."_$start".".sh";
		my $output = "chr"."$chr"."_$gene".",$counter"."intron"."$start"."_pi.txt";
		open (RUN, ">$runscript") or die "file not found $!";
		print RUN "#!/bin/bash\n";
		print RUN "#SBATCH --mem=30GB\n";
		print RUN "cd /datacommons/noor2/klk37/BackgroundSelection/intron_nucleotide_diversity_DPSE\n";
		print RUN "/opt/apps/rhel7/vcftools-0.1.17/bin/vcftools --vcf genotyped_RemovedFilteredSites_DPSEONLY.recode.vcf --site-pi --chr $chr --from-bp $trimStart --to-bp $trimEnd --out $output\n";
		close (RUN);
		system("sbatch $runscript"); 
	}
	close(POS);
}


exit;
