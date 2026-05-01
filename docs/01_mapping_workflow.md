# Metagenomic recruitment workflow

This document describes how leaf-associated *Zostera marina* metagenomic reads were mapped against a combined Bowtie2 reference built from 19 Northern California eelgrass-associated *Vibrio* isolate genomes, and how recruitment was summarized at the genome level using CoverM.

The outputs of this workflow support **Figure 1** of the poster.

> **Where is the code?**
> All executable code lives in `scripts/01_mapping/`. This document explains *what* each step does and *why* it was designed that way. For the actual commands, read the scripts directly — they are short, parameterized, and the single source of truth.

---

## Software

- `bowtie2` — short-read aligner
- `samtools` — SAM/BAM conversion, sorting, indexing
- `coverm` — genome-level coverage and abundance summarization
- `conda` — environment management

## Environment

A dedicated conda environment was used:

```bash
conda create -n mapping_env -c conda-forge -c bioconda bowtie2 samtools coverm
conda activate mapping_env
```

## Directory structure

```text
/home/algol/projects/
├── isolates/
│   └── bowtie2/
│       ├── combined_19_isolates_renamed.fasta       # combined reference
│       └── combined_19_isolates_renamed_index.*     # bowtie2 index
├── metagenomes/
│   ├── ALI_MergedLibrary/
│   ├── WAS_MergedLibraries/
│   ├── SD_MergedLibraries/
│   ├── QU_MergedLibrary/
│   └── ...
└── bowtie2_mapping_results/                         # all output BAMs and TSVs
```

---

## Pipeline overview

The workflow has three logical stages, each implemented as a small, single-purpose script:

| Stage | Script | What it does |
|---|---|---|
| 1. Build index | `01_build_index.sh` | One-time. Builds Bowtie2 index from the combined 19-isolate FASTA. |
| 2. Map one sample | `02_map_one_sample.sh` | Maps one metagenome directory → sorted, indexed BAM. Runs in the background via `nohup`. |
| 3. Summarize one sample | `03_coverm_one_sample.sh` | Runs CoverM on the BAM → per-genome abundance TSV. |

Two **wrapper scripts** drive the pipeline at scale by reading `metadata/mapping_samples.tsv`:

| Wrapper | Calls | When to use |
|---|---|---|
| `04_run_mapping_from_samplesheet.sh` | `02_map_one_sample.sh` for every row | Launch all mapping jobs at once. |
| `05_run_coverm_from_samplesheet.sh` | `03_coverm_one_sample.sh` for every row | After all BAMs are written, summarize them all. |

Typical end-to-end usage on a single machine:

```bash
# 1. Build the index (only once)
bash scripts/01_mapping/01_build_index.sh

# 2. Launch all mapping jobs (background, parallel)
bash scripts/01_mapping/04_run_mapping_from_samplesheet.sh metadata/mapping_samples.tsv 7

# 3. Wait for BAMs to finish (check logs in bowtie2_mapping_results/)

# 4. Summarize all samples with CoverM
bash scripts/01_mapping/05_run_coverm_from_samplesheet.sh metadata/mapping_samples.tsv 28
```

---

## Why the pipeline is designed this way

This section explains the non-obvious decisions, because the choices look the same from the outside but they were made for specific reasons that matter when you adapt the pipeline.

### Why single-end (`-U`), not paired-end?

All metagenomes in this project were processed as **single-end** reads using `bowtie2 -U`. The upstream merging step combined reads from multiple lanes/runs into a flat directory of `.fastq` files without preserving an explicit R1/R2 pairing structure that Bowtie2 could use. Treating reads as single-end is the conservative choice when pair information is unreliable: it slightly reduces alignment specificity but never produces ghost paired-end behavior. For genome-level recruitment with CoverM (which only needs alignment counts and coverage), single-end mapping is sufficient.

If you adapt this pipeline to data with reliable R1/R2 files, switch to `-1 ... -2 ...` in `02_map_one_sample.sh` — the rest of the pipeline does not change.

### Why a single combined reference instead of 19 separate ones?

All 19 isolate genomes were concatenated into one FASTA (`combined_19_isolates_renamed.fasta`) and indexed once. This matters for **competitive mapping**: when a read could plausibly match more than one isolate (e.g., closely related strains in the panel), Bowtie2 sees all references at once and assigns the read to the best hit. Mapping the same reads against 19 independent indexes would let the same read align "successfully" to multiple isolates, inflating recruitment for closely related references and making cross-isolate comparisons meaningless.

Each contig was renamed (`<isolate>_<contig>`) so that CoverM's `--separator "_"` flag can later collapse contig-level alignments back to genome-level summaries.

### Why streaming (`bowtie2 | samtools view | samtools sort`) instead of writing a SAM file?

The earlier version of this pipeline wrote SAM files to disk first and converted them to BAM as a second step. SAM files for these metagenomes were on the order of hundreds of GB and repeatedly filled the WSL filesystem mid-run. The streaming version pipes Bowtie2 output directly into `samtools view -bS` (compressing to BAM as it streams) and then into `samtools sort` (which uses bounded temporary files). This:

