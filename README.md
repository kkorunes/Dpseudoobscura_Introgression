# Dpseudoobscura_Introgression

## Citation
This repository is associated with the following publication:  
Korunes, KL, CA Machado, MAF Noor. Inversions shape the divergence of _Drosophila pseudoobscura_ and _D. persimilis_ on multiple timescales. 2021. Evolution.

Corresponding author: Katharine Korunes, kkorunes@gmail.com

## Underlying Date
Note that all raw sequence data associated with these analyses have been uploaded to NCBI’s Short Read Archive, with sequence accession numbers in Supplementary Table 1 in the associated manucript. 

## The 3 directories here contain code for analyses performed in this study:
#### 1. [Scripts_AlignmentAndSNPCalling](./Scripts_AlignmentAndSNPCalling) 
This directory contains all scripts used for alignment, SNP calling, and hard filtering. All sequencing data were aligned to the reference genome of D. miranda using BWA-0.7.5a (Li & Durbin 2009). Variants were called and filtered used GATK v4 (McKenna et al. 2010; Van der Auwera et al. 2013) after using Picard to mark adapters and duplicates (http://broadinstitute.github.io/picard).

#### 2. [Scripts_ModelsOfDivergence](./Scripts_ModelsOfDivergence) 
This directory contains scripts for generating the input data to consider the coalescent models described by Costa & Wilkinson-Herbots (2017) to compare scenarios of divergence of D. persimilis and D. p. bogotana. See Costa & Wilkinson-Herbots (2017) for the R code containing the models themselves.

#### 3. [Scripts_DivergenceAndRelativeRates](./Scripts_DivergenceAndRelativeRates) 
This directory contains:
* scripts for calculating Dxy 
* empirical Dxy estimates and introgression effect estimates needed for Figures 3, 5, and S3 in the associated manuscript.
* F statistics from Dsuite (Malinsky, Matschiner, & Svardal, 2020) needed for Figure 4 in the associated manuscript.
* scripts for performing Tajima's Relative Rate Test by tallying substitutions per lineage (relative to outgroup D. lowei) and calculating the chi-square test statistic as described in Tajima 1993.
* the .xml file used for StarBEAST2.
