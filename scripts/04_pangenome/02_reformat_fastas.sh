#!/bin/bash
# Reformat FASTA files to satisfy anvi'o simple defline requirements.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

cd "${FASTA_DIR}"

for genome in "${GENOMES[@]}"; do
    IN_FASTA="${FASTA_DIR}/${genome}.fa"
    OUT_FASTA="${FASTA_DIR}/${genome}_reformatted.fa"

    if [[ ! -f "${IN_FASTA}" ]]; then
        echo "Error: input FASTA not found: ${IN_FASTA}"
        exit 1
    fi

    if [[ -f "${OUT_FASTA}" ]]; then
        echo "Reformatted FASTA already exists, skipping: ${OUT_FASTA}"
        continue
    fi

    echo "Reformatting ${genome} FASTA..."
    anvi-script-reformat-fasta "${IN_FASTA}" \
        -o "${OUT_FASTA}" \
        --simplify-names
done

echo "FASTA reformatting complete."
