# Anvi'o pangenome analysis workflow

This document describes the anvi'o pangenome workflow used to compare Isol153 with three other eelgrass-associated *Vibrio* isolates, each representing a different species-level group identified in the KBase phylogeny.

The outputs of this workflow support **Figure 2** of the poster.

---

## Purpose

The pangenome analysis was designed to answer three questions:

1. Which gene clusters are **shared** among all four isolates (core genome)?
2. Which gene clusters are **variable** — present in some genomes but not others (accessory/singleton)?
3. Does Isol153 carry **lineage-specific gene content** that could help explain its consistent metagenomic recruitment?

The key finding: Isol153 retains a conserved shared genomic backbone with the other isolates, but its differences are concentrated in accessory and singleton-like gene-cluster regions — not distributed across the entire genome.

---

## Software and environment

| Tool | Purpose |
|---|---|
| anvi'o (v9) | Pangenome construction, visualization, and functional annotation |
| KOfam / KEGG | Functional annotation of predicted genes |

```bash
conda activate anvio-9
```

---

## Input genomes

Four isolates were selected for comparison, each representing a **different species-level cluster** from the KBase phylogeny (see [`docs/phylogeny_workflow.md`](phylogeny_workflow.md)):

| Isolate | Role |
|---|---|
| **Isol153** | Focal isolate (strongest recruitment signal) |
| Isol88 | Representative of a separate species-level cluster |
| Isol104 | Representative of a separate species-level cluster |
| Isol129 | Representative of a separate species-level cluster |

Input FASTA files were placed in:

```text
/home/algol/projects/anvio_isol153/fasta/
├── Isol88.fa
├── Isol104.fa
├── Isol129.fa
└── Isol153.fa
```

---

## Workflow overview

The anvi'o pangenome pipeline has many steps, but they follow a clear logic:

```text
FASTA files
  │
  ▼
Step 1–2: Reformat → Contigs databases (one per genome)
  │
  ▼
Step 3–4: Annotate each database (HMMs + KOfam)
  │
  ▼
Step 5–6: Combine into genomes storage → Run pangenome
  │
  ▼
Step 7–8: Visualize and export figure
```

