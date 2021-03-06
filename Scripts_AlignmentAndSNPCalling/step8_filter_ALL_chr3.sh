#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor/klk37/gvcfs/
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH

/datacommons/noor/klk37/gatk-4.0.7.0/gatk SelectVariants \
	-R /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa \
	-V chr3_firstpassSNPS_64samples.vcf.gz \
	--select-type-to-include SNP \
	-O chr3_firstpassSNPS_64samples_snps.vcf.gz

/datacommons/noor/klk37/gatk-4.0.7.0/gatk VariantFiltration \
	-R /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa \
	-V chr3_firstpassSNPS_64samples_snps.vcf.gz \
	-O chr3_64samples_filteredSNPS.vcf.gz \
	--filter-expression "QD < 2.0 || FS > 60.0 || SOR > 3.0 || MQ < 40.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" \
	--filter-name "hardfilter"
