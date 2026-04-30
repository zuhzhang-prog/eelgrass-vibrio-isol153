#!/bin/bash
# Build Bowtie2 index from the combined 19-isolate Vibrio reference

set -euo pipefail

REF_FASTA="/home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed.fasta"
INDEX_PREFIX="/home/algol/projects/isolates/bowtie2/combined_19_isolates_renamed_index"

bowtie2-build "${REF_FASTA}" "${INDEX_PREFIX}"

echo "Bowtie2 index built:"
echo "  FASTA: ${REF_FASTA}"
echo "  PREFIX: ${INDEX_PREFIX}"
