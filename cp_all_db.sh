#!/usr/bin/env bash
echo "Copying greengenes classifier for qiime2"
cp /mnt/isilon/microbiome/analysis/danielsg/TagSequencingPipeline/gg-13-8-99-nb-classifier.qza ./QIIME2_data/
echo "Copying unassigner species database"
cp /mnt/isilon/microbiome/analysis/danielsg/16S_QIIME2/unassign_data/unassigner_species.fasta ./unassign_data/
echo "Copying rdp classifier for dada2"
cp /mnt/isilon/microbiome/analysis/danielsg/16S_QIIME2/dada2_data/rdp_species_assignment_16.fa.gz ./dada2_data/
