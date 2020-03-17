#!/usr/bin/perl -w
###################################################################################################
# Wrapper to run "pairwise_dxy.pl" over a directory of depth files (split by region).
#
# USAGE: perl run_pairwise_dxy chr_variantstoTable Chr_depth_folder/
#
# #################################################################################################
use strict;

my $var = "$ARGV[0]";
my @files = <"$ARGV[1]"/*txt>;

my $chr;
my $region;
foreach my $file (@files){
	if ($file =~ /\/All_depths_matrix_chr(.*?)_(\d+).txt/){
		$chr = $1;
		$region = $2;
	} else {
		print "warning, couldn't identify chromosome for: $file\n";
		next;
	}

	#use vcftools to get pi per site
	my $runscript = "run_chr$chr"."_$region".".sh";
	print "$runscript\n";
	open (RUN, ">$runscript") or die "file not found $!\n";
	print RUN "#!/bin/bash\n";
	print RUN "#SBATCH --mem=20GB\n";
	print RUN "#SBATCH -p noor\n";
	print RUN "cd /datacommons/noor/klk37/introgression/Pairwise_Dxy\n";
	print RUN "perl pairwise_dxy.pl $var $file\n";
	close (RUN);
	system("sbatch $runscript"); 
}


exit;
