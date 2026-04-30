#!/bin/bash
# Run CheckM2 genome quality assessment for Isol153
#
# Usage:
# conda activate checkm2
# bash scripts/04_checkm2_gtdb/02_run_checkm2.sh

set -euo pipefail

THREADS="${1:-28}"

INPUT_GENOME="/home/algol/projects/isolates/Isol153.fa"
OUT_DIR="/home/algol/projects/isol153_identity/checkm2_out"

mkdir -p "${OUT_DIR}"

checkm2 predict \
  --threads "${THREADS}" \
  --input "${INPUT_GENOME}" \
  --output-directory "${OUT_DIR}"

echo "CheckM2 completed."
echo "Output directory:"
echo "  ${OUT_DIR}"
echo
echo "View quality report with:"
echo "  column -t ${OUT_DIR}/quality_report.tsv | less -S"