| Step | Command | What it does |
|---|---|---|
| 1 | `anvi-script-reformat-fasta` | Simplify FASTA headers (anvi'o requirement) |
| 2 | `anvi-gen-contigs-database` | Build per-genome database with gene calls |
| 3 | `anvi-run-hmms` | Identify single-copy core genes and HMM features |
| 4 | `anvi-run-kegg-kofams` | Annotate genes against KOfam/KEGG |
| 5 | `anvi-gen-genomes-storage` | Combine all genomes into one storage file |
| 6 | `anvi-pan-genome` | Cluster genes across genomes → pangenome |
| 7 | `anvi-display-pan` | Launch interactive pangenome viewer |
| 8 | Export | Save figure as SVG/PNG for poster |

---

## Step 1. Reformat FASTA files

anvi'o requires simple, clean FASTA headers (no spaces, no special characters). If the original headers contain long descriptions, `anvi-gen-contigs-database` will fail.

```bash
cd /home/algol/projects/anvio_isol153/fasta

for ISOLATE in Isol88 Isol104 Isol129 Isol153; do
    anvi-script-reformat-fasta ${ISOLATE}.fa \
      -o ${ISOLATE}_reformatted.fa \
      --simplify-names
done
```

This produces `Isol88_reformatted.fa`, `Isol104_reformatted.fa`, etc.

---

## Step 2. Generate contigs databases

One contigs database per genome. This is where anvi'o calls genes (using Prodigal by default) and stores them for downstream analysis.

```bash
mkdir -p /home/algol/projects/anvio_isol153/contigs_db
cd /home/algol/projects/anvio_isol153/contigs_db

for ISOLATE in Isol88 Isol104 Isol129 Isol153; do
    anvi-gen-contigs-database \
      -f /home/algol/projects/anvio_isol153/fasta/${ISOLATE}_reformatted.fa \
      -o ${ISOLATE}.db \
      --project-name ${ISOLATE} \
      -T 12
done
```

Output: `Isol88.db`, `Isol104.db`, `Isol129.db`, `Isol153.db`

---

## Step 3. Run HMMs

Identifies single-copy core genes and other conserved features in each genome. anvi'o uses these for genome completeness estimates and downstream summaries. Skipping this step won't break the pangenome, but anvi'o will warn about missing HMM data.

```bash
cd /home/algol/projects/anvio_isol153/contigs_db

for ISOLATE in Isol88 Isol104 Isol129 Isol153; do
    anvi-run-hmms -c ${ISOLATE}.db -T 12
done
```

---

## Step 4. Run KOfam / KEGG functional annotation

Annotates predicted genes against KOfam (KEGG Orthology HMM profiles). This is critical — without this step, the pangenome visualization would show gene-cluster structure but no functional labels.

```bash
cd /home/algol/projects/anvio_isol153/contigs_db

for ISOLATE in Isol88 Isol104 Isol129 Isol153; do
    anvi-run-kegg-kofams -c ${ISOLATE}.db -T 12
done
```

The KOfam annotations are used for:

- Functional layers in the pangenome visualization
- Identifying candidate functions in Isol153-specific gene clusters
- Downstream KOfam-based functional comparison (see [`docs/functional_comparison_workflow.md`](functional_comparison_workflow.md))

---

## Step 5. Create external genomes file and genomes storage

anvi'o needs a tab-separated file telling it where each contigs database lives.

**`external-genomes.txt`**:

```tsv
name	contigs_db_path
Isol88	/home/algol/projects/anvio_isol153/contigs_db/Isol88.db
Isol104	/home/algol/projects/anvio_isol153/contigs_db/Isol104.db
Isol129	/home/algol/projects/anvio_isol153/contigs_db/Isol129.db
Isol153	/home/algol/projects/anvio_isol153/contigs_db/Isol153.db
```

Then combine all genomes into a single storage database:

```bash
cd /home/algol/projects/anvio_isol153

anvi-gen-genomes-storage \
  -e external-genomes.txt \
  -o ISOL153-4-GENOMES.db
```

Summary from this project:

| Metric | Value |
|---|---|
| Number of genomes | 4 |
| Total gene calls | 17,749 |
| Partial gene calls | 55 |

Approximate gene counts per genome:

| Genome | Gene calls |
|---|---|
| Isol88 | 4,817 |
| Isol153 | 4,705 |
| Isol104 | 4,284 |
| Isol129 | 3,943 |

---

## Step 6. Run pangenome analysis

This is the core step — anvi'o clusters genes from all four genomes into **gene clusters** based on sequence similarity, then organizes them by presence/absence pattern.

```bash
cd /home/algol/projects/anvio_isol153

anvi-pan-genome \
  -g ISOL153-4-GENOMES.db \
  -o PAN_OUT \
  --project-name ISOL153_4PAN \
  --num-threads 12
```

Output:

```text
PAN_OUT/ISOL153_4PAN-PAN.db
```

Summary:

| Metric | Value |
|---|---|
| Gene clusters initialized | 6,198 |
| Functional annotations | KOfam, KEGG_BRITE, KEGG_Class, KEGG_Module |
| Homogeneity estimates | functional, geometric, combined |

---

## Step 7. Visualize the pangenome

```bash
anvi-display-pan \
  -p PAN_OUT/ISOL153_4PAN-PAN.db \
  -g ISOL153-4-GENOMES.db \
  -I localhost
```

Then open in a browser:

```text
http://localhost:8080
```

> **WSL note**: the terminal may show `xdg-open: no method available for opening ...`. This is normal — WSL cannot auto-launch a browser. Just open `http://localhost:8080` manually in your Windows browser.

### Display configuration for poster

The anvi'o interface shows many layers by default. For the poster figure, the display was simplified:

**Layers shown**:

- Isol88, Isol104, Isol129, Isol153 (gene-cluster presence/absence rings)
- Num contributing genomes
- KOfam
- Functional / Geometric / Combined homogeneity

**Layers hidden** (too detailed for a poster):

- Min/Max/Avg AAI, Total length, GC content, Completion, Redundancy

---

## Step 8. Export poster figure

The final visualization was exported from the anvi'o browser interface as SVG and/or high-resolution PNG:

```text
figures/figure2_pangenome.svg
figures/figure2_pangenome.png
```

SVG is preferred for poster use because it scales without quality loss.

---

## How to read the pangenome figure

The circular anvi'o pangenome display can look overwhelming at first. Here is how to interpret it:

- **Each ring** represents one genome (Isol88, Isol104, Isol129, Isol153).
- **Each radial segment** represents one gene cluster.
- A **filled segment** means that genome contributes at least one gene to that cluster; a **gap** means it does not.
- **Gene clusters present in all 4 genomes** = core genome (shared backbone).
- **Gene clusters present in 2–3 genomes** = accessory genome (variable content).
- **Gene clusters present in only 1 genome** = singleton-like (lineage-specific).

The poster interpretation focuses on the contrast: Isol153 shares a large core genome with the other three species representatives, but also carries a substantial number of singleton-like and accessory gene clusters — especially in regions annotated with carbohydrate utilization, surface colonization, and stress/plasticity functions.

---

## Why these decisions were made

### Why anvi'o and not Roary, PIRATE, or PPanGGOLiN?

anvi'o provides an integrated environment where gene-cluster construction, functional annotation, and interactive visualization happen in one tool. For a four-genome comparison, the interactive display is especially valuable — you can visually identify which gene clusters are Isol153-specific and immediately check their KOfam annotations. Roary and PIRATE are designed for larger datasets (dozens to hundreds of genomes) and produce static output that requires separate visualization.

### Why four genomes and not more?

Each of the four isolates represents a different species-level cluster from the KBase phylogeny. This design captures **inter-species** variation: gene clusters unique to Isol153 in this comparison are absent from representatives of three other eelgrass-associated *Vibrio* species, making them stronger candidates for lineage-specific ecological function. Adding more genomes from the same species clusters would shift the analysis toward within-species strain variation, which is a different question.

### Why KOfam annotation specifically?

KOfam (KEGG Orthology HMM profiles) provides standardized functional categories that are widely used in microbial ecology. Unlike COG or Pfam, KOfam maps directly to KEGG pathways and modules, making it straightforward to group Isol153-specific genes into ecologically interpretable categories (carbohydrate metabolism, transport, biofilm, stress response). anvi'o integrates KOfam annotation natively, so the results appear directly as layers in the pangenome visualization.

### Why are singleton gene clusters not automatically "real"?

A gene cluster found only in Isol153 could represent:

- **True lineage-specific content** — a gene genuinely absent from the other three species
- **A missing close relative** — if a fifth genome closely related to Isol153 were added, the "singleton" might become shared
- **Assembly or annotation artifact** — fragmented contigs or different gene-calling behavior can create apparent singletons

This is why the poster describes these as **candidate** functions rather than confirmed Isol153-specific traits. The functional comparison workflow (see [`docs/functional_comparison_workflow.md`](functional_comparison_workflow.md)) applies additional filtering to focus on the most interpretable candidates.

---

## Output summary

| Output | Path | Description |
|---|---|---|
| Contigs databases | `contigs_db/Isol*.db` | Per-genome databases with gene calls and annotations |
| Genomes storage | `ISOL153-4-GENOMES.db` | Combined genome storage for pangenome |
| Pan database | `PAN_OUT/ISOL153_4PAN-PAN.db` | Pangenome gene-cluster results |
| Poster figure | `figures/figure2_pangenome.svg` | Exported pangenome visualization |

---

## Notes and limitations

- The pangenome was built from four selected isolates, not all 19 in the collection. It is not intended to represent the full species-level pangenome of any *Vibrio* lineage.
- Functional annotations are sequence-based predictions (KOfam HMM hits) and should be interpreted as candidate functions, not experimentally validated traits.
- Singleton-like gene clusters may reflect true lineage-specific content, missing close relatives, or assembly/annotation artifacts.
- The pangenome figure is useful for structural comparison, but ecological interpretation requires the functional annotation and enrichment analysis described in [`docs/functional_comparison_workflow.md`](functional_comparison_workflow.md).

---

## Related workflows

- Metagenomic recruitment mapping: [`docs/mapping_workflow.md`](mapping_workflow.md)
- Phylogenetic tree construction: [`docs/phylogeny_workflow.md`](phylogeny_workflow.md)
- Isol153 taxonomy placement: [`docs/checkm2_gtdb_workflow.md`](checkm2_gtdb_workflow.md)
- Functional comparison: [`docs/functional_comparison_workflow.md`](functional_comparison_workflow.md)
