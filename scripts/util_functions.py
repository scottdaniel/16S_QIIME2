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
   """Return the names (without extension) of the *.fastq.gz files and of the
   PetaGene-compressed *.fasterq files in raw_dir. A file found in both forms is
   only listed as a fastq.gz."""
   if not os.path.isdir(raw_dir):
      raise ValueError("raw_data directory not found: " + raw_dir +
                       "\nCheck all: raw_data (and raw_data_root) in qiime2_config.yml")
   def names(ext):
      return sorted(os.path.basename(f)[:-len(ext)]
                    for f in glob.glob(os.path.join(raw_dir, "*" + ext)))
   fastqs = names(".fastq.gz")
   fasterqs = [n for n in names(".fasterq") if n not in fastqs]
   if not fastqs and not fasterqs:
      raise ValueError("No *.fastq.gz or *.fasterq files found in raw_data directory: " + raw_dir)
   return fastqs, fasterqs


def get_raw_mapping(raw_dir):
   """Return the path of the one *.tsv mapping file in raw_dir."""
   tsvs = sorted(glob.glob(os.path.join(raw_dir, "*.tsv")))
   if len(tsvs) != 1:
      raise ValueError("Expected one .tsv mapping file in " + raw_dir + ", found " +
                       str(len(tsvs)) + ": " + ", ".join(os.path.basename(f) for f in tsvs) +
                       "\nSet all: mapping in qiime2_config.yml instead")
   return tsvs[0]
