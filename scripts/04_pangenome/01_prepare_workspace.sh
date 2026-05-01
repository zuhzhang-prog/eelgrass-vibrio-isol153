#!/bin/bash
# Prepare the local directory structure for the anvi'o pangenome workflow.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

mkdir -p "${FASTA_DIR}"
mkdir -p "${CONTIGS_DB_DIR}"
mkdir -p "${PAN_OUT_DIR}"

echo "Workspace prepared:"
echo "  PROJECT_DIR: ${PROJECT_DIR}"
echo "  FASTA_DIR: ${FASTA_DIR}"
echo "  CONTIGS_DB_DIR: ${CONTIGS_DB_DIR}"
echo "  PAN_OUT_DIR: ${PAN_OUT_DIR}"
echo
echo "Expected input FASTA files:"
for genome in "${GENOMES[@]}"; do
    echo "  ${FASTA_DIR}/${genome}.fa"
done
