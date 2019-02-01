#!/bin/bash
#SBATCH --mem=40GB
cd /datacommons/noor/klk37/introgression/

BAMs=*piped.bam
for BAM in $BAMs
do
	#name="$(echo ${R1} | awk -F'[_' '{print $1}')"
	name="$(echo ${BAM} | grep -oP '.*(?=_piped.bam)')"
	echo "working on $name"
	OUT="$name"_dedup_reads.bam
	MET="$name"_dedup_metrics.txt
	/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -jar /datacommons/noor/klk37/picard.jar MarkDuplicates \
		INPUT=$BAM \
		OUTPUT=$OUT \
		METRICS_FILE=$MET
	/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -jar /datacommons/noor/klk37/picard.jar BuildBamIndex \
		INPUT=$OUT
done
