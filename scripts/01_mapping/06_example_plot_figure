# Figure 1 - final ALI-style fixed-log-axis version
# fixed abundance axis: -4, -3, -2, -1, 0
# keep -4 fixed at left edge
# compress tick spacing by extending only the right limit
# no spacer
# ============================

library(tidyverse)
library(ape)
library(ggtree)
library(patchwork)
library(grid)

# ---- 1. paths ----
tree_file   <- "/home/algol/projects/Figure1/speciestree3_isolates_only.nwk"
coverm_file <- "/home/algol/projects/Figure1/SD_CoverM_Isolate_Abundance.tsv"
meta_file   <- "/home/algol/projects/Figure1/species_meta.tsv"

out_pdf <- "/home/algol/projects/Figure1/SD_figure1_fixedlogaxis_final.pdf"
out_png <- "/home/algol/projects/Figure1/SD_figure1_fixedlogaxis_final.png"

# ---- 2. read tree ----
tr <- read.tree(tree_file)

ref_hit <- grep("crassostreae|GCF_", tr$tip.label, value = TRUE)
if (length(ref_hit) > 0) {
  tr <- drop.tip(tr, ref_hit)
}

tr$tip.label <- sub(" .*", "", tr$tip.label)
tr <- ladderize(tr, right = FALSE)

# ---- 3. base tree + tip positions ----
p_tree_base <- ggtree(tr, linewidth = 0.45, color = "black")

tip_pos <- p_tree_base$data %>%
  filter(isTip) %>%
  transmute(isolate = label, y = y)

# ---- 4. read coverM ----
cov_raw <- read_tsv(coverm_file, show_col_types = FALSE) %>%
  filter(Genome != "unmapped")

relab_col   <- grep("Relative Abundance", names(cov_raw), value = TRUE)[1]
breadth_col <- grep("Covered Fraction", names(cov_raw), value = TRUE)[1]

if (is.na(relab_col))   stop("No Relative Abundance column found.")
if (is.na(breadth_col)) stop("No Covered Fraction column found.")

cov <- cov_raw %>%
  transmute(
    isolate = Genome,
    relab   = .data[[relab_col]],
    breadth = .data[[breadth_col]]
  ) %>%
  mutate(
    log_relab   = log10(relab + 1e-4),
    breadth_pct = breadth * 100
  )

# ---- 5. read metadata ----
meta <- read_tsv(meta_file, show_col_types = FALSE)

required_cols <- c("isolate", "species", "color_hex")
missing_cols <- setdiff(required_cols, names(meta))
if (length(missing_cols) > 0) {
  stop("species_meta.tsv 缺少这些列: ", paste(missing_cols, collapse = ", "))
}

# ---- 6. match isolates ----
common_isolates <- Reduce(intersect, list(tr$tip.label, cov$isolate, meta$isolate))
if (length(common_isolates) == 0) {
  stop("tree / coverM / species_meta 没有共同 isolate，请检查命名。")
}

if (length(common_isolates) < length(tr$tip.label)) {
  tr <- drop.tip(tr, setdiff(tr$tip.label, common_isolates))
  tr <- ladderize(tr, right = FALSE)
  p_tree_base <- ggtree(tr, linewidth = 0.45, color = "black")
  tip_pos <- p_tree_base$data %>%
    filter(isTip) %>%
    transmute(isolate = label, y = y)
}

cov  <- cov  %>% filter(isolate %in% common_isolates)
meta <- meta %>% filter(isolate %in% common_isolates)

# ---- 7. merge ----
plot_df <- tip_pos %>%
  left_join(cov,  by = "isolate") %>%
  left_join(meta, by = "isolate")

species_order <- c(
  "Vibrio sp.",
  "Vibrio lentus",
  "Vibrio toranzoniae",
  "Vibrio sp.(coralliirubri-related lineage)",
  "Vibrio cyclitrophicus"
)

plot_df$species <- factor(plot_df$species, levels = species_order)
meta$species    <- factor(meta$species, levels = species_order)

species_colors <- meta %>%
  distinct(species, color_hex) %>%
  arrange(match(species, species_order)) %>%
  deframe()

# ---- 8. axis settings ----
ylims <- c(min(plot_df$y) - 0.5, max(plot_df$y) + 0.5)

# fixed abundance axis:
# keep -4 fixed at the left edge
# extend only the right side so the 0 tick is farther from the border
x_abund_plot <- c(-4, 0.8)
abund_breaks <- c(-4, -3, -2, -1, 0)

x_breadth <- c(0, 100)

bar_half_height <- 0.37
outline_col <- "black"
outline_lwd <- 0.22

