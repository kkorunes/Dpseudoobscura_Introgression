#!/usr/bin/perl -w
########################################################################
# For the D. pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019:
#
# For each window in the input file:
# 	draw one pair Dper
# 	draw one pair Dpsebog
# 	draw 1 of each
#
# 	for each of the 3 pairs above, count segregating sites, and
# 	calculate relative mutation rate.
#
### USAGE: perl step4_forInput-DiffsAndRelativeRates.pl windows.txt
# where windows.txt is a tab-delimited file of "chr start-coord end-coord"
########################################################################
use strict;

my $input = "$ARGV[0]";
my $name;
if ($input =~ /(.*)\.txt/){
	$name = $1;
}
my $output = "$name"."_infoForIIM.txt";
open (OUT, ">$output") or die "unable to open $!\n";
open (IN, "$input") or die "unable to open $!\n";
	
my %collect2; #keep track of all the windows we want to find in chr2
my %collect4; #keep track of all the windows we want to find in chr4
my %collectXL; #keep track of all the windows we want to find in chrXL
my %collectXR; #keep track of all the windows we want to find in chrXR
my %collectChr;
while(<IN>) {
	chomp();
	my $line = $_;
	my @fields = split /\s+/, $line;
	my $chr = "$fields[0]";
	my $start = "$fields[1]";
	my $end = "$fields[2]";
	if ($chr =~ /2/){
		$collect2{$start} = $end;
	} elsif ($chr =~ /4/){
		$collect4{$start} = $end;
	} elsif ($chr =~ /XL/){
		$collectXL{$start} = $end;
	} elsif ($chr =~ /XR/){
		$collectXR{$start} = $end;
	} else {
		next;
	}
	$collectChr{$chr} = 0; #make sure this chr is in the hash of chromosome to search
}
close(IN);

foreach my $key (keys %collectChr){
	my $table = "$key"."_forIIM_VariantsToTable.txt"; 
	print "finding windows in $table\n";
	my %variants; #Match to the hash we want to look through
	if ($key =~ /2/){
		%variants = %collect2;
	} elsif ($key =~ /4/){
		%variants = %collect4;
	} elsif ($key =~ /XL/){
		%variants = %collectXL;
	} elsif ($key =~ /XR/){
		%variants = %collectXR;
	} else {
		next;
	}
	
	foreach my $start (keys %variants){
		my $end = $variants{$start};
		open (TABLE, "$table") or die "unable to open $!\n";
		my $header = <TABLE>;
		my @stash = ();
		my $last = 0;
		my $pos = 0;
		while(<TABLE>){
			chomp();
			my $line = $_;
			my @info = split /\s+/, $line;
			$pos = "$info[1]";
			if ($pos > $end){
				last;
			} elsif (($start >= $last) && ($start <= $pos)){
				push (@stash, $line); 
				while($pos < $end){
					my $nextline = <TABLE>;
					chomp($nextline);
					my @info = split /\s+/, $nextline;
					$pos = "$info[1]";
					push (@stash, $nextline);
				}
				last;
			}else{
				$last = $pos;
				next;
			}
		}
		close(TABLE);

		#Now we have the relevant chunk on file, collect stats
		my $dperCount = 0;
		my $dbogCount = 0;
		my $bothCount = 0;
		my @r1vals=();
		my @r2vals=();
		my @r3vals=();
		
		my $windowSize = $end - $start;
		my $checkL = (scalar @stash);
		#print "window $start - $end\n@stash\n";
		#print "variant sites in window: $checkL, window length $windowSize\n";
		foreach my $position (@stash){
			my @info = split /\s+/, $position;
			my $pos = "$info[1]";		
			my $out = "$info[16]";
			my $ref = "$info[2]";
			#Now calculate the needed stats from here to the end of the window
			#First, draw a pair from each species and a between spp pair
			my @dbogInd = (4,5,6,7);
			my @dperInd = (8,9,10,11,12,13,14,15);
			my @selectDper; #store 2 randomly picked Dper GTs
			my @selectDbog;
			for (1..2){
				push @selectDper, splice(@dperInd, int rand @dperInd, 1); #removes and returns, so we don't pick the same 1 twice
				push @selectDbog, splice(@dbogInd, int rand @dbogInd, 1);
			}
				
			my $dperInd1 = "$selectDper[0]"; #the index of the 1st random Dper pick
			my $dperInd2 = "$selectDper[1]"; #the index of the second random Dper pick
			my $dbogInd1 = "$selectDbog[0]";
			my $dbogInd2 = "$selectDbog[1]";
			my $dper1 = "$info[$dperInd1]";
			my $dper2 = "$info[$dperInd2]";
			my $dbog1 = "$info[$dbogInd1]";
			my $dbog2 = "$info[$dbogInd2]";
			my $concatDper = "$dper1"."\/$dper2";
			my $concatDbog = "$dbog1"."\/$dbog2";
			my $concatBoth = "$dbog1"."\/$dper1";
			
			my $dperSeg = compare($concatDper); #0 means segregating = false
			my $dbogSeg = compare($concatDbog); 
			my $bothSeg = compare($concatBoth); 	
			$dperCount = ($dperCount + $dperSeg);
			$dbogCount = ($dbogCount + $dbogSeg);
			$bothCount = ($bothCount + $bothSeg);

			#default to ref where lowei is heterozygous or missing
			my @checkOut = split /[\|\/]/, $out;
			my @keepOut;	
			foreach my $raw (@checkOut){
				if (($raw =~ /\./) || ($raw =~ /\*/)){
					next;
				} else {
					push (@keepOut, $raw);
				}
			}
			if ((scalar @keepOut) == 2){
				if ("$keepOut[0]" eq "$keepOut[1]"){
					my $outGT = "$keepOut[0]";
					my $dperOut = outgroup($outGT,$concatDper); #returns 0 if no diff; 1 if diff
					my $dbogOut = outgroup($outGT,$concatDbog);
					my $bothOut = outgroup($outGT,$concatBoth);
					push(@r1vals, $dperOut);
					push(@r2vals, $dbogOut);
					push(@r3vals, $bothOut);
					#print "lowei was $out, gts @keepOut, val saved for per $dperOut\n";
				} 
			} elsif ((scalar @keepOut) == 1){
				my $outGT = "$keepOut[0]";
				my $dperOut = outgroup($outGT,$concatDper);
				my $dbogOut = outgroup($outGT,$concatDbog);
				my $bothOut = outgroup($outGT,$concatBoth);
				push(@r1vals, $dperOut);
				push(@r2vals, $dbogOut);
				push(@r3vals, $bothOut);
			}else{	 
				my $outGT = "$ref";
				my $dperOut = outgroup($outGT,$concatDper);
				my $dbogOut = outgroup($outGT,$concatDbog);
				my $bothOut = outgroup($outGT,$concatBoth);
				push(@r1vals, $dperOut);
				push(@r2vals, $dbogOut);
				push(@r3vals, $bothOut);
			}
		}
		
		my $r1 = sum(\@r1vals);	
		my $r2 = sum(\@r2vals);	
		my $r3 = sum(\@r3vals);	
		my $r1avg = $r1/$windowSize;
		my $r2avg = $r2/$windowSize;
		my $r3avg = $r3/$windowSize;
		print OUT "$key\t$start\t$dperCount\t$dbogCount\t$bothCount\t$r1avg\t$r2avg\t$r3avg\n";
					
	}
}

