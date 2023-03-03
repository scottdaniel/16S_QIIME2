#!/usr/bin/env bash

set -xeuo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: bash $0 PATH_TO_CONFIG"
    exit 1
fi

CONFIG_FP=$1

snakemake \
    --jobs 100 \
    --configfile ${CONFIG_FP} \
    --cluster-config cluster.json \
    --keep-going \
    --latency-wait 90 \
    --notemp \
    --printshellcmds \
    --cluster \
    "sbatch --account={cluster.account} --partition={cluster.partition} --mem-per-cpu={cluster.memcpu} --cpus-per-task={threads} --time={cluster.time} --job-name={cluster.name} --output=slurm_%x_%j.out" \
    --dryrun
