#!/bin/bash
# Run CoverM summaries for all sites listed in metadata/mapping_samples.tsv
#
# Usage:
# bash scripts/01_mapping/05_run_coverm_from_samplesheet.sh metadata/mapping_samples.tsv 28

set -euo pipefail

SAMPLE_SHEET="${1:-metadata/mapping_samples.tsv}"
THREADS="${2:-28}"

if [[ ! -f "${SAMPLE_SHEET}" ]]; then
    echo "Error: sample sheet not found: ${SAMPLE_SHEET}"
    exit 1
fi

tail -n +2 "${SAMPLE_SHEET}" | while IFS=$'\t' read -r SITE OUT_TAG SAMPLE_DIR GROUP; do
    if [[ -z "${SITE}" || -z "${OUT_TAG}" ]]; then
        echo "Skipping incomplete row: ${SITE} ${OUT_TAG}"
        continue
    fi

    echo "Running CoverM for ${SITE} (${OUT_TAG})"
    bash scripts/01_mapping/03_coverm_one_sample.sh "${OUT_TAG}" "${THREADS}"
done

echo "CoverM summaries completed for samples listed in ${SAMPLE_SHEET}."
