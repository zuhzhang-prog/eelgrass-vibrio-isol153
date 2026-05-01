#!/bin/bash
# Run the core local anvi'o pangenome workflow.
#
# Usage:
# conda activate anvio-9
# bash scripts/04_pangenome/10_run_core_workflow.sh
#
# This script runs:
# 1. workspace preparation
# 2. FASTA reformatting
# 3. contigs database generation
# 4. HMM annotation
# 5. KOfam annotation
# 6. external-genomes.txt generation
# 7. genomes storage generation
# 8. pangenome analysis
#
# It does not launch anvi-display-pan because that step is interactive.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "${SCRIPT_DIR}/01_prepare_workspace.sh"
bash "${SCRIPT_DIR}/02_reformat_fastas.sh"
bash "${SCRIPT_DIR}/03_build_contigs_dbs.sh"
bash "${SCRIPT_DIR}/04_run_hmms.sh"
bash "${SCRIPT_DIR}/05_run_kofams.sh"
bash "${SCRIPT_DIR}/06_make_external_genomes.sh"
bash "${SCRIPT_DIR}/07_build_genomes_storage.sh"
bash "${SCRIPT_DIR}/08_run_pan_genome.sh"

echo
echo "Core pangenome workflow complete."
echo "To visualize the pangenome, run:"
echo "  bash scripts/04_pangenome/09_display_pan.sh"
