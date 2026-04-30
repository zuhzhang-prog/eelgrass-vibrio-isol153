#!/bin/bash
# Launch Bowtie2/Samtools mapping jobs for all sites listed in metadata/mapping_samples.tsv
#
# Usage:
# bash scripts/01_mapping/04_run_mapping_from_samplesheet.sh metadata/mapping_samples.tsv 28
#
# Notes:
# - This script launches mapping jobs with nohup in the background.
# - If the sample sheet has many sites, many jobs may start at once.
# - For large datasets, consider running fewer sites at a time.

set -euo pipefail

SAMPLE_SHEET="${1:-metadata/mapping_samples.tsv}"
THREADS="${2:-28}"

if [[ ! -f "${SAMPLE_SHEET}" ]]; then
    echo "Error: sample sheet not found: ${SAMPLE_SHEET}"
    exit 1
fi

tail -n +2 "${SAMPLE_SHEET}" | while IFS=$'\t' read -r SITE OUT_TAG SAMPLE_DIR GROUP; do
    if [[ -z "${SITE}" || -z "${OUT_TAG}" || -z "${SAMPLE_DIR}" ]]; then
        echo "Skipping incomplete row: ${SITE} ${OUT_TAG} ${SAMPLE_DIR}"
        continue
    fi

    echo "Launching mapping for ${SITE} (${OUT_TAG})"
    echo "  Directory: ${SAMPLE_DIR}"
    echo "  Group: ${GROUP}"

    bash scripts/01_mapping/02_map_one_sample.sh "${SAMPLE_DIR}" "${OUT_TAG}" "${THREADS}"
done

echo "All mapping jobs from ${SAMPLE_SHEET} have been launched."
echo "Check logs in /home/algol/projects/bowtie2_mapping_results/"
