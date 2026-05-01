#!/bin/bash
# Run GTDB-Tk ANI screening for Isol153 against GTDB representative genomes
#
# Usage:
# conda activate gtdbtk-2.6.1
# bash scripts/04_checkm2_gtdb/04_run_gtdbtk_ani.sh

set -euo pipefail

THREADS="${1:-28}"

GENOME_DIR="/home/algol/projects/isol153_identity/genome"
OUT_DIR="/home/algol/projects/isol153_identity/gtdbtk_ani"

mkdir -p "${OUT_DIR}"

gtdbtk ani_rep \
  --genome_dir "${GENOME_DIR}" \
  --out_dir "${OUT_DIR}" \
  -x fa \
  --cpus "${THREADS}"

echo "GTDB-Tk ANI screen completed."
echo "Output directory:"
echo "  ${OUT_DIR}"
echo
echo "Key output files:"
echo "  ${OUT_DIR}/gtdbtk.ani_summary.tsv"
echo "  ${OUT_DIR}/gtdbtk.ani_closest.tsv"
