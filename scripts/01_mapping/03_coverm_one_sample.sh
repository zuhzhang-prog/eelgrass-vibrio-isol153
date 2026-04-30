#!/bin/bash
# Summarize one mapped BAM with CoverM
#
# Usage:
# bash 03_coverm_one_sample.sh was 28

set -euo pipefail

OUT_TAG="$1"
THREADS="${2:-28}"

OUT_DIR="/home/algol/projects/bowtie2_mapping_results"
BAM="${OUT_DIR}/${OUT_TAG}_to_isolates_v2_sorted.bam"
OUT_TSV="${OUT_DIR}/${OUT_TAG^^}_CoverM_Isolate_Abundance.tsv"

if [[ ! -f "${BAM}" ]]; then
    echo "Error: BAM file not found: ${BAM}"
    exit 1
fi

coverm genome \
  -b "${BAM}" \
  --separator "_" \
  -m relative_abundance mean covered_fraction \
  -t "${THREADS}" \
  -o "${OUT_TSV}"

echo "CoverM summary written to:"
echo "  ${OUT_TSV}"
