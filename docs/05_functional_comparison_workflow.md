# KOfam functional comparison and visualization workflow

This document describes the KOfam-based functional comparison used to identify candidate Isol153-specific functions and visualize them as a presence/absence heatmap.

The outputs of this workflow support **Figure 3** of the poster.

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
| R + ggplot2 | Generate the presence/absence heatmap |

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

The four genomes were split into two groups for the enrichment test:

| Genome | Group | Role |
|---|---|---|
| Isol153 | `isol153` | Focal isolate |
| Isol88 | `other` | Species representative (comparator) |
| Isol104 | `other` | Species representative (comparator) |
| Isol129 | `other` | Species representative (comparator) |

This is a **1-vs-3 screening design**, not a powered statistical test. With only one genome in the focal group, there is no within-group replication — so the enrichment results should be interpreted as **candidate screening**, not as proof of statistically significant enrichment.

The design asks a specific question: *what does Isol153 have that representatives of three other eelgrass-associated Vibrio species do not?*

---

## Step 1. Create the group file

Create a tab-separated file defining the group assignments:

```bash
mkdir -p /home/algol/projects/anvio_isol153/functional_comparison
cd /home/algol/projects/anvio_isol153/functional_comparison

cat > isol153_vs_others_groups.txt <<EOF
name	group
Isol88	other
Isol104	other
Isol129	other
Isol153	isol153
EOF
```

The `name` column must exactly match the genome names in `external-genomes.txt`.

---

## Step 2. Run functional enrichment

```bash
anvi-compute-functional-enrichment-across-genomes \
  -e /home/algol/projects/anvio_isol153/external-genomes.txt \
  -G /home/algol/projects/anvio_isol153/functional_comparison/isol153_vs_others_groups.txt \
  --annotation-source KOfam \
  -o /home/algol/projects/anvio_isol153/functional_comparison/isol153_vs_others.enrichment.txt \
  --functional-occurrence-table-output /home/algol/projects/anvio_isol153/functional_comparison/isol153_vs_others.function_counts.txt
```

### What this command does internally

1. For each of the four contigs databases, it reads all KOfam annotations (added earlier by `anvi-run-kegg-kofams`).
2. For each KO function, it builds a presence/absence vector across the four genomes.
3. It tests whether each function is **enriched** in one group relative to the other, using a statistical framework based on the GLM approach described in the anvi'o functional enrichment tutorial.
4. It outputs two files.

### Output files

**`isol153_vs_others.enrichment.txt`** — the main results table. Each row is one KOfam function, with columns for:

- KO accession and function name
- which group the function is associated with (`isol153` or `other`)
- occurrence proportions in each group (`p_isol153`, `p_other`)
- enrichment score and adjusted p-value

**`isol153_vs_others.function_counts.txt`** — a simpler occurrence matrix showing which functions appear in which genomes. Useful for manual inspection and downstream filtering.

---

## Step 3. Screen for Isol153-specific candidate functions

From the enrichment table, candidate functions were selected using the following criteria:

| Filter | Value | Meaning |
|---|---|---|
| `p_isol153` | = 1 | Function is present in Isol153 |
| `p_other` | = 0 | Function is absent from all three comparators |
| `associated_groups` | = `isol153` | Enrichment test associates this function with the Isol153 group |

This is the strictest possible filter: **present in Isol153, absent from Isol88, Isol104, and Isol129**. Functions present in Isol153 plus one or two comparators were excluded to focus on the clearest candidates.

### Important caveat

"Isol153-specific" here means **specific relative to this three-genome comparison set**. It does **not** mean the function is unique to Isol153 across all *Vibrio* globally. A broader comparison panel would likely reclassify some of these as shared with other *Vibrio* lineages not included in this project.

---

## Step 4. Group candidate functions into ecological categories

The candidate functions were manually grouped into three ecological categories based on their KOfam descriptions and KEGG pathway assignments. This grouping is an **interpretive step** — it reflects the authors' ecological reasoning, not an automated classification.

### Category 1: Carbohydrate utilization / transport

| Candidate function | Ecological relevance |
|---|---|
| Beta-agarase | Agar degradation — agar is a major polysaccharide in marine algae and eelgrass epiphytes |
| Beta-glucoside PTS system | Uptake of beta-glucosides (plant-derived sugars) |
| Lactose permease (MFS) | Broad-specificity sugar transporter |
| Maltose PTS system | Maltose uptake |
| Simple sugar transporter | General monosaccharide import |

**Ecological interpretation**: Isol153 may have a broader carbohydrate utilization repertoire than the other three species representatives, potentially allowing it to exploit a wider range of carbon sources in the eelgrass phyllosphere.

### Category 2: Surface colonization / biofilm

| Candidate function | Ecological relevance |
|---|---|
| Accessory colonization factor AcfD | Known colonization factor in *Vibrio cholerae*; may facilitate host surface attachment |
| Biofilm biosynthesis protein VpsM | Vibrio polysaccharide synthesis — biofilm matrix component |
| Biofilm biosynthesis protein VpsN | Same pathway as VpsM |
| Colanic acid biosynthesis WcaI | Exopolysaccharide biosynthesis — protective surface layer |

