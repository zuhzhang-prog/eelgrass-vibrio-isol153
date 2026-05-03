#!/usr/bin/env Rscript

# Extract Isol153-associated candidate functions from anvi'o enrichment output.
#
# Screening criteria:
#   - associated_groups contains "isol153"
#   - p_isol153 == 1  (function present in Isol153)
#   - p_other   == 0  (function absent from all three comparators)
#
# This is an automated binary filter, not a statistical enrichment test.
# With n=1 in the focal group, p-values from the enrichment table should
# be treated as descriptive scores, not hypothesis tests.
#
# Input:
#   isol153_vs_others.enrichment.txt  (from 02_run_functional_enrichment.sh)
#
# Output:
#   isol153_candidate_functions_all.tsv  (all candidates passing the filter)
#
# Usage:
#   Rscript scripts/05_functional_comparison/03_extract_isol153_candidates.R

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

# ── Paths ──
# NOTE: Update project_dir if running on a different machine.
project_dir <- "/home/algol/projects/anvio_isol153"
result_dir  <- file.path(project_dir, "functional_comparison")

enrichment_file <- file.path(result_dir, "isol153_vs_others.enrichment.txt")
candidate_out   <- file.path(result_dir, "isol153_candidate_functions_all.tsv")

# ── Check input ──
if (!file.exists(enrichment_file)) {
  stop(paste("Missing enrichment file:", enrichment_file,
             "\nRun 02_run_functional_enrichment.sh first."))
}

# ── Read enrichment table ──
df <- read_tsv(enrichment_file, show_col_types = FALSE)

# Verify required columns exist
# Note: "function" is a reserved word in R, so we check it as a string
#       and use backticks when referencing the column.
required_cols <- c("associated_groups", "p_isol153", "p_other", "function")
missing_cols  <- setdiff(required_cols, colnames(df))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

# ── Filter for Isol153-specific candidates ──
candidates <- df %>%
  filter(
    grepl("isol153", associated_groups, ignore.case = TRUE),
    as.numeric(p_isol153) == 1,
    as.numeric(p_other)   == 0
  )

# Sort by enrichment score if available, otherwise by function name
if ("enrichment_score" %in% colnames(candidates)) {
  candidates <- candidates %>%
    arrange(desc(enrichment_score), `function`)
} else {
  candidates <- candidates %>%
    arrange(`function`)
}

# ── Write output ──
write_tsv(candidates, candidate_out)

cat("Isol153-associated candidate functions extracted:\n")
cat("  Total candidates: ", nrow(candidates), "\n")
cat("  Output: ", candidate_out, "\n")

# ── Print summary ──
if (nrow(candidates) > 0) {
  cat("\nFirst 10 candidates:\n")
  print(head(candidates %>% select(`function`, p_isol153, p_other), 10))
} else {
  cat("\nWarning: no candidate functions passed the filter.\n")
  cat("Check the enrichment table and column names.\n")
}
