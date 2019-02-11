#!/bin/bash
# Use only introns that are less than 100bp

cd /datacommons/noor2/klk37/BackgroundSelection/intron_nucleotide_diversity/Intron_Coords_LongestIsoformsOnly/

FILES=*.txt
for file in $FILES
do 
	name="$(echo ${file} | grep -oP '.*(?=.txt)')"
	out="$name"_short-100bp.txt	
	awk '$5 < 100' $file > $out
done
