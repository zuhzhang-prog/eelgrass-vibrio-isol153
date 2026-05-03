#!/bin/bash
# Run anvi'o functional enrichment across genomes using KOfam annotations.
#
# Prerequisites:
#   - anvi'o pangenome workflow completed (contigs databases with KOfam annotations)
#   - Group file created by 01_make_groups_file.sh
#
# Usage:
#   conda activate anvio-9
#   bash scripts/05_functional_comparison/02_run_functional_enrichment.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

mkdir -p "${RESULT_DIR}"

# ── Check that pangenome workflow outputs exist ──
if [[ ! -f "${EXTERNAL_GENOMES}" ]]; then
    echo "Error: external genomes file not found:"
    echo "  ${EXTERNAL_GENOMES}"
    echo "Run the pangenome workflow first."
    exit 1
fi

# ── Check that group file exists ──
if [[ ! -f "${GROUPS_FILE}" ]]; then
    echo "Error: group file not found:"
    echo "  ${GROUPS_FILE}"
    echo "Run 01_make_groups_file.sh first."
    exit 1
fi

cd "${PROJECT_DIR}"

# ── Run functional enrichment ──
#
# This compares KOfam occurrence between the "isol153" and "other" groups.
# With n=1 in the focal group, this is effectively a presence/absence screen,
# not a powered statistical test. See workflow documentation for details.

anvi-compute-functional-enrichment-across-genomes \
  -e "${EXTERNAL_GENOMES}" \
  -G "${GROUPS_FILE}" \
  --annotation-source "${ANNOTATION_SOURCE}" \
  -o "${ENRICHMENT_OUT}" \
  --functional-occurrence-table-output "${FUNCTION_COUNTS_OUT}"

echo
echo "Functional comparison completed."
echo "  Enrichment table:        ${ENRICHMENT_OUT}"
echo "  Function occurrence:     ${FUNCTION_COUNTS_OUT}"
