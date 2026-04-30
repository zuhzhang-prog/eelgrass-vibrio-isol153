# eelgrass-vibrio-isol153
Genome-informed metagenomic recruitment and comparative genomics of an eelgrass-associated Vibrio lineage
## Project overview

This project uses genome-informed metagenomic recruitment to identify eelgrass-associated *Vibrio* lineages that are repeatedly detected across geographically distant *Zostera marina* metagenomes. Among 19 cultured eelgrass-associated *Vibrio* isolates, Isol153 showed the strongest and most consistent recruitment signal across focal leaf-associated metagenomic samples. Follow-up comparative analyses suggest that Isol153 is genomically distinct from currently defined GTDB species clusters and carries candidate accessory functions related to carbohydrate utilization, surface colonization, and stress/plasticity.

## Research questions

1. Which eelgrass-associated *Vibrio* isolate-related lineages are repeatedly detected across geographically distant metagenomic samples?
2. Why was Isol153 selected as the focal lineage for follow-up analysis?
3. What genomic and functional features distinguish Isol153 from closely related *Vibrio* isolates?

## Study design

This project combines isolate genome sequencing, metagenomic recruitment, and comparative genomics:

1. Nineteen eelgrass-associated *Vibrio* isolates were cultured and sequenced to generate draft genomes.
2. Leaf-associated *Zostera marina* metagenomic reads were mapped against the isolate genome set.
3. Recruitment was quantified across sites using relative abundance and genome coverage.
4. Isol153 was selected for follow-up because it showed the strongest and most consistent recruitment across focal samples.
5. Genome quality and taxonomic placement were evaluated using CheckM2 and GTDB ANI screening.
6. Isol153 was compared with closely related *Vibrio* isolates using anvi’o-based pangenome analysis and KOfam-supported functional comparison.

## Workflow modules

### 1. Metagenomic recruitment mapping
Leaf-associated *Zostera marina* metagenomic reads were mapped against a combined Bowtie2 reference built from 19 eelgrass-associated *Vibrio* isolate genomes. Recruitment was summarized at the genome level using Samtools and CoverM, with relative abundance, mean coverage, and covered fraction used in downstream comparisons.

Detailed workflow: [docs/mapping_workflow.md](docs/mapping_workflow.md)   Scripts: [scripts/01_mapping](scripts/01_mapping)

### 2. Phylogenetic tree construction

Evolutionary relationships among the 19 isolate genomes were explored 
using a KBase species-tree workflow. The resulting tree guided isolate 
selection for downstream pangenome comparison.

Detailed workflow: [docs/phylogeny_workflow.md](docs/phylogeny_workflow.md)

### 3. Genome quality and taxonomic placement

The focal isolate Isol153 was evaluated for genome quality using CheckM2 and then screened against GTDB representative genomes using GTDB-Tk ANI analysis. This workflow was used to confirm that the Isol153 assembly was high quality and to identify its closest currently represented GTDB reference lineage.

- Detailed workflow: [docs/isol153_taxonomy_workflow.md](docs/isol153_taxonomy_workflow.md)
- Scripts: [scripts/04_checkm2_gtdb/](scripts/04_checkm2_gtdb/)

## Main findings

### 1. Recruitment across sites
Genome-informed metagenomic recruitment resolved eelgrass-associated *Vibrio* diversity at the lineage level across Northern Hemisphere *Zostera marina* sites. Isol153 showed the strongest and most consistent recruitment signal among focal samples, suggesting that it may represent a broadly distributed eelgrass-associated lineage.

### 2. Genomic distinctiveness of Isol153
GTDB ANI screening identified *Vibrio coralliirubri* as the closest current reference genome to Isol153, with:
- ANI: 94.76%
- Alignment fraction (AF): 0.771
- GTDB species circumscription satisfied: No

These values suggest that Isol153 is not confidently assigned to an existing GTDB species cluster and is genomically distinct from currently represented references.

### 3. Pangenome structure
Comparative pangenome analysis showed that Isol153 retains a conserved shared genomic backbone with nearby isolates while also carrying substantial variable gene-cluster content. These differences are concentrated in accessory and singleton-like regions rather than being distributed across the entire genome.

### 4. Candidate functional differences
Comparative KOfam-based functional profiling identified a set of candidate functions present in Isol153 but absent from closely related isolates. These functions group into three ecological categories:
- carbohydrate / transport
- surface colonization
- stress / plasticity

Representative candidate functions include carbohydrate-processing enzymes, sugar transport systems, colonization and biofilm-associated proteins, and DNA repair/stress-related features. Together, these suggest that Isol153 may combine broader substrate use with enhanced surface-associated persistence.

## Interpretation

The results support Isol153 as a strong focal lineage for future study because it combines:
- repeated metagenomic detection across focal sites,
- genomic distinctiveness relative to current GTDB references,
- and lineage-specific accessory gene content with plausible ecological relevance.

This project therefore frames Isol153 as a candidate eelgrass-associated *Vibrio* lineage for future work on host association, ecological distribution, and adaptation.

## Repository contents

This repository is intended to document a reproducible project workflow rather than store all raw sequencing data. It is organized around the major analytical steps used to generate the poster figures.

Suggested structure:

- `metadata/` — isolate and site metadata
- `scripts/01_mapping/` — Bowtie2, samtools, and CoverM workflow
- `scripts/04_checkm2_gtdb/` — genome quality and ANI screening
- `scripts/05_pangenome/` — anvi’o pangenome workflow
- `scripts/07_enrichment/` — KOfam comparison and enrichment
- `scripts/08_figures/` — figure generation scripts
- `results/` — summary tables and poster-ready figures
- `docs/` — workflow notes and interpretation notes

## Reproducibility note

The original analyses were performed interactively in the terminal during project development. The scripts and notes in this repository represent a reconstructed final workflow based on the successful commands, intermediate outputs, and figure-generation steps used to produce the poster.

## Figure guide

- **Figure 1** — geographic distribution and metagenomic recruitment of eelgrass-associated *Vibrio* isolates across Northern Hemisphere sites
- **Figure 2** — pangenome comparison of Isol153 and closely related *Vibrio* isolates
- **Figure 3** — Isol153-specific candidate functional modules relative to closely related isolates

## Limitations

The isolate reference set was derived from multiple eelgrass-associated microhabitats, whereas the metagenomic dataset analyzed here is leaf-associated. Accordingly, recruitment should be interpreted at the lineage level: leaf-associated metagenomes contain organisms closely related to these reference genomes, rather than necessarily the exact original isolates or strictly tissue-specific strains.

## Future directions

- Expand lineage-level recruitment analyses across additional eelgrass-associated compartments
- Compare Isol153 against a broader reference panel of closely related *Vibrio* genomes
- Refine candidate functional modules using genome-context and gene-cluster analyses
- Test whether predicted carbohydrate-use and colonization-related traits are associated with ecological persistence in eelgrass-associated environments