**Ecological interpretation**: these functions suggest enhanced capacity for surface attachment and biofilm formation, which could contribute to persistence on eelgrass leaf surfaces.

### Category 3: Stress response / plasticity

| Candidate function | Ecological relevance |
|---|---|
| Competence protein CoiA | Natural competence (DNA uptake from environment) — a source of genomic plasticity |
| DNA repair helicase HerA | DNA damage repair under stress |
| Immunomodulating metalloprotease | May interact with host immune-like defenses |
| Toxin-antitoxin system (YefM/YoeB) | Stress-responsive growth arrest — can help cells survive antibiotic exposure or nutrient starvation |

**Ecological interpretation**: these functions suggest enhanced stress tolerance and genome plasticity, which could help Isol153 persist under the fluctuating conditions of the eelgrass phyllosphere (UV, salinity shifts, tidal cycles).

---

## Step 5. Visualization

The candidate functions were visualized as a **horizontal presence/absence heatmap** using R and ggplot2.

### Input

A manually curated CSV file summarizing the selected candidate functions:

```text
functional_comparison/heatmap_data_simplified.csv
```

This file contains one row per genome group × function combination, with columns for genome group, function name, ecological category, and presence/absence (0 or 1).

### Output

```text
figures/Isol153_vs_Others_Horizontal.pdf
figures/Isol153_vs_Others_Horizontal.png
```

### How to read the heatmap

- **Rows**: two genome groups — "Isol153" and "Other Close Relatives"
- **Columns**: candidate functions, grouped by ecological category (carbohydrate/transport, surface/colonization, stress/plasticity)
- **Fill color**: 0 = absent (light), 1 = present (dark)

The visual pattern is straightforward: the "Other Close Relatives" row is mostly light (absent), and the "Isol153" row is entirely dark (present). This is by design — the screening in Step 3 selected only functions with this exact pattern.

**This is not an expression heatmap or an abundance heatmap.** It is a binary presence/absence summary based on KOfam annotation.

---

## Why these decisions were made

### Why KOfam enrichment and not just eyeballing the pangenome?

The pangenome visualization (Figure 2) shows **structural** differences — which gene clusters are shared or variable. But a gene cluster is defined by sequence similarity, not by function. Two genes in different gene clusters might have the same KOfam annotation (same function, divergent sequence), or one gene cluster might contain genes with different functions across genomes. KOfam enrichment operates at the **functional level**, asking "does Isol153 have function X?" rather than "does Isol153 have gene cluster Y?" This is more directly interpretable in ecological terms.

### Why a 1-vs-3 design instead of a proper statistical enrichment?

With only four genomes and one in the focal group, there is no statistical power for a formal enrichment test in the traditional sense. The anvi'o enrichment framework still runs and produces p-values, but with n=1 in one group, these should be treated as **descriptive scores** rather than rigorous hypothesis tests. The 1-vs-3 design was chosen because it matches the biological question — "what is distinctive about Isol153 specifically?" — and because the available genome set consisted of one representative per species-level cluster.

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
| Enrichment table | `functional_comparison/isol153_vs_others.enrichment.txt` | Full KOfam enrichment results |
| Occurrence table | `functional_comparison/isol153_vs_others.function_counts.txt` | Per-genome function occurrence matrix |
| Curated candidates | `functional_comparison/isol153_candidate_functions_with_modules.tsv` | Filtered candidates with ecological categories |
| Heatmap input | `functional_comparison/heatmap_data_simplified.csv` | Simplified data for R visualization |
| Poster figure | `figures/Isol153_vs_Others_Horizontal.pdf` | Figure 3 heatmap |

---

## Notes and limitations

- All functional annotations are **sequence-based predictions** (KOfam HMM hits). They represent candidate functions, not experimentally validated traits.
- "Isol153-specific" refers only to the selected comparison set. Expanding the comparison to additional *Vibrio* genomes would likely reclassify some candidates as more broadly shared.
- The 1-vs-3 design provides candidate screening, not statistically powered enrichment. Results should be interpreted accordingly.
- The ecological categories (carbohydrate, colonization, stress) are manually assigned based on the authors' interpretation and should be treated as hypotheses for future testing.
- Future work should include expanded comparative genomics, gene-neighborhood analysis, metagenomic coverage of specific loci, and experimental validation of predicted traits.

---

## Related workflows

- Pangenome analysis: [`docs/pangenome_workflow.md`](pangenome_workflow.md)
- Phylogenetic tree construction: [`docs/phylogeny_workflow.md`](phylogeny_workflow.md)
- Isol153 taxonomy placement: [`docs/checkm2_gtdb_workflow.md`](checkm2_gtdb_workflow.md)
- Metagenomic recruitment mapping: [`docs/mapping_workflow.md`](mapping_workflow.md)
