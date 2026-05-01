#!/bin/bash
# Shared configuration for the anvi'o pangenome workflow.
# Edit paths here if reproducing the workflow on a different machine.

set -euo pipefail

# Main project directory used for the local anvi'o pangenome analysis
PROJECT_DIR="/home/algol/projects/anvio_isol153"

# Input/output subdirectories
FASTA_DIR="${PROJECT_DIR}/fasta"
CONTIGS_DB_DIR="${PROJECT_DIR}/contigs_db"
PAN_OUT_DIR="${PROJECT_DIR}/PAN_OUT"

# Main output database names
GENOMES_STORAGE_DB="${PROJECT_DIR}/ISOL153-4-GENOMES.db"
PAN_PROJECT_NAME="ISOL153_4PAN"
PAN_DB="${PAN_OUT_DIR}/${PAN_PROJECT_NAME}-PAN.db"

# Threads
THREADS="${THREADS:-12}"

# Genomes included in the local anvi'o pangenome comparison
GENOMES=("Isol88" "Isol104" "Isol129" "Isol153")
