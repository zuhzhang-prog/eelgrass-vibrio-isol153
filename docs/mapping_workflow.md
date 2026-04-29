## Metagenomic recruitment workflow

This workflow was used to quantify recruitment of eelgrass-associated metagenomic reads against a combined reference built from 19 Northern California eelgrass-associated *Vibrio* isolate genomes. Recruitment was summarized at the genome level using Bowtie2, Samtools, and CoverM. The final workflow used streaming (`bowtie2 | samtools`) to avoid very large intermediate SAM files. 

### Software
- bowtie2
- samtools
- coverm
- conda

### Environment
A dedicated conda environment was used for mapping:
```bash
conda create -n mapping_env -c conda-forge -c bioconda bowtie2 samtools coverm
conda activate mapping_env
