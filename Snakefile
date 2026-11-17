import configparser
import os
import re
import yaml

from scripts import util_functions

# Use project_dir from the config if set, otherwise the project the pipeline sits in
# as a git submodule (e.g. a blank_16s project, in Scripts/HPC_cluster/16S_QIIME2)
PROJECT_DIR = (config["all"].get("project_dir") or
               util_functions.find_project_dir(workflow.basedir))
if not PROJECT_DIR:
    raise ValueError("Could not find the project directory: this pipeline is not a "
                     "git submodule of a project. Set all: project_dir in qiime2_config.yml")
PROJECT_DIR = os.path.abspath(os.path.expanduser(PROJECT_DIR))

MUX_DIR = os.path.join(PROJECT_DIR, config["all"]["mux_dir"])

# Run folder with the multiplexed fastq.gz and/or PetaGene .fasterq files; all of
# them end up in MUX_DIR as fastq.gz. Leave raw_data empty to skip copying
# (fastqs already in MUX_DIR).
RAW_DATA = config["all"].get("raw_data") or ""
if RAW_DATA:
    RAW_DIR = os.path.join(
        config["all"].get("raw_data_root", "/mnt/isilon/microbiome/raw_data"), RAW_DATA)
    RAW_FASTQS, RAW_FASTERQS = util_functions.get_raw_fastqs(RAW_DIR)
else:
    RAW_DIR = ""
    RAW_FASTQS = []
    RAW_FASTERQS = []

# Pipeline output (demultiplexed fastqs and QIIME_output) goes in data_dir, relative to
# project_dir. manifest.csv, the read count tables and the mapping file stay in project_dir.
DATA_DIR = os.path.normpath(os.path.join(PROJECT_DIR, config["all"].get("data_dir", "Data")))
QIIME_OUTPUT_DIR = DATA_DIR + "/QIIME_output"

# Mapping file in project_dir. If mapping is left blank, use the .tsv in the
# raw_data folder (MAPPING_SRC), which gets copied to project_dir.
MAPPING = config["all"].get("mapping") or ""
MAPPING_SRC = ""
if not MAPPING:
    if not RAW_DIR:
        raise ValueError("all: mapping can only be left blank when all: raw_data is set "
                         "in qiime2_config.yml")
    MAPPING_SRC = util_functions.get_raw_mapping(RAW_DIR)
    MAPPING = os.path.basename(MAPPING_SRC)
MAPPING_FP = os.path.join(PROJECT_DIR, MAPPING)
# Sample IDs are needed now, before the copy has run, so read them from the
# raw_data copy until the project_dir copy exists
SAMPLE_IDS = util_functions.get_sample(
    MAPPING_SRC if MAPPING_SRC and not os.path.exists(MAPPING_FP) else MAPPING_FP)

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

