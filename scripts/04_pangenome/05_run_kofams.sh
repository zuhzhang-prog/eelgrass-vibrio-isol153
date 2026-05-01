#!/bin/bash
# Run KOfam / KEGG functional annotation on each contigs database.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

cd "${CONTIGS_DB_DIR}"

for genome in "${GENOMES[@]}"; do
    DB="${CONTIGS_DB_DIR}/${genome}.db"

    if [[ ! -f "${DB}" ]]; then
        echo "Error: contigs DB not found: ${DB}"
        echo "Run 03_build_contigs_dbs.sh first."
        exit 1
    fi

    echo "Running KOfam annotation for ${genome}..."
    anvi-run-kegg-kofams \
        -c "${DB}" \
        -T "${THREADS}"
done

echo "KOfam annotation complete."
