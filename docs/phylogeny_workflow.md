# Phylogeny workflow

This document describes the KBase-based workflow used to explore evolutionary relationships among 19 eelgrass-associated *Vibrio* isolate genomes.

The resulting species tree provided a phylogenetic framework for interpreting downstream metagenomic recruitment patterns and for selecting isolates for pangenome comparison. This step was exploratory — it was not intended to make final taxonomic assignments.

---

## Platform

All phylogenetic analyses were performed on [KBase](https://www.kbase.us/) (DOE Systems Biology Knowledgebase) using the browser-based Narrative interface. No local command-line tools were used for this step.

---

## Purpose

The goal was to place the 19 cultured isolates into an evolutionary context before downstream analyses. Specifically, the tree was used to:

1. **Visualize evolutionary relationships** among the 19 isolate genomes at finer resolution than genus-level identity alone.
2. **Identify closely related subgroups** within the collection.
3. **Provide context for recruitment interpretation** — determining whether isolates with strong metagenomic recruitment signals are phylogenetically clustered or scattered.
4. **Guide isolate selection for pangenome comparison** — choosing a set of closely related genomes to compare with Isol153.

---

## Input data

The input consisted of 19 assembled *Vibrio* isolate genomes derived from eelgrass-associated samples:

| Isolate | Isolate | Isolate | Isolate |
|---|---|---|---|
| Isol87 | Isol97 | Isol103 | Isol127 |
| Isol88 | Isol100 | Isol104 | Isol129 |
| Isol89 | Isol101 | Isol124 | Isol140 |
| Isol90 | Isol102 | Isol126 | Isol141 |
| Isol92 | Isol95 | | Isol153 |

All genomes were assembled draft genomes (one FASTA file per isolate).

---

## Workflow steps

### Step 1. Import isolate genomes

Each assembled isolate genome FASTA was uploaded into a KBase Narrative and converted into a KBase genome object.

- **Input format**: one assembled genome FASTA file per isolate
- **Output**: one KBase genome object per isolate (19 total)

### Step 2. Create a GenomeSet

The 19 genome objects were organized into a single **GenomeSet** — a KBase container object that groups multiple genomes for joint analysis. This ensured all isolates were analyzed together as a single input.

### Step 3. Build the species tree

The KBase species-tree application was run using the 19-isolate GenomeSet as input.

- **KBase app**: Insert Genome Into Species Tree (or equivalent species-tree workflow)
- **Input**: GenomeSet containing 19 *Vibrio* isolate genomes
- **Output tree object**: `speciestree3`
- **KBase object type**: `KBaseTrees.Tree-1.0`

The app identifies conserved marker genes across the input genomes, builds a multiple sequence alignment, and infers a phylogenetic tree. Branch support values (displayed as red numbers on internal nodes in the KBase viewer) indicate confidence in each split — values close to 1.000 indicate strong support.

### Step 4. Interpret isolate relationships

The tree revealed several well-supported clusters within the 19-isolate collection. Key observations:

- Many major groupings showed **high support values close to 1.000**, indicating robust evolutionary signal.
- Isolates were not uniformly distributed — some formed tight clusters, while others were more phylogenetically isolated.
- **Isol153 grouped near a specific subset of isolates**, which informed the choice of comparison genomes for downstream pangenome analysis.

### Step 5. Select isolates for downstream comparison

Based on the tree topology, the following four isolates were selected for pangenome comparison:

| Isolate | Role in comparison |
|---|---|
| **Isol153** | Focal isolate (strongest recruitment signal) |
| Isol88 | Closely related comparator |
| Isol104 | Closely related comparator |
| Isol129 | Closely related comparator |

These were chosen to ask: does Isol153 carry distinctive accessory gene content compared to its nearest phylogenetic neighbors? Selecting closely related genomes makes this comparison more meaningful — differences between distant relatives would reflect deep evolutionary divergence rather than lineage-specific adaptation.

---

## Output summary

| Output | Description |
|---|---|
| `speciestree3` | KBase species tree of 19 *Vibrio* isolate genomes |
| Object type | `KBaseTrees.Tree-1.0` |

### How this output was used in the poster

- **Figure 1 context**: the tree provided evolutionary framing for interpreting which isolates recruited reads and whether recruitment was phylogenetically structured.
- **Pangenome isolate selection**: the tree guided the choice of Isol88, Isol104, and Isol129 as comparison genomes for the Figure 2 pangenome analysis.

---

## Why these decisions were made

### Why use KBase instead of a local phylogenetic pipeline?

KBase provides a reproducible, browser-based environment that handles marker-gene extraction, alignment, and tree inference in a single integrated workflow. For an exploratory tree of 19 genomes, this is faster and more practical than setting up a local pipeline with separate tools (e.g., PhyloPhlan, GToTree, or manual marker extraction + RAxML). The trade-off is less control over individual parameters, but for the purpose of this step — identifying subgroups and guiding isolate selection — the KBase workflow was sufficient.

### Why a species tree and not a single-gene tree (e.g., 16S)?

Single-gene trees (such as 16S rRNA) have limited resolution for distinguishing closely related *Vibrio* species and strains. Species-tree methods use **multiple conserved marker genes** across the genome, providing substantially more phylogenetic information. This matters here because the downstream pangenome comparison depends on correctly identifying which isolates are truly close relatives of Isol153.

### Why only 4 isolates for pangenome comparison, not all 19?

Pangenome analyses are most interpretable when the comparison set is phylogenetically coherent. Including all 19 isolates — some of which are distantly related — would produce a pangenome dominated by deep divergence, making it difficult to identify Isol153-specific accessory content. By restricting the comparison to Isol153's nearest neighbors, differences are more likely to reflect recent lineage-specific gain or loss rather than noise from ancient divergence.

---

## Notes and limitations

- This tree was used as an **exploratory phylogenetic framework**, not as a final taxonomic assignment. Taxonomic placement of Isol153 was evaluated separately using GTDB-Tk and ANI screening (see `docs/checkm2_gtdb_workflow.md`).
- The tree describes relationships **within this 19-isolate collection** and does not represent the full diversity of *Vibrio* globally.
- The pangenome comparison set (Isol88, Isol104, Isol129, Isol153) was guided by this tree in combination with downstream analysis goals — the tree was a starting point, not the sole criterion.
- Because the analysis was performed in KBase's browser interface, there are no local command-line scripts for this step. The KBase Narrative preserves the full interactive record of the analysis.
