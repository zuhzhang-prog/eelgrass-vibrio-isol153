#!/bin/bash
# Generate anvi'o contigs databases for each isolate genome.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

mkdir -p "${CONTIGS_DB_DIR}"
cd "${CONTIGS_DB_DIR}"

for genome in "${GENOMES[@]}"; do
    IN_FASTA="${FASTA_DIR}/${genome}_reformatted.fa"
    OUT_DB="${CONTIGS_DB_DIR}/${genome}.db"

    if [[ ! -f "${IN_FASTA}" ]]; then
        echo "Error: reformatted FASTA not found: ${IN_FASTA}"
        echo "Run 02_reformat_fastas.sh first."
        exit 1
    fi

    if [[ -f "${OUT_DB}" ]]; then
        echo "Contigs DB already exists, skipping: ${OUT_DB}"
        continue
    fi

    echo "Building contigs database for ${genome}..."
    anvi-gen-contigs-database \
        -f "${IN_FASTA}" \
        -o "${OUT_DB}" \
        --project-name "${genome}" \
        -T "${THREADS}"
done

echo "Contigs database generation complete."
