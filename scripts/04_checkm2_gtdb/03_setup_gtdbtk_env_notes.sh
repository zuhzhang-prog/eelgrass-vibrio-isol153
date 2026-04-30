#!/bin/bash
# GTDB-Tk environment setup notes
#
# This script records the environment setup used for GTDB-Tk v2.6.1.
# Run commands manually if the environment/database has not been installed.

set -euo pipefail

echo "Suggested GTDB-Tk installation commands:"
echo
echo "conda create -n gtdbtk-2.6.1 -c conda-forge -c bioconda gtdbtk=2.6.1"
echo "conda activate gtdbtk-2.6.1"
echo "download-db.sh"
echo
echo "Database path used in this project:"
echo "/home/algol/miniconda3/envs/gtdbtk-2.6.1/share/gtdbtk-2.6.1/db/"
echo
echo "Set GTDBTK_DATA_PATH:"
echo 'conda env config vars set GTDBTK_DATA_PATH="/home/algol/miniconda3/envs/gtdbtk-2.6.1/share/gtdbtk-2.6.1/db/"'
echo "conda deactivate"
echo "conda activate gtdbtk-2.6.1"
echo
echo "Check installation:"
echo "echo \$GTDBTK_DATA_PATH"
echo "gtdbtk check_install"
