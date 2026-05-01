#!/bin/bash
# Prepare workspace for Isol153 genome quality and GTDB ANI analysis

set -euo pipefail

PROJECT_DIR="/home/algol/projects/isol153_identity"
INPUT_GENOME="/home/algol/projects/isolates/Isol153.fa"
GENOME_DIR="${PROJECT_DIR}/genome"

mkdir -p "${GENOME_DIR}"

ln -sf "${INPUT_GENOME}" "${GENOME_DIR}/Isol153.fa"

echo "Workspace prepared:"
echo "  Project directory: ${PROJECT_DIR}"
echo "  Genome directory: ${GENOME_DIR}"
echo "  Linked genome: ${GENOME_DIR}/Isol153.fa"
