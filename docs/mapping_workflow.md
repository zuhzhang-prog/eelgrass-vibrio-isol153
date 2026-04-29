# Metagenomic recruitment workflow

This document describes the final reconstructed workflow used to map eelgrass-associated metagenomic reads against a combined Bowtie2 reference built from 19 Northern California eelgrass-associated *Vibrio* isolate genomes, and to summarize recruitment at the genome level using CoverM.

This workflow was used to generate the metagenomic recruitment summaries that supported Figure 1 of the poster.

## Software

- bowtie2
- samtools
- coverm
- conda

## Environment

A dedicated conda environment was used for mapping:

```bash
conda create -n mapping_env -c conda-forge -c bioconda bowtie2 samtools coverm
conda activate mapping_env
```

## Directory structure used in this project

```text
/home/algol/projects/
├── isolates/
│   └── bowtie2/
│       ├── combined_19_isolates_renamed.fasta
│       └── combined_19_isolates_renamed_index.*
├── metagenomes/
│   ├── ALI_MergedLibrary/
│   ├── WAS_MergedLibraries/
│   ├── SD_MergedLibraries/
│   ├── QU_MergedLibrary/
│   └── ...
└── bowtie2_mapping_results/
```

## 1. Build the Bowtie2 index

Skip this step if the index already exists.

```bash
bowtie2-build \
  /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed.fasta \
  /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index
```

This creates the standard Bowtie2 index files:

- `combined_19_isolates_renamed_index.1.bt2`
- `combined_19_isolates_renamed_index.2.bt2`
- `combined_19_isolates_renamed_index.3.bt2`
- `combined_19_isolates_renamed_index.4.bt2`
- `combined_19_isolates_renamed_index.rev.1.bt2`
- `combined_19_isolates_renamed_index.rev.2.bt2`

## 2. Recommended mapping workflow (streaming, no intermediate SAM)

This is the final workflow recommended for this project, because writing full SAM files can consume a large amount of disk space. In the final workflow, Bowtie2 output is streamed directly into `samtools view` and `samtools sort`.

All metagenomes in this workflow were treated as **single-end reads** using `-U`.

### Example: WAS

```bash
READS=$(find /home/algol/projects/metagenomes/WAS_MergedLibraries -maxdepth 1 -type f -name "*.fastq" | sort | paste -sd, -)

nohup bash -lc "
bowtie2 -p 28 \
  -x /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index \
  -U ${READS} | \
samtools view -@ 28 -bS - | \
samtools sort -@ 28 -o /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam && \
samtools index -@ 28 /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam
" > /home/algol/projects/bowtie2_mapping_results/bowtie2_samtools_was_v2.log 2>&1 &
```

### Example: ALI

```bash
READS=$(find /home/algol/projects/metagenomes/ALI_MergedLibrary -maxdepth 1 -type f -name "*.fastq" | sort | paste -sd, -)

nohup bash -lc "
bowtie2 -p 28 \
  -x /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index \
  -U ${READS} | \
samtools view -@ 28 -bS - | \
samtools sort -@ 28 -o /home/algol/projects/bowtie2_mapping_results/ali_to_isolates_v2_sorted.bam && \
samtools index -@ 28 /home/algol/projects/bowtie2_mapping_results/ali_to_isolates_v2_sorted.bam
" > /home/algol/projects/bowtie2_mapping_results/bowtie2_samtools_ali_v2.log 2>&1 &
```

### Example: QU

```bash
READS=$(find /home/algol/projects/metagenomes/QU_MergedLibrary -maxdepth 1 -type f -name "*.fastq" | sort | paste -sd, -)

nohup bash -lc "
bowtie2 -p 28 \
  -x /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index \
  -U ${READS} | \
samtools view -@ 28 -bS - | \
samtools sort -@ 28 -o /home/algol/projects/bowtie2_mapping_results/qu_to_isolates_v2_sorted.bam && \
samtools index -@ 28 /home/algol/projects/bowtie2_mapping_results/qu_to_isolates_v2_sorted.bam
" > /home/algol/projects/bowtie2_mapping_results/bowtie2_samtools_qu_v2.log 2>&1 &
```

## 3. Genome-level recruitment summary with CoverM

After sorted BAM files were generated, recruitment was summarized at the genome level using CoverM.

The poster used the following metrics:

- `relative_abundance`
- `mean`
- `covered_fraction`

### Example: WAS

```bash
coverm genome \
  -b /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam \
  --separator "_" \
  -m relative_abundance mean covered_fraction \
  -t 28 \
  -o /home/algol/projects/bowtie2_mapping_results/WAS_CoverM_Isolate_Abundance.tsv
```