# ---- 9. tree panel ----
p_tree <- p_tree_base %<+% meta +
  geom_tippoint(
    aes(fill = species),
    shape = 21,
    size = 2.9,
    color = outline_col,
    stroke = 0.28,
    show.legend = TRUE
  ) +
  scale_fill_manual(values = species_colors, name = NULL) +
  coord_cartesian(ylim = ylims, clip = "off") +
  theme_tree2() +
  theme(
    plot.margin = margin(20, 0, 20, 5),
    legend.title = element_blank(),
    legend.text = element_text(size = 10, face = "italic"),
    legend.key.width = unit(18, "pt"),
    legend.key.height = unit(10, "pt")
  ) +
  guides(
    fill = guide_legend(
      nrow = 1,
      byrow = TRUE,
      override.aes = list(shape = 22, size = 5, color = "black")
    )
  )

# ---- 10. strip panel ----
p_strip <- ggplot(plot_df, aes(x = 1, y = y, fill = species)) +
  geom_tile(
    width = 0.98,
    height = 0.80,
    color = outline_col,
    linewidth = outline_lwd,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = species_colors, guide = "none") +
  scale_y_continuous(NULL, breaks = NULL, limits = ylims, expand = c(0, 0)) +
  coord_cartesian(xlim = c(0.5, 1.5), clip = "off") +
  theme_void() +
  theme(
    plot.margin = margin(20, 0, 20, 0)
  )

# ---- 11. isolate label panel ----
p_label <- ggplot(plot_df, aes(x = 1, y = y, label = isolate)) +
  geom_text(hjust = 0, size = 3.45, fontface = "bold", color = "black") +
  scale_y_continuous(NULL, breaks = NULL, limits = ylims, expand = c(0, 0)) +
  coord_cartesian(xlim = c(1, 1.75), clip = "off") +
  theme_void() +
  theme(
    plot.margin = margin(20, 0, 20, 0)
  )

# ---- 12. abundance panel ----
abund_rect_df <- plot_df %>%
  mutate(
    xmin = -4,
    xmax = pmax(log_relab, -4),
    ymin = y - bar_half_height,
    ymax = y + bar_half_height
  )

p_abund <- ggplot(abund_rect_df) +
  geom_rect(
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = species),
    color = outline_col,
    linewidth = outline_lwd,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = species_colors, guide = "none") +
  scale_y_continuous(NULL, breaks = NULL, limits = ylims, expand = c(0, 0)) +
  scale_x_continuous(
    limits = x_abund_plot,
    breaks = abund_breaks,
    labels = abund_breaks,
    expand = c(0, 0)
  ) +
  labs(
    title = "Relative abundance",
    x = "log10(Relative abundance % + 1e-4)"
  ) +
  theme_classic(base_size = 11) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    panel.border = element_rect(colour = "grey60", fill = NA, linewidth = 0.5),
    panel.background = element_rect(fill = "#FBFBF9", colour = NA),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.text.x  = element_text(size = 11, face = "bold", colour = "black"),
    axis.ticks.x = element_line(linewidth = 0.55, colour = "black"),
    axis.ticks.length = unit(2.8, "mm"),
    axis.line.x = element_line(linewidth = 0.55, colour = "black"),
    plot.margin = margin(20, 1, 20, 0)
  )

# ---- 13. breadth panel ----
breadth_rect_df <- plot_df %>%
  mutate(
    xmin = 0,
    xmax = breadth_pct,
    ymin = y - bar_half_height,
    ymax = y + bar_half_height
  )

p_breadth <- ggplot(breadth_rect_df) +
  geom_rect(
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = species),
    color = outline_col,
    linewidth = outline_lwd,
    show.legend = FALSE
  ) +
  scale_fill_manual(values = species_colors, guide = "none") +
  scale_y_continuous(NULL, breaks = NULL, limits = ylims, expand = c(0, 0)) +
  scale_x_continuous(
    limits = x_breadth,
    breaks = c(0, 25, 50, 75, 100),
    expand = expansion(mult = c(0, 0.02))
  ) +
  labs(
    title = "Covered fraction",
    x = "Covered fraction (%)"
  ) +
  theme_classic(base_size = 11) +
  theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank(),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 13),
    panel.border = element_rect(colour = "grey60", fill = NA, linewidth = 0.5),
    panel.background = element_rect(fill = "#FBFBF9", colour = NA),
    axis.title.x = element_text(size = 12, face = "bold"),
    axis.text.x  = element_text(size = 11, face = "bold", colour = "black"),
    axis.ticks.x = element_line(linewidth = 0.55, colour = "black"),
    axis.ticks.length = unit(2.8, "mm"),
    axis.line.x = element_line(linewidth = 0.55, colour = "black"),
    plot.margin = margin(20, 1, 20, 0)
  )

# ---- 14. combine ----
final_plot <- p_tree + p_strip + p_label + p_abund + p_breadth +
  plot_layout(
    widths = c(1.35, 0.08, 0.55, 2.15, 2.15),
    guides = "collect"
  ) &
  theme(
    legend.position = "bottom",
    legend.justification = "center"
  )

# ---- 15. save ----
ggsave(out_pdf, final_plot, width = 12.2, height = 8.4, units = "in")
ggsave(out_png, final_plot, width = 12.2, height = 8.4, units = "in", dpi = 300)

message("Saved PDF to: ", out_pdf)
message("Saved PNG to: ", out_png)
