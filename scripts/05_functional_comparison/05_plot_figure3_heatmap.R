#!/usr/bin/env Rscript

# Plot Figure 3: Isol153-specific candidate functional modules
# relative to closely related isolates.
#
# This produces a horizontal presence/absence heatmap showing candidate
# functions grouped into three ecological categories.
#
# Input:
#   figure3_heatmap_data.tsv  (from 04_prepare_figure3_heatmap_data.R)
#
# Outputs:
#   Isol153_vs_Others_Horizontal.pdf
#   Isol153_vs_Others_Horizontal.png
#
# Usage:
#   Rscript scripts/05_functional_comparison/05_plot_figure3_heatmap.R

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(readr)
})

# ── Paths ──
# NOTE: Update project_dir if running on a different machine.
project_dir <- "/home/algol/projects/anvio_isol153"
result_dir  <- file.path(project_dir, "functional_comparison")

input_file <- file.path(result_dir, "figure3_heatmap_data.tsv")
output_pdf <- file.path(result_dir, "Isol153_vs_Others_Horizontal.pdf")
output_png <- file.path(result_dir, "Isol153_vs_Others_Horizontal.png")

# ── Check input ──
if (!file.exists(input_file)) {
  stop(paste0(
    "Input file not found: ", input_file, "\n",
    "Run 04_prepare_figure3_heatmap_data.R first."
  ))
}

# ── Read curated candidate function table ──
heatmap_data <- read_tsv(input_file, show_col_types = FALSE)

required_cols <- c("Category", "Gene_Name", "Other_Close_Relatives", "Isol153")
missing_cols  <- setdiff(required_cols, colnames(heatmap_data))

if (length(missing_cols) > 0) {
  stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
}

# ── Convert wide → long for ggplot ──
plot_data <- heatmap_data %>%
  pivot_longer(
    cols      = c("Other_Close_Relatives", "Isol153"),
    names_to  = "Genome",
    values_to = "Presence"
  )

# ── Set row labels and order ──
plot_data$Genome <- factor(
  plot_data$Genome,
  levels = c("Other_Close_Relatives", "Isol153"),
  labels = c("Other Close\nRelatives", "Isol153\n(Generalist)")
)

# ── Set category order ──
plot_data$Category <- factor(
  plot_data$Category,
  levels = c(
    "Carbohydrate/Transport",
    "Surface/Colonization",
    "Stress/Plasticity"
  )
)

# ── Preserve gene order within each category ──
plot_data$Gene_Name <- factor(
  plot_data$Gene_Name,
  levels = heatmap_data$Gene_Name
)

# ── Plot horizontal presence/absence heatmap ──
p_heatmap <- ggplot(
  plot_data,
  aes(x = Gene_Name, y = Genome, fill = factor(Presence))
) +
  geom_tile(color = "black", linewidth = 0.25) +
  facet_grid(
    . ~ Category,
    scales = "free_x",
    space  = "free_x"
  ) +
  scale_fill_manual(
    values = c("0" = "#f4fad4", "1" = "#ab2428"),
    labels = c("Absent (0%)", "Present (100%)"),
    name   = "Gene Status"
  ) +
  theme_minimal(base_size = 12) +
  theme(
    # Facet strip styling
    strip.text.x = element_text(
      face   = "bold",
      size   = 12,
      color  = "black",
      margin = margin(b = 10, t = 10)
    ),
    strip.background = element_rect(
      fill     = "#e9ecef",
      color    = "black",
      linewidth = 0.5
    ),

    # Axis text
    axis.text.x = element_text(
      angle = 45,
      hjust = 1,
      vjust = 1,
      size  = 11,
      color = "black"
    ),
    axis.text.y = element_text(
      size  = 12,
      face  = "bold",
      color = "black"
    ),

    # Remove axis titles and grid
    axis.title    = element_blank(),
    panel.grid    = element_blank(),
    panel.spacing = unit(0.5, "lines"),

    # Legend
    legend.position = "bottom",
    legend.text     = element_text(size = 11),
    legend.title    = element_text(face = "bold", size = 11),

    # Margins
    plot.margin = margin(t = 10, r = 20, b = 10, l = 10)
  )

# ── Save outputs ──
ggsave(
  filename = output_pdf,
  plot     = p_heatmap,
  width    = 11,
  height   = 4.5
)

ggsave(
  filename = output_png,
  plot     = p_heatmap,
  width    = 11,
  height   = 4.5,
  dpi      = 300
)

cat("Figure 3 heatmap saved:\n")
cat("  PDF: ", output_pdf, "\n")
cat("  PNG: ", output_png, "\n")
