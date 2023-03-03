#!/usr/bin/env bash

#SBATCH --mem=2G
#SBATCH -n 1
#SBATCH --export=ALL
#SBATCH --mail-user=danielsg@chop.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --no-requeue
#SBATCH -t 72:00:00
#SBATCH --output=slurm_%x_%j.out

source ~/.bashrc.conda #needed to make "conda" command to work
conda activate qiime2-2023.2

set -xeuo pipefail

if [[ -f config.yaml ]]; then
    echo "Must have a config.yaml to be able to run"
    exit 1
fi

snakemake --profile ./
