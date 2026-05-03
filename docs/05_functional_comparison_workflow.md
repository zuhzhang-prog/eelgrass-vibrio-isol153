# KOfam functional comparison and visualization workflow

This document describes the KOfam-based functional comparison used to identify candidate Isol153-specific functions and visualize them as a presence/absence heatmap.

The outputs of this workflow support **Figure 3** of the poster.

> **Where is the code?**
> All executable code lives in `scripts/05_functional_comparison/`. This document explains *what* each step does and *why* it was designed that way. For the actual commands, read the scripts directly — they are the single source of truth.

---

## Purpose

The pangenome analysis (see [`docs/pangenome_workflow.md`](pangenome_workflow.md)) showed that Isol153 carries substantial accessory and singleton-like gene-cluster content. But knowing that gene clusters are "different" is not the same as knowing *what they do*. This workflow takes the next step: it asks **what functional traits does Isol153 carry that the other three species representatives do not?**

Specifically:

1. Which KOfam-annotated functions are **present in Isol153 but absent from all three comparators**?
2. Do these candidate functions cluster into **interpretable ecological categories**?
3. Can they provide a **plausible genomic explanation** for why Isol153 was repeatedly detected across focal eelgrass-associated metagenomes?

---

## Software and environment

This workflow uses the same anvi'o v9 environment as the pangenome analysis, plus R for visualization:

```bash
conda activate anvio-9
```

| Tool | Purpose |
|---|---|
| `anvi-compute-functional-enrichment-across-genomes` | Compare KOfam occurrence across genome groups |
| R + ggplot2 / tidyverse | Candidate extraction, data preparation, and heatmap visualization |

No additional installation is needed beyond the anvi'o environment set up in [`docs/pangenome_workflow.md`](pangenome_workflow.md) — R and tidyverse were already installed as anvi'o dependencies.

---

## Input data

This workflow does **not** re-run KOfam annotation. It builds on the contigs databases that were already annotated with `anvi-run-kegg-kofams` during the pangenome workflow.

Required inputs from the pangenome workflow:

```text
/home/algol/projects/anvio_isol153/
├── external-genomes.txt              # points to the 4 contigs databases
├── contigs_db/
│   ├── Isol88.db                     # already KOfam-annotated
│   ├── Isol104.db
│   ├── Isol129.db
│   └── Isol153.db
└── functional_comparison/            # created in this workflow
```

---

## Comparison design: 1 vs 3

The four genomes were split into two groups:

| Genome | Group | Role |
|---|---|---|
| Isol153 | `isol153` | Focal isolate |
| Isol88 | `other` | Species representative (comparator) |
| Isol104 | `other` | Species representative (comparator) |
| Isol129 | `other` | Species representative (comparator) |

This is a **1-vs-3 screening design**, not a powered statistical test. With only one genome in the focal group, there is no within-group replication — so the results should be interpreted as **candidate screening**, not as proof of statistically significant enrichment.

The design asks a specific question: *what does Isol153 have that representatives of three other eelgrass-associated Vibrio species do not?*

---

## Pipeline overview

The workflow has five logical steps, split across automated scripts and one manually maintained curation table:

| Step | Script | What it does | Automated? |
|---|---|---|---|
| 1. Create group file | `01_make_groups_file.sh` | Defines the 1-vs-3 comparison | Yes |
| 2. Run functional comparison | `02_run_functional_enrichment.sh` | Runs anvi'o KOfam comparison → enrichment table | Yes |
| 3. Extract candidates | `03_extract_isol153_candidates.R` | Filters enrichment table for Isol153-specific functions | Yes |
| 4. Curate for Figure 3 | `04_prepare_figure3_heatmap_data.R` + `metadata/figure3_candidate_curation.tsv` | Matches candidates to display labels and ecological categories | **Semi-auto** |
| 5. Plot heatmap | `05_plot_figure3_heatmap.R` | Generates Figure 3 PDF and PNG | Yes |

A master script runs all steps in sequence:

```bash
conda activate anvio-9
cd ~/github/eelgrass-vibrio-isol153
bash scripts/05_functional_comparison/06_run_all.sh
```

