#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor/klk37/introgression/
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH
#Create initial variant calls

#ulimit -c unlimited

FILES=*.bam
for BAM in $FILES
do 
	ID="$(echo ${BAM} | awk -F'[.]' '{print $1}')"
	echo "calling variants for $ID"
	OUT="$ID"-g.vcf.gz
	echo "$OUT"
	/datacommons/noor/klk37/gatk-4.0.7.0/gatk --java-options "-Xmx100G" HaplotypeCaller \
		-R /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa -I $BAM -O $OUT -ERC GVCF
done
