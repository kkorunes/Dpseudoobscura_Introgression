#!/bin/bash
#SBATCH --mem=20GB
cd /datacommons/noor/klk37/introgression/IIM

# For the D. pseudoobscura introgression analyses of Korunes, Machado, & Noor 2019
# This is a step in considering the models of divergence described in Costa & Wilinson-Herbots 2017
# First, blast the Dpse gene annotations against the Dmir reference

/opt/apps/rhel7/ncbi-blast/bin/blastn -db /datacommons/noor/klk37/introgression/DroMir2.2_genomic.fa -query dpse-all-gene-r3.04.fasta -evalue 0.000001 -perc_identity 80 -outfmt 6 -out initialBLAST-DpseGenesToDmir.out
