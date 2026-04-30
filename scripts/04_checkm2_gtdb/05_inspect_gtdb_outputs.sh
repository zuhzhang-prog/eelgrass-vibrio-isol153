#!/bin/bash
# Inspect GTDB-Tk ANI output files for Isol153
#
# Usage:
# bash scripts/04_checkm2_gtdb/05_inspect_gtdb_outputs.sh

set -euo pipefail

ANI_DIR="/home/algol/projects/isol153_identity/gtdbtk_ani"

SUMMARY="${ANI_DIR}/gtdbtk.ani_summary.tsv"
CLOSEST="${ANI_DIR}/gtdbtk.ani_closest.tsv"

echo "Checking GTDB-Tk ANI output files..."
echo

if [[ -f "${SUMMARY}" ]]; then
    echo "ANI summary:"
    column -t "${SUMMARY}" | head -n 20
else
    echo "Missing file: ${SUMMARY}"
fi

echo

if [[ -f "${CLOSEST}" ]]; then
    echo "Closest ANI hits for Isol153:"
    python - <<PY
import pandas as pd

path = "${CLOSEST}"
df = pd.read_csv(path, sep="\t")

if "user_genome" in df.columns:
    print(df[df["user_genome"] == "Isol153"].head(10).to_string(index=False))
else:
    print(df.head(10).to_string(index=False))
PY
else
    echo "Missing file: ${CLOSEST}"
fi
