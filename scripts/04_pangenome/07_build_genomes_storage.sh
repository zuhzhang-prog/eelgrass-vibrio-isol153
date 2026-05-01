#!/bin/bash
# Build anvi'o genomes storage database from external-genomes.txt.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

EXTERNAL_GENOMES="${PROJECT_DIR}/external-genomes.txt"

if [[ ! -f "${EXTERNAL_GENOMES}" ]]; then
    echo "Error: external-genomes.txt not found: ${EXTERNAL_GENOMES}"
    echo "Run 06_make_external_genomes.sh first."
    exit 1
fi

if [[ -f "${GENOMES_STORAGE_DB}" ]]; then
    echo "Genomes storage DB already exists:"
    echo "  ${GENOMES_STORAGE_DB}"
    echo "Remove it manually if you want to rebuild."
    exit 0
fi

cd "${PROJECT_DIR}"

anvi-gen-genomes-storage \
    -e "${EXTERNAL_GENOMES}" \
    -o "${GENOMES_STORAGE_DB}"

echo "Genomes storage database created:"
echo "  ${GENOMES_STORAGE_DB}"
