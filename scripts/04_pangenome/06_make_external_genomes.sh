#!/bin/bash
# Create external-genomes.txt for anvi'o genomes storage.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

EXTERNAL_GENOMES="${PROJECT_DIR}/external-genomes.txt"

echo -e "name\tcontigs_db_path" > "${EXTERNAL_GENOMES}"

for genome in "${GENOMES[@]}"; do
    DB="${CONTIGS_DB_DIR}/${genome}.db"

    if [[ ! -f "${DB}" ]]; then
        echo "Error: contigs DB not found: ${DB}"
        echo "Run 03_build_contigs_dbs.sh first."
        exit 1
    fi

    echo -e "${genome}\t${DB}" >> "${EXTERNAL_GENOMES}"
done

echo "external-genomes.txt created:"
echo "  ${EXTERNAL_GENOMES}"
echo
cat "${EXTERNAL_GENOMES}"
