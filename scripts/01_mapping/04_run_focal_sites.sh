#!/bin/bash
# Run mapping + CoverM for focal metagenome sites used in the poster

set -euo pipefail

THREADS="${1:-28}"

# Mapping
bash scripts/01_mapping/02_map_one_sample.sh /home/algol/projects/metagenomes/WAS_MergedLibraries was "${THREADS}"
bash scripts/01_mapping/02_map_one_sample.sh /home/algol/projects/metagenomes/ALI_MergedLibrary ali "${THREADS}"
bash scripts/01_mapping/02_map_one_sample.sh /home/algol/projects/metagenomes/QU_MergedLibrary qu "${THREADS}"
bash scripts/01_mapping/02_map_one_sample.sh /home/algol/projects/metagenomes/SD_MergedLibraries sd "${THREADS}"

echo "Mapping jobs launched."
echo "Wait until BAM files finish, then run CoverM summaries with:"
echo "  bash scripts/01_mapping/03_coverm_one_sample.sh was ${THREADS}"
echo "  bash scripts/01_mapping/03_coverm_one_sample.sh ali ${THREADS}"
echo "  bash scripts/01_mapping/03_coverm_one_sample.sh qu ${THREADS}"
echo "  bash scripts/01_mapping/03_coverm_one_sample.sh sd ${THREADS}"
