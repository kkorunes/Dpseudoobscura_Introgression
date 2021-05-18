# Dpseudoobscura_Introgression

#### "Scripts_AlignmentAndSNPCalling":
This directory contains all scripts used for alignment, SNP calling, and hard filtering. All sequencing data were aligned to the reference genome of D. miranda using BWA-0.7.5a (Li & Durbin 2009). Variants were called and filtered used GATK v4 (McKenna et al. 2010; Van der Auwera et al. 2013) after using Picard to mark adapters and duplicates (http://broadinstitute.github.io/picard).

#### "Scripts_ModelsOfDivergence":
This directory contains scripts for generating the input data to consider the coalescent models described by Costa & Wilkinson-Herbots (2017) to compare scenarios of divergence of D. persimilis and D. p. bogotana. See Costa & Wilkinson-Herbots (2017) for the R code containing the models themselves.

#### "Scripts_DivergenceAndRelativeRates":
This directory contains:
* scripts for calculating Dxy 
* empirical Dxy estimates and introgression effect estimates (needed for Figures 3, 5, and S3 in the associated manuscript)
* F statistics from Dsuite (Malinsky, Matschiner, & Svardal, 2020)
* scripts for performing Tajima's Relative Rate Test by tallying substitutions per lineage (relative to outgroup D. lowei) and calculating the chi-square test statistic as described in Tajima 1993.
* the .xml file used for StarBEAST2
