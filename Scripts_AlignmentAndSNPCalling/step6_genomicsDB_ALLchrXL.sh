#!/bin/bash
#SBATCH --mem=100GB
#SBATCH -p noor
cd /datacommons/noor/klk37/gvcfs/
PATH=/datacommons/noor/klk37/java/jdk1.8.0_144/bin:$PATH
export PATH
#Create initial GenomicsDB

/datacommons/noor/klk37/gatk-4.0.7.0/gatk --java-options "-Xmx80g -Xms40g" GenomicsDBImport \
	-V Dmir_MA28_dedup_reads-g.vcf.gz \
	-V Dmir_MAO101-4_dedup_reads-g.vcf.gz \
	-V Dmir_MAO3-3_dedup_reads-g.vcf.gz \
	-V Dmir_MAO3-4_dedup_reads-g.vcf.gz \
	-V Dmir_MAO3-5_dedup_reads-g.vcf.gz \
	-V Dmir_MAO3-6_dedup_reads-g.vcf.gz \
	-V Dmir_ML14_dedup_reads-g.vcf.gz \
	-V Dmir_ML16_dedup_reads-g.vcf.gz \
	-V Dmir_ML6f_dedup_reads-g.vcf.gz \
	-V Dmir_SP138_dedup_reads-g.vcf.gz \
	-V Dmir_SP235_dedup_reads-g.vcf.gz \
	-V Dbog_Potosi2_dedup_reads-g.vcf.gz \
	-V Dbog_Potosi3_dedup_reads-g.vcf.gz \
	-V Dbog_Susa2_dedup_reads-g.vcf.gz \
	-V Dbog_Susa3_dedup_reads-g.vcf.gz \
	-V Dbog_Susa6_dedup_reads-g.vcf.gz \
	-V Dbog_Sutatausa3_dedup_reads-g.vcf.gz \
	-V Dbog_Toro7_dedup_reads-g.vcf.gz \
	-V Dper_111_35_dedup_reads-g.vcf.gz \
	-V Dper_111_50_dedup_reads-g.vcf.gz \
	-V Dper_111_51_dedup_reads-g.vcf.gz \
	-V Dper_Mather40_dedup_reads-g.vcf.gz \
	-V Dper_MatherG_dedup_reads-g.vcf.gz \
	-V Dper_MSH3_dedup_reads-g.vcf.gz \
	-V Dper_MSH42_dedup_reads-g.vcf.gz \
	-V Dper_MSH7_dedup_reads-g.vcf.gz \
	-V S10-A47_dedup_reads-g.vcf.gz \
	-V S11-A14_dedup_reads-g.vcf.gz \
	-V S12-M27_dedup_reads-g.vcf.gz \
	-V S13-A48_dedup_reads-g.vcf.gz \
	-V S14-A49_dedup_reads-g.vcf.gz \
	-V S15-A57_dedup_reads-g.vcf.gz \
	-V S16-A30_dedup_reads-g.vcf.gz \
	-V S17-M20_dedup_reads-g.vcf.gz \
	-V S18-M15_dedup_reads-g.vcf.gz \
	-V S19-A24_dedup_reads-g.vcf.gz \
	-V S1-A56_dedup_reads-g.vcf.gz \
	-V S20-M13_dedup_reads-g.vcf.gz \
	-V S21-M6_dedup_reads-g.vcf.gz \
	-V S22-A6_dedup_reads-g.vcf.gz \
	-V S2-MV2-25_dedup_reads-g.vcf.gz \
	-V S3-M14_dedup_reads-g.vcf.gz \
	-V S4-A60_dedup_reads-g.vcf.gz \
	-V S5-M17_dedup_reads-g.vcf.gz \
	-V S6-A19_dedup_reads-g.vcf.gz \
	-V S7-Flag14_dedup_reads-g.vcf.gz \
	-V S8-VY-F16_dedup_reads-g.vcf.gz \
	-V S9-A12_dedup_reads-g.vcf.gz \
	--genomicsdb-workspace-path chrXL_allsamples_genomicsdb \
	-L NC_030302.1