### Example: ALI

```bash
coverm genome \
  -b /home/algol/projects/bowtie2_mapping_results/ali_to_isolates_v2_sorted.bam \
  --separator "_" \
  -m relative_abundance mean covered_fraction \
  -t 28 \
  -o /home/algol/projects/bowtie2_mapping_results/ALI_CoverM_Isolate_Abundance.tsv
```

### Example: QU

```bash
coverm genome \
  -b /home/algol/projects/bowtie2_mapping_results/qu_to_isolates_v2_sorted.bam \
  --separator "_" \
  -m relative_abundance mean covered_fraction \
  -t 28 \
  -o /home/algol/projects/bowtie2_mapping_results/QU_CoverM_Isolate_Abundance.tsv
```

### Optional: include mapped counts

```bash
coverm genome \
  -b /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam \
  --separator "_" \
  -m count relative_abundance mean covered_fraction \
  -t 28 \
  -o /home/algol/projects/bowtie2_mapping_results/WAS_CoverM_Isolate_Abundance_with_counts.tsv
```

## 4. Quick checks

Useful quick checks after mapping:

```bash
# Check BAM and index files
ls -lh /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam
ls -lh /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam.bai

# Count mapped reads
samtools view -c -F 4 /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam

# Inspect per-reference mapping
samtools idxstats /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam

# Monitor the log while running
tail -f /home/algol/projects/bowtie2_mapping_results/bowtie2_samtools_was_v2.log
```

## 5. Earlier workflow used during pipeline development

Initially, the workflow was run in two steps:

1. Bowtie2 first wrote a SAM file
2. Samtools was then used to convert SAM to BAM, sort, and index

This worked, but SAM files were extremely large and sometimes filled the WSL filesystem. The streaming workflow above was adopted as the final recommended version.

### Step 1: Bowtie2 to SAM

```bash
nohup bowtie2 -p 28 \
  -x /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index \
  -U /home/algol/projects/metagenomes/WAS_MergedLibraries/*.fastq \
  -S /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2.sam \
  > /home/algol/projects/bowtie2_mapping_results/bowtie2_log_was_v2.txt 2>&1 &
```

### Step 2: SAM to sorted BAM + index

```bash
nohup sh -c "
samtools view -@ 28 -bS /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2.sam | \
samtools sort -@ 28 -o /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam && \
samtools index -@ 28 /home/algol/projects/bowtie2_mapping_results/was_to_isolates_v2_sorted.bam
" > /home/algol/projects/bowtie2_mapping_results/samtools_process_was_v2.log 2>&1 &
```

## 6. Notes

- All metagenomes in this workflow were treated as **single-end** reads using `-U`.
- The combined Bowtie2 reference index contained **19 isolate genomes**.
- CoverM was run on **sorted BAM files**, not SAM files.
- The final workflow streamed Bowtie2 output directly into samtools to avoid very large intermediate SAM files.
- Recruitment outputs used in the poster were based on:
  - `relative_abundance`
  - `mean`
  - `covered_fraction`

## 7. Compact reusable template

If you want one reusable block for any sample:

```bash
SAMPLE_DIR="/home/algol/projects/metagenomes/WAS_MergedLibraries"
OUT_TAG="was"

READS=$(find "${SAMPLE_DIR}" -maxdepth 1 -type f -name "*.fastq" | sort | paste -sd, -)

nohup bash -lc "
bowtie2 -p 28 \
  -x /home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index \
  -U ${READS} | \
samtools view -@ 28 -bS - | \
samtools sort -@ 28 -o /home/algol/projects/bowtie2_mapping_results/${OUT_TAG}_to_isolates_v2_sorted.bam && \
samtools index -@ 28 /home/algol/projects/bowtie2_mapping_results/${OUT_TAG}_to_isolates_v2_sorted.bam
" > /home/algol/projects/bowtie2_mapping_results/bowtie2_samtools_${OUT_TAG}_v2.log 2>&1 &

coverm genome \
  -b /home/algol/projects/bowtie2_mapping_results/${OUT_TAG}_to_isolates_v2_sorted.bam \
  --separator "_" \
  -m relative_abundance mean covered_fraction \
  -t 28 \
  -o /home/algol/projects/bowtie2_mapping_results/${OUT_TAG^^}_CoverM_Isolate_Abundance.tsv
```

## 8. Reproducibility note

This workflow was reconstructed from the final commands, outputs, and notes used during poster development. The original analysis was performed interactively in the terminal rather than as a fully scripted pipeline.
