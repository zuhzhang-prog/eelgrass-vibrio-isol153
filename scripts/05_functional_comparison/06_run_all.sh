#!/bin/bash
# Run the complete KOfam functional comparison and Figure 3 visualization workflow.
#
# This script runs all steps in order:
#   1. Create Isol153 vs other close relatives group file
#   2. Run anvi'o functional comparison with KOfam
#   3. Extract Isol153-specific candidate functions (automated screening)
#   4. Match candidates to curated display labels and categories
#   5. Plot Figure 3 horizontal heatmap
#
# Prerequisites:
#   - anvi'o pangenome workflow completed (contigs databases with KOfam annotations)
#   - conda activate anvio-9
#   - metadata/figure3_candidate_curation.tsv exists
#
# Usage:
#   conda activate anvio-9
#   bash scripts/05_functional_comparison/06_run_all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Check that Rscript is available ──
if ! command -v Rscript &> /dev/null; then
    echo "Error: Rscript not found."
    echo "Make sure the anvio-9 conda environment is activated:"
    echo "  conda activate anvio-9"
    exit 1
fi

# ── Check that curation table exists ──
CURATION_FILE="$(pwd)/metadata/figure3_candidate_curation.tsv"
if [[ ! -f "${CURATION_FILE}" ]]; then
    echo "Error: curation table not found:"
    echo "  ${CURATION_FILE}"
    echo "Make sure you are running this script from the repository root directory."
    exit 1
fi

echo "============================================"
echo "Step 1/5: Creating group file"
echo "============================================"
bash "${SCRIPT_DIR}/01_make_groups_file.sh"
echo

echo "============================================"
echo "Step 2/5: Running functional comparison"
echo "============================================"
bash "${SCRIPT_DIR}/02_run_functional_enrichment.sh"
echo

echo "============================================"
echo "Step 3/5: Extracting candidate functions"
echo "============================================"
Rscript "${SCRIPT_DIR}/03_extract_isol153_candidates.R"
echo

echo "============================================"
echo "Step 4/5: Matching candidates to curation table"
echo "============================================"
Rscript "${SCRIPT_DIR}/04_prepare_figure3_heatmap_data.R"
echo

echo "============================================"
echo "Step 5/5: Plotting Figure 3 heatmap"
echo "============================================"
Rscript "${SCRIPT_DIR}/05_plot_figure3_heatmap.R"
echo

echo "============================================"
echo "Functional comparison workflow completed."
echo "============================================"
echo
echo "Outputs:"
echo "  Candidate functions:  functional_comparison/isol153_candidate_functions_all.tsv"
echo "  Match details:        functional_comparison/figure3_matched_candidate_functions.tsv"
echo "  Heatmap data:         functional_comparison/figure3_heatmap_data.tsv"
echo "  Figure 3 PDF:         functional_comparison/Isol153_vs_Others_Horizontal.pdf"
echo "  Figure 3 PNG:         functional_comparison/Isol153_vs_Others_Horizontal.png"
