#!/usr/bin/env Rscript

# Prepare Figure 3 heatmap input from automatically extracted candidate functions
# plus a manually curated display/category table.
#
# This script bridges the automated screening (03) and the visualization (05).
# It links each curated display label back to the actual candidate functions
# identified from the anvi'o enrichment output, so the Figure 3 gene list
# is traceable rather than hard-coded.
#
# Inputs:
#   isol153_candidate_functions_all.tsv    (from 03_extract_isol153_candidates.R)
#   metadata/figure3_candidate_curation.tsv (manually maintained)
#
# Outputs:
#   figure3_matched_candidate_functions.tsv (full match details for audit)
#   figure3_heatmap_data.tsv               (simplified input for 05_plot)
#
# Usage:
#   Rscript scripts/05_functional_comparison/04_prepare_figure3_heatmap_data.R

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(stringr)
})

# ── Paths ──
# NOTE: Update project_dir if running on a different machine.
project_dir <- "/home/algol/projects/anvio_isol153"
repo_dir    <- getwd()
result_dir  <- file.path(project_dir, "functional_comparison")

candidate_file <- file.path(result_dir, "isol153_candidate_functions_all.tsv")
curation_file  <- file.path(repo_dir, "metadata", "figure3_candidate_curation.tsv")
out_file       <- file.path(result_dir, "figure3_heatmap_data.tsv")
matched_out    <- file.path(result_dir, "figure3_matched_candidate_functions.tsv")

# ── Check inputs ──
if (!file.exists(candidate_file)) {
  stop(paste("Missing candidate file:", candidate_file,
             "\nRun 03_extract_isol153_candidates.R first."))
}

if (!file.exists(curation_file)) {
  stop(paste("Missing curation file:", curation_file,
             "\nExpected at: metadata/figure3_candidate_curation.tsv"))
}

# ── Read data ──
candidates <- read_tsv(candidate_file, show_col_types = FALSE)
curation   <- read_tsv(curation_file,  show_col_types = FALSE)

# ── Validate candidate table columns ──
# Note: "function" is a reserved word in R — use backticks when referencing.
required_candidate_cols <- c("function", "p_isol153", "p_other")
missing_candidate_cols  <- setdiff(required_candidate_cols, colnames(candidates))

if (length(missing_candidate_cols) > 0) {
  stop(paste("Missing columns in candidate table:",
             paste(missing_candidate_cols, collapse = ", ")))
}

# ── Validate curation table columns ──
required_curation_cols <- c("function_keyword", "display_label",
                            "category", "include_in_figure")
missing_curation_cols  <- setdiff(required_curation_cols, colnames(curation))

if (length(missing_curation_cols) > 0) {
  stop(paste("Missing columns in curation table:",
             paste(missing_curation_cols, collapse = ", ")))
}

# ── Filter curation table to included entries only ──
curation <- curation %>%
  filter(tolower(include_in_figure) == "yes")

if (nrow(curation) == 0) {
  stop("No entries with include_in_figure='yes' in curation table.")
}

# ── Match each curation keyword against candidate functions ──
matched_list <- list()

cat("Keyword matching results:\n")

for (i in seq_len(nrow(curation))) {
  keyword <- curation$function_keyword[i]
  label   <- curation$display_label[i]

  matched <- candidates %>%
    filter(str_detect(`function`, regex(keyword, ignore_case = TRUE)))

  if (nrow(matched) == 0) {
    warning(paste("  No candidate matched keyword:", keyword,
                  "  (display_label:", label, ")"))
    cat("  [MISS]  ", keyword, " → no match\n")
    next
  }

  # Log each match so you can audit for false positives
  for (j in seq_len(nrow(matched))) {
    cat("  [OK]    ", keyword, " → ", matched$`function`[j], "\n")
  }

  matched <- matched %>%
    mutate(
      function_keyword = keyword,
      display_label    = label,
      category         = curation$category[i]
    )

  matched_list[[length(matched_list) + 1]] <- matched
}

if (length(matched_list) == 0) {
  stop("No candidate functions matched any curation keywords.")
}

# ── Combine and deduplicate by display label ──
matched_candidates <- bind_rows(matched_list) %>%
  distinct(display_label, category, .keep_all = TRUE)

# ── Write full matched table (for audit/traceability) ──
write_tsv(matched_candidates, matched_out)

# ── Build simplified heatmap input ──
heatmap_data <- matched_candidates %>%
  transmute(
    Category              = category,
    Gene_Name             = display_label,
    Other_Close_Relatives = as.numeric(p_other),
    Isol153               = as.numeric(p_isol153)
  ) %>%
  distinct()

# Set category display order
category_order <- c(
  "Carbohydrate/Transport",
  "Surface/Colonization",
  "Stress/Plasticity"
)

heatmap_data <- heatmap_data %>%
  mutate(Category = factor(Category, levels = category_order)) %>%
  arrange(Category, Gene_Name)

# ── Write heatmap input ──
write_tsv(heatmap_data, out_file)

cat("\nSummary:\n")
cat("  Matched candidate details: ", matched_out, "\n")
cat("  Heatmap input:             ", out_file, "\n")
cat("  Functions in heatmap:      ", nrow(heatmap_data), "\n")
