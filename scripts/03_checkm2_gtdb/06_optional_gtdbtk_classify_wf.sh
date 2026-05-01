#!/bin/bash
# Optional GTDB-Tk classify_wf attempt
#
# Note:
# This step was attempted during analysis but was unstable under the local WSL setup,
# likely due to pplacer/classification-stage memory or placement issues.
# The ANI-based result from gtdbtk ani_rep was used as the reliable result.

set -euo pipefail

THREADS="${1:-28}"

GENOME_DIR="/home/algol/projects/isol153_identity/genome"
OUT_DIR="/home/algol/projects/isol153_identity/gtdbtk_classify_retry_$(date +%Y%m%d_%H%M%S)"

mkdir -p "${OUT_DIR}"

gtdbtk classify_wf \
  --genome_dir "${GENOME_DIR}" \
  --out_dir "${OUT_DIR}" \
  -x fa \
  --cpus "${THREADS}"

echo "GTDB-Tk classify_wf completed."
echo "Output directory:"
echo "  ${OUT_DIR}"
