import configparser
import os
import re
import yaml

from scripts import util_functions

# Use project_dir from the config if set, otherwise the project this pipeline is
# a git submodule of (e.g. a blank_16s project with Scripts/HPC_cluster/16S_QIIME2)
PROJECT_DIR = (config["all"].get("project_dir") or
               util_functions.find_project_dir(workflow.basedir))
if not PROJECT_DIR:
    raise ValueError("Could not find the project directory: this pipeline is not a "
                     "git submodule of a project. Set all: project_dir in qiime2_config.yml")
PROJECT_DIR = os.path.abspath(os.path.expanduser(PROJECT_DIR))

MUX_DIR = os.path.join(PROJECT_DIR, config["all"]["mux_dir"])

# Run folder with the multiplexed fastq.gz files; all of them get copied to MUX_DIR.
# Leave raw_data empty to skip copying (fastqs already in MUX_DIR).
RAW_DATA = config["all"].get("raw_data") or ""
if RAW_DATA:
    RAW_DIR = os.path.join(
        config["all"].get("raw_data_root", "/mnt/isilon/microbiome/raw_data"), RAW_DATA)
    RAW_FASTQS = util_functions.get_raw_fastqs(RAW_DIR)
else:
    RAW_DIR = ""
    RAW_FASTQS = []

QIIME_OUTPUT_DIR = PROJECT_DIR + "/QIIME_output"
MAPPING_FP = PROJECT_DIR + "/" + config["all"]["mapping"]
SAMPLE_IDS = util_functions.get_sample(MAPPING_FP)

trim_left_f = config["denoise"]["trim_left_f"]
trunc_len_f = config["denoise"]["trunc_len_f"]
trim_left_r = config["denoise"]["trim_left_r"]
trunc_len_r = config["denoise"]["trunc_len_r"]

DENOISE_DIR = (QIIME_OUTPUT_DIR + "/denoise-results")

CORE_METRIC_DIR = (DENOISE_DIR + "/core-metrics" +
		  "_sampling_depth_" + str(config["diversity"]["sampling_depth"]))

CORE_METRIC_UNRAREFIED_DIR = (DENOISE_DIR + "/core-metrics-unrarefied")

include: "rules/targets/targets.rules"
include: "rules/copy/copy_raw.rules"
include: "rules/demux/dnabc.rules"
include: "rules/import/qiime_import.rules"
include: "rules/import/qiime_demux_stat.rules"
include: "rules/denoise/denoise.rules"
include: "rules/taxonomy/taxonomy.rules"
include: "rules/tree/tree.rules"
include: "rules/diversity/diversity.rules"
include: "rules/unassign/unassign.rules"
include: "rules/dada2_species/dada2.rules"
include: "rules/vsearch/vsearch.rules"

workdir: PROJECT_DIR

rule all:
    input: TARGET_ALL