Shared paths are defined in `00_config.sh` and sourced by all bash scripts.

---

## Step 1. Create the group file

**Script**: `scripts/05_functional_comparison/01_make_groups_file.sh`

Creates a tab-separated file defining the group assignments. The `name` column must exactly match the genome names in `external-genomes.txt`.

Output:

```text
functional_comparison/isol153_vs_others_groups.txt
```

---

## Step 2. Run functional comparison

**Script**: `scripts/05_functional_comparison/02_run_functional_enrichment.sh`

Runs `anvi-compute-functional-enrichment-across-genomes` using KOfam as the annotation source. The script checks that both the external genomes file and the group file exist before proceeding.

### What this command does internally

1. For each of the four contigs databases, it reads all KOfam annotations (added earlier by `anvi-run-kegg-kofams`).
2. For each KO function, it builds a presence/absence vector across the four genomes.
3. It computes enrichment scores using a GLM-based framework. However, with n=1 in the focal group, these scores should be treated as **descriptive indicators**, not rigorous hypothesis tests.
4. It outputs two files.

### Output files

**`isol153_vs_others.enrichment.txt`** — the main results table. Each row is one KOfam function, with columns for KO accession, function name, associated group, occurrence proportions (`p_isol153`, `p_other`), enrichment score, and adjusted p-value.

**`isol153_vs_others.function_counts.txt`** — a simpler occurrence matrix showing which functions appear in which genomes.

---

## Step 3. Extract Isol153-specific candidate functions

**Script**: `scripts/05_functional_comparison/03_extract_isol153_candidates.R`

This step was previously performed manually by inspecting the enrichment table. It is now automated as an R script that filters the enrichment output using the following criteria:

| Filter | Value | Meaning |
|---|---|---|
| `p_isol153` | = 1 | Function is present in Isol153 |
| `p_other` | = 0 | Function is absent from all three comparators |
| `associated_groups` | contains `isol153` | Comparison associates this function with the Isol153 group |

This is the strictest possible filter: **present in Isol153, absent from Isol88, Isol104, and Isol129**. The script prints a summary of how many candidates pass the filter and previews the first 10.

Output:

```text
functional_comparison/isol153_candidate_functions_all.tsv
```

This file may contain dozens of candidate functions. Not all of them are equally interpretable or suitable for a poster figure — that is what Step 4 addresses.

### Important caveat

"Isol153-specific" here means **specific relative to this three-genome comparison set**. It does **not** mean the function is unique to Isol153 across all *Vibrio* globally. A broader comparison panel would likely reclassify some of these as shared with other *Vibrio* lineages not included in this project.

---

## Step 4. Curate candidate functions for Figure 3

**Script**: `scripts/05_functional_comparison/04_prepare_figure3_heatmap_data.R`
**Curation table**: `metadata/figure3_candidate_curation.tsv`

This is the **only semi-automated step** in the workflow. It bridges the automated screening (Step 3) and the visualization (Step 5) by selecting which candidate functions to show in the poster figure and assigning them display labels and ecological categories.

### How it works

The curation table (`metadata/figure3_candidate_curation.tsv`) is a manually maintained file with four columns:

| Column | Purpose | Example |
|---|---|---|
| `function_keyword` | Regex pattern to match against candidate function names | `agarase`, `VpsM`, `YefM\|YoeB` |
| `display_label` | Clean name shown in the heatmap | `Beta-agarase (Agar degradation)` |
| `category` | Ecological category for faceting | `Carbohydrate/Transport` |
| `include_in_figure` | Whether to include this function | `yes` or `no` |

The R script reads both the automated candidate list and the curation table, then uses keyword matching (`str_detect` with regex) to link each curated entry to its corresponding candidate function. It prints a match log (`[OK]` or `[MISS]` for each keyword) so you can verify that each keyword matched the intended function and catch false positives.

### Why separate the curation from the code?

In the previous version of this workflow, the 13 poster functions were hard-coded directly in an R script. This made it impossible to tell which functions came from the enrichment output and which were manually chosen. The new design separates the two concerns:

