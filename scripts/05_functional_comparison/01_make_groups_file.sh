#!/bin/bash
# Create the group file for Isol153 vs other close relatives.
#
# This defines the 1-vs-3 comparison design:
#   - Isol153 = focal isolate
#   - Isol88, Isol104, Isol129 = representatives of other species-level clusters
#
# Usage:
#   bash scripts/05_functional_comparison/01_make_groups_file.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/00_config.sh"

mkdir -p "${RESULT_DIR}"

cat > "${GROUPS_FILE}" << 'EOF'
name	group
Isol88	other
Isol104	other
Isol129	other
Isol153	isol153
EOF

echo "Group file created:"
echo "  ${GROUPS_FILE}"
echo
echo "Contents:"
cat "${GROUPS_FILE}"