- avoids ever materializing an uncompressed SAM on disk,
- keeps peak disk usage roughly equal to the final BAM size,
- and runs faster because there is no second pass over a multi-hundred-GB file.

The trade-off: if any stage in the pipe crashes (e.g., out-of-memory during sort), there is no SAM file to recover from and the run must restart from Bowtie2. In practice this has been a non-issue with the streaming workflow.

### Why `nohup ... &` and not `srun` / `sbatch` / `parallel`?

`02_map_one_sample.sh` returns immediately after launching the mapping job in the background with `nohup`. This was chosen for a single-server environment with no scheduler. Using `nohup` lets you start a job and close the SSH session without killing it; the wrapper script `04_run_mapping_from_samplesheet.sh` exploits this to launch all sites in rapid succession, so they end up running in parallel.

**Important consequence**: with N sites in the sample sheet, you have N concurrent jobs each requesting `THREADS` cores. Set the `THREADS` argument so that `N × THREADS` does not exceed your physical core count — otherwise the jobs thrash. On a 28-core machine with 4 sites, `THREADS=7` is a reasonable choice.

### Why CoverM and not raw `samtools idxstats`?

`samtools idxstats` reports raw mapped-read counts per reference contig, which:

- does not collapse contigs back to genomes,
- does not normalize by genome length,
- and does not distinguish "this genome is broadly covered at low depth" from "one contig has a deep pileup."

CoverM with `--separator "_"` collapses to genome level, and the three metrics used here capture complementary aspects of recruitment:

- **`relative_abundance`** — how much of the mapped read pool is assigned to each genome. Useful for cross-site comparison.
- **`mean`** — average per-base coverage depth across the genome. Useful for distinguishing weak detection from strong recruitment.
- **`covered_fraction`** — fraction of the genome that has any coverage at all. Critical for filtering out spurious hits where only conserved regions recruit reads.

A genome with high `relative_abundance` but low `covered_fraction` is recruiting reads only to a few conserved loci, not as a whole organism. The poster's interpretation of Isol153 as a consistently recruited lineage relies on it scoring well on **all three** metrics, not just one.

---

## Sample sheet format

`metadata/mapping_samples.tsv` is a tab-separated file with a header and four columns:

| Column | Meaning | Example |
|---|---|---|
| `SITE` | Human-readable site name | `Westhaven` |
| `OUT_TAG` | Lowercase tag used in all output filenames | `was` |
| `SAMPLE_DIR` | Absolute path to the directory of `.fastq` files | `/home/algol/projects/metagenomes/WAS_MergedLibraries` |
| `GROUP` | Free-form grouping label (region, batch, etc.) | `focal` |

The wrapper scripts read this file with `tail -n +2 | while IFS=$'\t' read ...`, skip incomplete rows with a warning, and call the per-sample scripts with the parsed values. To add a new site, append a row — no code changes required.

---

## Output naming convention

For a sample with `OUT_TAG=was`:

| File | Path |
|---|---|
| Sorted BAM | `bowtie2_mapping_results/was_to_isolates_v2_sorted.bam` |
| BAM index | `bowtie2_mapping_results/was_to_isolates_v2_sorted.bam.bai` |
| Mapping log | `bowtie2_mapping_results/bowtie2_samtools_was_v2.log` |
| CoverM output | `bowtie2_mapping_results/WAS_CoverM_Isolate_Abundance.tsv` |

Note the case difference: BAMs use lowercase tags (`was`), CoverM TSVs use uppercase (`WAS`). This is produced by the `${OUT_TAG^^}` expansion in `03_coverm_one_sample.sh` and matches the naming used in the downstream figure scripts.

---

## Quality checks after mapping

These are ad-hoc commands run by hand after the pipeline finishes — they are not part of the automated workflow.

```bash
# Confirm BAM and index exist and have reasonable sizes
ls -lh bowtie2_mapping_results/was_to_isolates_v2_sorted.bam{,.bai}

# Count successfully mapped reads (excluding flag 4 = unmapped)
samtools view -c -F 4 bowtie2_mapping_results/was_to_isolates_v2_sorted.bam

# Per-reference mapped-read counts (sanity check before CoverM)
samtools idxstats bowtie2_mapping_results/was_to_isolates_v2_sorted.bam

# Watch a job in real time
tail -f bowtie2_mapping_results/bowtie2_samtools_was_v2.log
```

A successful mapping log should end with Bowtie2's overall alignment summary (overall alignment rate, etc.) and no `samtools sort` errors.

---

## Reproducibility note

The original mapping was performed interactively in the terminal during poster development; the scripts in `scripts/01_mapping/` are a cleaned-up, parameterized reconstruction of the final commands actually used. Running the scripts on the same input metagenomes and the same combined reference reproduces the BAMs and CoverM tables that fed into Figure 1.