- **Automated screening** (`03_extract`): reproducible, code-driven, filters by objective criteria
- **Manual curation** (`metadata/figure3_candidate_curation.tsv`): transparent, editable, documents the interpretive choices

If the enrichment results change (e.g., new genomes added, KOfam database updated), the automated candidates will update automatically. The curation table may then need to be reviewed, but the separation makes it clear exactly what needs human attention.

### Outputs

```text
functional_comparison/figure3_matched_candidate_functions.tsv   # full match details (for audit)
functional_comparison/figure3_heatmap_data.tsv                  # simplified input for plotting
```

### Ecological categories

The curated candidates are grouped into three categories:

#### Category 1: Carbohydrate utilization / transport

| Candidate function | Ecological relevance |
|---|---|
| Beta-agarase | Agar degradation — agar is a major polysaccharide in marine algae and eelgrass epiphytes |
| Beta-glucoside PTS system | Uptake of beta-glucosides (plant-derived sugars) |
| Lactose permease (MFS) | Broad-specificity sugar transporter |
| Maltose PTS system | Maltose uptake |
| Simple sugar transporter | General monosaccharide import |

**Ecological interpretation**: Isol153 may have a broader carbohydrate utilization repertoire, potentially allowing it to exploit a wider range of carbon sources in the eelgrass phyllosphere.

#### Category 2: Surface colonization / biofilm

| Candidate function | Ecological relevance |
|---|---|
| Accessory colonization factor AcfD | Known colonization factor in *Vibrio cholerae*; may facilitate host surface attachment |
| Biofilm biosynthesis protein VpsM | Vibrio polysaccharide synthesis — biofilm matrix component |
| Biofilm biosynthesis protein VpsN | Same pathway as VpsM |
| Colanic acid biosynthesis WcaI | Exopolysaccharide biosynthesis — protective surface layer |

**Ecological interpretation**: these functions suggest enhanced capacity for surface attachment and biofilm formation, which could contribute to persistence on eelgrass leaf surfaces.

#### Category 3: Stress response / plasticity

| Candidate function | Ecological relevance |
|---|---|
| Competence protein CoiA | Natural competence (DNA uptake from environment) — a source of genomic plasticity |
| DNA repair helicase HerA | DNA damage repair under stress |
| Immunomodulating metalloprotease | May interact with host immune-like defenses |
| Toxin-antitoxin system (YefM/YoeB) | Stress-responsive growth arrest — can help cells survive antibiotic exposure or nutrient starvation |

**Ecological interpretation**: these functions suggest enhanced stress tolerance and genome plasticity, which could help Isol153 persist under the fluctuating conditions of the eelgrass phyllosphere (UV, salinity shifts, tidal cycles).

---

## Step 5. Visualization

**Script**: `scripts/05_functional_comparison/05_plot_figure3_heatmap.R`

The curated candidate functions are visualized as a **horizontal presence/absence heatmap** using R and ggplot2.

### How to read the heatmap

- **Rows**: two genome groups — "Isol153" and "Other Close Relatives"
- **Columns**: candidate functions, grouped by ecological category
- **Fill color**: 0 = absent (light), 1 = present (dark)

The visual pattern is straightforward: the "Other Close Relatives" row is mostly light (absent), and the "Isol153" row is entirely dark (present). This is by design — the screening in Step 3 selected only functions with this exact pattern.

**This is not an expression heatmap or an abundance heatmap.** It is a binary presence/absence summary based on KOfam annotation.

### Output

```text
functional_comparison/Isol153_vs_Others_Horizontal.pdf
functional_comparison/Isol153_vs_Others_Horizontal.png
```

---

## Why these decisions were made

### Why KOfam comparison and not just eyeballing the pangenome?

The pangenome visualization (Figure 2) shows **structural** differences — which gene clusters are shared or variable. But a gene cluster is defined by sequence similarity, not by function. Two genes in different gene clusters might have the same KOfam annotation (same function, divergent sequence), or one gene cluster might contain genes with different functions across genomes. KOfam comparison operates at the **functional level**, asking "does Isol153 have function X?" rather than "does Isol153 have gene cluster Y?" This is more directly interpretable in ecological terms.

