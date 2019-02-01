#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor/klk37/gvcfs/
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH
#Create initial GenomicsDB

/datacommons/noor/klk37/gatk-4.0.7.0/gatk --java-options "-Xmx80g" GenotypeGVCFs \
	-R /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa \
	-V gendb://chrXR_allsamples_genomicsdb \
	-O chrXR_firstpassSNPS.vcf.gz
