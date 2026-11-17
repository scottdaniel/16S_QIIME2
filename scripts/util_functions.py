import glob
import os


def get_sample(sample_fp):
   with open(sample_fp) as f:
      lines = f.readlines()
   samples = []
   for line in lines:
      samples.append(line.split("\t")[0])
   if "SampleID" in samples: samples.remove("SampleID")
   if "#SampleID" in samples: samples.remove("#SampleID")
   return(samples)


def find_project_dir(pipeline_dir):
   """Return the root of the git repo that has this pipeline as a submodule
   (e.g. a project made from the blank_16s template, where the pipeline lives in
   Scripts/HPC_cluster/16S_QIIME2), or None if it isn't a submodule."""
   d = os.path.dirname(os.path.abspath(pipeline_dir))
   while d != os.path.dirname(d):
      if os.path.isfile(os.path.join(d, ".gitmodules")):
         return d
      d = os.path.dirname(d)
   return None


def get_raw_fastqs(raw_dir):
   """Return the names of all *.fastq.gz files in raw_dir."""
   if not os.path.isdir(raw_dir):
      raise ValueError("raw_data directory not found: " + raw_dir +
                       "\nCheck all: raw_data (and raw_data_root) in qiime2_config.yml")
   fastqs = sorted(os.path.basename(f) for f in glob.glob(os.path.join(raw_dir, "*.fastq.gz")))
   if not fastqs:
      raise ValueError("No *.fastq.gz files found in raw_data directory: " + raw_dir)
   return fastqs
