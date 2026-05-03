#!/bin/bash
# Shared configuration for KOfam functional comparison and Figure 3 visualization.
#
# This file is sourced by all other scripts in this directory.
# Update paths here if running on a different machine.
 
set -euo pipefail
 
# ── Main anvi'o project directory ──
PROJECT_DIR="/home/algol/projects/anvio_isol153"
 
# ── Input files from anvi'o pangenome workflow ──
EXTERNAL_GENOMES="${PROJECT_DIR}/external-genomes.txt"
GENOMES_STORAGE_DB="${PROJECT_DIR}/ISOL153-4-GENOMES.db"
 
# ── Output directory for KOfam comparison and visualization ──
RESULT_DIR="${PROJECT_DIR}/functional_comparison"
 
# ── Group file for Isol153 vs close relatives ──
GROUPS_FILE="${RESULT_DIR}/isol153_vs_others_groups.txt"
 
# ── Annotation source used by anvi'o ──
ANNOTATION_SOURCE="KOfam"
 
# ── anvi'o functional comparison outputs ──
ENRICHMENT_OUT="${RESULT_DIR}/isol153_vs_others.enrichment.txt"
FUNCTION_COUNTS_OUT="${RESULT_DIR}/isol153_vs_others.function_counts.txt"
 
# ── Automated candidate screening output ──
CANDIDATES_ALL="${RESULT_DIR}/isol153_candidate_functions_all.tsv"
 
# ── Figure 3 input and output files ──
FIGURE3_DATA="${RESULT_DIR}/figure3_heatmap_data.tsv"
FIGURE3_MATCHED="${RESULT_DIR}/figure3_matched_candidate_functions.tsv"
FIGURE3_PDF="${RESULT_DIR}/Isol153_vs_Others_Horizontal.pdf"
FIGURE3_PNG="${RESULT_DIR}/Isol153_vs_Others_Horizontal.png"
 
