#!/bin/bash
# Launch anvi'o interactive pangenome display.
#
# After running this script, open:
# http://localhost:8080

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

if [[ ! -f "${PAN_DB}" ]]; then
    echo "Error: pan DB not found: ${PAN_DB}"
    echo "Run 08_run_pan_genome.sh first."
    exit 1
fi

if [[ ! -f "${GENOMES_STORAGE_DB}" ]]; then
    echo "Error: genomes storage DB not found: ${GENOMES_STORAGE_DB}"
    echo "Run 07_build_genomes_storage.sh first."
    exit 1
fi

echo "Launching anvi'o pangenome display..."
echo "If the browser does not open automatically, manually open:"
echo "  http://localhost:8080"

anvi-display-pan \
    -p "${PAN_DB}" \
    -g "${GENOMES_STORAGE_DB}" \
    -I localhost
