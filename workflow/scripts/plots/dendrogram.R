library(rlang)
plot_dendrogram <- function(dist, phy, color_condition) {

    meta <- as.data.frame(sample_data(phy))
    sample_ids <- labels(dist)

    if (is.null(sample_ids)) {
        stop("Distance object must contain sample labels.")
    }
    if (!all(sample_ids %in% rownames(meta))) {
        stop("Sample IDs in distance matrix do not match sample_data.")
    }

    meta <- meta[sample_ids, , drop = FALSE]
    meta$sample_id <- rownames(meta)
    color_condition <- rlang::enquo(color_condition)

    cond <- rlang::eval_tidy(
        color_condition,
        data = meta
    )

    if (length(cond) != nrow(meta)) {
        stop("Condition must return one value per sample.")
    }

    if (is.matrix(cond) || is.data.frame(cond)) {
        stop("Condition must return a vector.")
    }

    cond <- factor(cond)
    cols <- setNames(
        hcl.colors(length(levels(cond)), palette = "Dark 3"),
        levels(cond)
    )
    label_cols <- cols[as.character(cond)]
    hc <- hclust(dist, method = "ward.D2")
    dend <- as.dendrogram(hc)
    dend <- dendextend::set(
        dend,
        "labels_col",
        label_cols[order.dendrogram(dend)]
    )

    plot(
        dend,
        xlab = "VST Euc. dist.",
        horiz = TRUE
    )
    legend(
        "topleft",
        title = rlang::as_label(color_condition),
        legend = names(cols),
        col = cols,
        pch = 20,
        bty = "n"
    )
    invisible(
        list(
            dendrogram = dend,
            condition = cond,
            cols = cols
        )
    )
}