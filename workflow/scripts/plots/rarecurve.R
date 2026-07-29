library(rlang)
library(phyloseq)
library(vegan)
plot_rarecurve <- function(ps, color_condition) {
    group_condition <- rlang::enquo(color_condition)
    group <- rlang::eval_tidy(
        group_condition,
        data=sample_data(ps)
    )
    group <- factor(group)
    group_levels <- levels(group)
    group_colors <- setNames(hcl.colors(length(group_levels), palette = "Dark 3"), group_levels)
    otu_matrix <- t(as.data.frame(otu_table(ps)))
    rarecurve(otu_matrix, step=100, lwd=2, ylab="ASVs", label=FALSE, col=group_colors[group])
    legend("bottomright", legend=levels(group), col=group_colors, lwd=2, bty="n")
    abline(v=(min(rowSums(otu_matrix))))
}