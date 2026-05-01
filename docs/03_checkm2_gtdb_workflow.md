# Isol153 taxonomy placement workflow

This document describes the genome-based workflow used to assess the quality and taxonomic placement of Isol153, the focal eelgrass-associated *Vibrio* isolate in this project.

The outputs of this workflow support the taxonomic interpretation presented in the poster and README.

---

## Goal

To determine whether Isol153 can be assigned to a currently represented GTDB species cluster, using a two-step approach:

1. **CheckM2** — genome quality assessment (completeness, contamination)
2. **GTDB-Tk `ani_rep`** — ANI-based comparison against GTDB representative genomes

This workflow was designed to answer three specific questions:

1. Is the Isol153 assembly high quality enough for reliable taxonomic analysis?
2. Which known *Vibrio* lineage is Isol153 most closely related to?
3. Can Isol153 be confidently assigned to a currently represented GTDB species cluster?

---

## Input genome

```text
/home/algol/projects/isolates/Isol153.fa
```

Note: the file uses a `.fa` extension (not `.fasta` or `.fna`). This matters for both CheckM2 and GTDB-Tk — both tools require the extension to be specified explicitly when using directory-based input (see [Troubleshooting](#troubleshooting) below).

---

## Software and environment

| Tool | Version | Purpose |
|---|---|---|
| CheckM2 | (conda default) | Completeness and contamination estimation |
| GTDB-Tk | v2.6.1 | ANI-based taxonomic placement |
| GTDB reference database | r226 | Reference genome set for ANI comparison |

Platform: WSL2 / Linux

### Environment setup

Each tool was installed in a separate conda environment to avoid dependency conflicts:

```bash
# CheckM2
conda create -n checkm2 -c conda-forge -c bioconda checkm2
conda activate checkm2
mkdir -p /home/algol/databases/checkm2_db
checkm2 database --download --path /home/algol/databases/checkm2_db

# GTDB-Tk
conda create -n gtdbtk-2.6.1 -c conda-forge -c bioconda gtdbtk=2.6.1
conda activate gtdbtk-2.6.1
download-db.sh
conda env config vars set GTDBTK_DATA_PATH="/home/algol/miniconda3/envs/gtdbtk-2.6.1/share/gtdbtk-2.6.1/db/"
conda deactivate && conda activate gtdbtk-2.6.1
gtdbtk check_install
```

### Working directory setup

```bash
mkdir -p /home/algol/projects/isol153_identity/genome
ln -sf /home/algol/projects/isolates/Isol153.fa \
       /home/algol/projects/isol153_identity/genome/Isol153.fa
cd /home/algol/projects/isol153_identity
```

A symlink was used so the original genome file stays in `isolates/` while GTDB-Tk gets the directory-based input it expects.

---

## Step 1. Genome quality assessment with CheckM2

### Command

```bash
conda activate checkm2

checkm2 predict \
  --threads 28 \
  --input /home/algol/projects/isolates/Isol153.fa \
  --output-directory /home/algol/projects/isol153_identity/checkm2_out
```

Providing the `.fa` file directly as `--input` avoids the need to specify `-x fa`.

### Inspect output

```bash
column -t /home/algol/projects/isol153_identity/checkm2_out/quality_report.tsv | less -S
```

### Result

| Metric | Value |
|---|---|
| Completeness | 100.0% |
| Contamination | 0.03% |
| Genome size | 5,370,668 bp |
| GC content | 44% |
| Coding sequences | 4,718 |
| Total contigs | 33 |
| Contig N50 | 282,466 bp |
| Max contig length | 1,000,587 bp |

### Interpretation

Isol153 is a **high-quality draft genome** with near-complete completeness and negligible contamination. These values exceed the MIMAG high-quality threshold (completeness >90%, contamination <5%) by a wide margin, confirming that the assembly is reliable for downstream taxonomic and comparative analyses.

---

## Step 2. ANI-based taxonomic placement with GTDB-Tk

### Why `ani_rep` and not `classify_wf`?

GTDB-Tk offers two main workflows:

- **`classify_wf`**: full pipeline including marker gene identification, alignment, phylogenetic placement with pplacer, and ANI-based species assignment. Requires ~55 GB RAM for the bacterial pplacer step.
- **`ani_rep`**: lightweight ANI screening that compares the query genome against all GTDB representative genomes. Does not require pplacer.

`classify_wf` was attempted multiple times but failed during the pplacer stage due to memory limitations in the WSL2 environment (~31.6 GB available vs ~55 GB required). The failures occurred at the phylogenetic placement stage, not during ANI computation — therefore the `ani_rep` results remain valid and represent the most reliable taxonomic result from this workflow. See [classify_wf troubleshooting](#attempted-full-classification-with-classify_wf) below for details.

### Command

```bash
conda activate gtdbtk-2.6.1

gtdbtk ani_rep \
  --genome_dir /home/algol/projects/isol153_identity/genome \
  --out_dir /home/algol/projects/isol153_identity/gtdbtk_ani \
  -x fa \
  --cpus 28
```

The `-x fa` flag is required because the genome file uses a `.fa` extension.

### Key output files

```text
gtdbtk_ani/gtdbtk.ani_summary.tsv    # full ANI results against all representative genomes
gtdbtk_ani/gtdbtk.ani_closest.tsv    # closest representative genome
```

### Inspect results

```bash
column -t /home/algol/projects/isol153_identity/gtdbtk_ani/gtdbtk.ani_closest.tsv | less -S
```

Or, to avoid terminal truncation:

```python
python - <<'PY'
import pandas as pd
df = pd.read_csv('/home/algol/projects/isol153_identity/gtdbtk_ani/gtdbtk.ani_closest.tsv', sep='\t')
print(df[df['user_genome']=='Isol153'].head(10).to_string(index=False))
PY
```

### Result

| Metric | Value |
|---|---|
| Closest GTDB representative | GCF_024347375.1 |
| Reference taxonomy | *Vibrio coralliirubri* |
| ANI | 94.76% |
| Alignment fraction (AF) | 0.771 |
| GTDB species circumscription satisfied | **No** |

Other close hits were also within the genus *Vibrio*, but none crossed the GTDB species circumscription threshold.

### Interpretation

The ANI screen placed Isol153 **confidently within the genus *Vibrio***, with *Vibrio coralliirubri* as the closest currently represented reference genome. However, the ANI value (94.76%) falls below the typical species boundary (~95–96% ANI), and the alignment fraction (0.771) indicates that only ~77% of the Isol153 genome aligned to the reference. Together, these values mean that **Isol153 is not confidently assignable to the *V. coralliirubri* species cluster or any other currently represented GTDB species**.

This is consistent with Isol153 being a **genomically distinct lineage** — closely related to *V. coralliirubri* but potentially representing an undescribed or under-sampled species.

### Recommended taxonomic label

For figures and downstream documentation:

> ***Vibrio* sp. Isol153 (coralliirubri-related)**

Or in formal text:

> GTDB ANI screening placed Isol153 within the genus *Vibrio*, with *Vibrio coralliirubri* as the closest representative genome (94.76% ANI, AF 0.771), although Isol153 was not assigned to that representative species cluster.

---

## Why these decisions matter

### Why CheckM2 before GTDB-Tk?

A fragmented or contaminated genome produces unreliable ANI values — contaminating contigs from a different organism inflate or deflate ANI depending on whether the contaminant is closely or distantly related. Running CheckM2 first confirms that the genome is clean and complete, so the GTDB-Tk ANI result can be trusted at face value. Isol153's near-perfect quality scores (100% completeness, 0.03% contamination) mean the ANI result is not confounded by assembly artifacts.

### Why does the ANI threshold matter?

GTDB uses ANI (Average Nucleotide Identity) as the primary criterion for species-level circumscription. The typical threshold is ~95% ANI with a sufficient alignment fraction. Isol153 at 94.76% ANI and 0.771 AF falls just below this boundary — it is close enough that *V. coralliirubri* is clearly the nearest reference, but distant enough that assigning Isol153 to that species would not be supported by GTDB's circumscription standards. This is exactly the kind of result expected for an isolate from an underexplored ecological niche (eelgrass-associated microbiome), where many lineages have no close representative in reference databases.

### Why does genomic distinctiveness matter for the project?

The poster argues that Isol153 is a strong focal lineage for future study. "Strong" means three things: (1) it recruits consistently across metagenomic sites, (2) it carries candidate lineage-specific functional genes, and (3) it is **genomically distinct** enough that these features are not trivially shared with an already-described species. The GTDB result provides evidence for point 3 — Isol153 is not just another strain of a well-characterized species, but a potentially novel lineage.

---

## Output summary

| Output | Path | Description |
|---|---|---|
| CheckM2 report | `checkm2_out/quality_report.tsv` | Completeness, contamination, assembly stats |
| ANI summary | `gtdbtk_ani/gtdbtk.ani_summary.tsv` | ANI against all GTDB representative genomes |
| ANI closest | `gtdbtk_ani/gtdbtk.ani_closest.tsv` | Closest representative genome and ANI/AF values |

---

## Attempted full classification with classify_wf

For completeness, `classify_wf` was attempted but did not run successfully:

```bash
gtdbtk classify_wf \
  --genome_dir /home/algol/projects/isol153_identity/genome \
  --out_dir /home/algol/projects/isol153_identity/gtdbtk_classify_retry \
  -x fa \
  --cpus 28
```

### Issues encountered

**1. Output directory reuse bug**

Reusing the same `--out_dir` across retries triggered an internal error:

```text
ANIScreenStep.__init__() got an unexpected keyword argument 'name'
```

**Workaround**: always use a fresh output directory for each attempt.

**2. Memory limitations during pplacer**

The bacterial pplacer step requires ~55 GB RAM. The WSL2 environment exposed ~31.6 GB, causing instability during backbone/class-level phylogenetic placement.

**3. pplacer placement failure**

The final error was:

```text
pplacer.class_level.bac120.json has no placements
```

### Why this does not affect the project's conclusions

The failure occurred during the **phylogenetic placement** stage of `classify_wf`, not during the ANI computation. The ANI-based genus placement from `ani_rep` is independent of pplacer and remains the most reliable taxonomic result from this workflow. For this project — where the key question is whether Isol153 belongs to a represented species cluster — the `ani_rep` result is sufficient.

---

## Troubleshooting

### CheckM2: "No bins found"

If CheckM2 returns `No bins found. Check the extension (-x) used to identify bins`, either:

- Provide the `.fa` file directly as `--input` (recommended), or
- Use a directory as `--input` and add `-x fa`

### GTDB-Tk: "Input directory does not exist"

`--genome_dir` must point to a **directory** containing genome files, not to a genome file directly.

Correct:
```bash
--genome_dir /home/algol/projects/isol153_identity/genome
```

Wrong:
```bash
--genome_dir /home/algol/projects/isolates/Isol153.fa
```

### GTDB-Tk: extension mismatch

If your genome file uses `.fa` instead of `.fna` or `.fasta`, you must pass `-x fa` to both `ani_rep` and `classify_wf`. Without this flag, GTDB-Tk silently finds zero genomes and produces empty output.
