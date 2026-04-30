#!/bin/bash
# Map one metagenome directory to the combined isolate reference
#
# Usage:
# bash 02_map_one_sample.sh /home/algol/projects/metagenomes/WAS_MergedLibraries was 28

set -euo pipefail

SAMPLE_DIR="$1"
OUT_TAG="$2"
THREADS="${3:-28}"

INDEX_PREFIX="/home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index"
OUT_DIR="/home/algol/projects/bowtie2_mapping_results"

mkdir -p "${OUT_DIR}"

READS=$(find "${SAMPLE_DIR}" -maxdepth 1 -type f -name "*.fastq" | sort | paste -sd, -)

if [[ -z "${READS}" ]]; then
    echo "Error: no .fastq files found in ${SAMPLE_DIR}"
    exit 1
fi

nohup bash -lc "
bowtie2 -p ${THREADS} \
  -x ${INDEX_PREFIX} \
  -U ${READS} | \
samtools view -@ ${THREADS} -bS - | \
samtools sort -@ ${THREADS} -o ${OUT_DIR}/${OUT_TAG}_to_isolates_v2_sorted.bam && \
samtools index -@ ${THREADS} ${OUT_DIR}/${OUT_TAG}_to_isolates_v2_sorted.bam
" > "${OUT_DIR}/bowtie2_samtools_${OUT_TAG}_v2.log" 2>&1 &

echo "Started mapping for ${OUT_TAG}"
echo "  Input dir: ${SAMPLE_DIR}"
echo "  BAM: ${OUT_DIR}/${OUT_TAG}_to_isolates_v2_sorted.bam"
echo "  Log: ${OUT_DIR}/bowtie2_samtools_${OUT_TAG}_v2.log"