close (OUT);
exit;


#############################################################################
sub compare {
	my $concat = shift;
	my @compare = split /[\|\/]/, $concat;

	my @keep;
	foreach my $rawGT (@compare){
		if (($rawGT =~ /\./) || ($rawGT =~ /\*/)){
			next;
		} else {
			push (@keep, $rawGT);
		}
	}
	my $seg = 0;
	if (scalar @keep > 1){
		my $val1 = "$keep[0]";
		foreach my $val (@keep){
			if ($val eq "$val1"){
				next;
			} else {
				$seg = 1;
			}
		}
	}
	#print "gts @compare; keep @keep; segregating = $seg\n";
	return $seg;
}

sub outgroup {
	my $ref = shift;
	my $concat = shift;
	my @compare = split /[\|\/]/, $concat;

	my @keep;
	foreach my $rawGT (@compare){
		if (($rawGT =~ /\./) || ($rawGT =~ /\*/)){
			next;
		} else {
			push (@keep, $rawGT);
		}
	}
	my $diffs = 0;
	my $counted = 0;
	if ((scalar @keep) > 0){	
		foreach my $val (@keep){
			$counted++;
			if ($val eq "$ref"){
				next;
			} else {
				$diffs++;
			}
		}
	}
	my $d = 0;
	if ($diffs > 0){
		$d=1;
	}	
	#print "ref:$ref, gts:$concat ...keeping @keep, diffs:$diffs, counted;$counted\n";
	return $d;
}


sub avg {
	my @vals = @{$_[0]};
	my $length = (scalar @vals);
	my $sum = 0;
	foreach my $val (@vals){
		$sum = ($sum + $val);
	}
	my $avg = 0;
	if ($length > 0){
		$avg = $sum/$length	
	}
	return $avg;
}

sub sum {
	my @vals = @{$_[0]};
	my $sum = 0;
	foreach my $val (@vals){
		$sum = ($sum + $val);
	}
	return $sum;
}
