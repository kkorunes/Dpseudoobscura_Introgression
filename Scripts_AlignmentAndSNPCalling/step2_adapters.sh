#!/bin/bash
#SBATCH --mem=60GB
cd /datacommons/noor/klk37/introgression/ubams/

BAMs=*.bam
for BAM in $BAMs
do
	#name="$(echo ${R1} | awk -F'[_' '{print $1}')"
	name="$(echo ${BAM} | grep -oP '.*(?=_unaligned_read_pairs.bam)')"
	echo "working on $name"
	MET="$name"_mark_adapters_metrics.txt
	OUT="$name"_markadapters.bam
	/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -Xmx8G -jar /datacommons/noor/klk37/picard.jar MarkIlluminaAdapters \
		INPUT=$BAM \
		OUTPUT=$OUT \
		METRICS=$MET \
		TMP_DIR=`pwd`/tmp
done
