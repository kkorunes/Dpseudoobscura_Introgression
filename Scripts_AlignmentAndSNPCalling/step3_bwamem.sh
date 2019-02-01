#!/bin/bash
#SBATCH --mem=60GB
set -euxo pipefail
cd /datacommons/noor/klk37/introgression/ubams_marked/

BAMS=*_markadapters.bam
for BAM in $BAMS
do
	name="$(echo ${BAM} | grep -oP '.*(?=_markadapters.bam)')"
	echo "working on $name"
	/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -Xmx8G -jar /datacommons/noor/klk37/picard.jar SamToFastq \
		I=$BAM \
		FASTQ=/dev/stdout \
		CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=2 INTERLEAVE=true NON_PF=true \
		TMP_DIR=`pwd`/tmp | \
		/opt/apps/rhel7/bwa-0.7.17/bwa mem -M -t 4 -p /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa /dev/stdin | \
		/datacommons/noor/klk37/java/jdk1.8.0_144/bin/java -Xmx16G -jar /datacommons/noor/klk37/picard.jar MergeBamAlignment \
		ALIGNED_BAM=/dev/stdin \
		UNMAPPED_BAM="$name"_unaligned_read_pairs.bam \
		OUTPUT="$name"_piped.bam \
		R=/datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa CREATE_INDEX=true ADD_MATE_CIGAR=true \
		CLIP_ADAPTERS=false CLIP_OVERLAPPING_READS=true \
		INCLUDE_SECONDARY_ALIGNMENTS=true MAX_INSERTIONS_OR_DELETIONS=-1 \
		PRIMARY_ALIGNMENT_STRATEGY=MostDistant ATTRIBUTES_TO_RETAIN=XS \
		TMP_DIR=`pwd`/tmp
done