### Why a 1-vs-3 design instead of a proper statistical enrichment?

With only four genomes and one in the focal group, there is no statistical power for a formal enrichment test in the traditional sense. The anvi'o framework still runs and produces p-values, but with n=1 in one group, these should be treated as **descriptive scores** rather than rigorous hypothesis tests. The 1-vs-3 design was chosen because it matches the biological question — "what is distinctive about Isol153 specifically?" — and because the available genome set consisted of one representative per species-level cluster.

A more powerful design would require multiple genomes per group (e.g., 5 Isol153-like genomes vs 5 genomes from each of the other species). This is noted as a future direction in the poster.

### Why manual ecological categorization?

KEGG provides pathway and module classifications, but these are optimized for model organisms and metabolic completeness, not for ecological interpretation of marine epiphytes. The three categories (carbohydrate/transport, surface colonization, stress/plasticity) were chosen because they map directly onto hypotheses about **why** a *Vibrio* lineage might persist on eelgrass surfaces: it needs to eat (carbohydrates), stick (colonization), and survive (stress). This framing makes the results interpretable at poster level without requiring the audience to navigate KEGG pathway maps.

### Why presence/absence and not abundance or expression?

This project uses genome-derived KOfam annotation, which tells you whether a gene encoding a given function **exists in the genome**. It does not tell you whether the gene is expressed, how highly it is expressed, or how much protein it produces. A binary heatmap honestly represents this level of evidence. Showing a gradient or continuous scale would imply quantitative information that the data does not support.

---

## Output summary

| Output | Path | Description |
|---|---|---|
| Group file | `functional_comparison/isol153_vs_others_groups.txt` | 1-vs-3 group assignments |
| Enrichment table | `functional_comparison/isol153_vs_others.enrichment.txt` | Full KOfam comparison results |
| Occurrence table | `functional_comparison/isol153_vs_others.function_counts.txt` | Per-genome function occurrence matrix |
| All candidates | `functional_comparison/isol153_candidate_functions_all.tsv` | Automated screening output (all candidates passing filter) |
| Match details | `functional_comparison/figure3_matched_candidate_functions.tsv` | Curation keyword → candidate function match log |
| Heatmap input | `functional_comparison/figure3_heatmap_data.tsv` | Simplified input for heatmap plotting |
| Curation table | `metadata/figure3_candidate_curation.tsv` | Manually maintained display labels and categories |
| Poster figure | `functional_comparison/Isol153_vs_Others_Horizontal.pdf` | Figure 3 heatmap |

---

## Notes and limitations

- All functional annotations are **sequence-based predictions** (KOfam HMM hits). They represent candidate functions, not experimentally validated traits.
- "Isol153-specific" refers only to the selected comparison set. Expanding the comparison to additional *Vibrio* genomes would likely reclassify some candidates as more broadly shared.
- The 1-vs-3 design provides candidate screening, not statistically powered enrichment. Results should be interpreted accordingly.
- The ecological categories (carbohydrate, colonization, stress) are manually assigned based on the authors' interpretation and should be treated as hypotheses for future testing.
- The curation table (`metadata/figure3_candidate_curation.tsv`) uses keyword matching, which may produce false positives if keywords are too broad. The match log (`figure3_matched_candidate_functions.tsv`) should be reviewed after each run.
- Future work should include expanded comparative genomics, gene-neighborhood analysis, metagenomic coverage of specific loci, and experimental validation of predicted traits.

---

## Related workflows

- Pangenome analysis: [`docs/pangenome_workflow.md`](pangenome_workflow.md)
- Phylogenetic tree construction: [`docs/phylogeny_workflow.md`](phylogeny_workflow.md)
- Isol153 taxonomy placement: [`docs/checkm2_gtdb_workflow.md`](checkm2_gtdb_workflow.md)
- Metagenomic recruitment mapping: [`docs/mapping_workflow.md`](mapping_workflow.md)
