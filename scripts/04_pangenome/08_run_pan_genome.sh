#!/bin/bash
# Run anvi'o pangenome analysis for Isol153 and close relatives.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

if [[ ! -f "${GENOMES_STORAGE_DB}" ]]; then
    echo "Error: genomes storage DB not found: ${GENOMES_STORAGE_DB}"
    echo "Run 07_build_genomes_storage.sh first."
    exit 1
fi

mkdir -p "${PAN_OUT_DIR}"

cd "${PROJECT_DIR}"

anvi-pan-genome \
    -g "${GENOMES_STORAGE_DB}" \
    -o "${PAN_OUT_DIR}" \
    --project-name "${PAN_PROJECT_NAME}" \
    --num-threads "${THREADS}"

echo "Pangenome analysis complete."
echo "Pan output directory:"
echo "  ${PAN_OUT_DIR}"
echo "Expected pan DB:"
echo "  ${PAN_DB}"
