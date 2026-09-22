library(DirichletMultinomial)
library(phyloseq)
library(ggpubr)


fit_dmm_from_ps <- function (
    ps,
    plots = F,
    max_components=8
) {
    .qualitative <- DirichletMultinomial:::.qualitative
    counts <- otu_table(ps) |> t()
    meta <- data.frame(sample_data(ps))

    fit <- lapply(1:max_components, dmn, count=counts, verbose=F)
    lplc <- sapply(fit, laplace)
    best <- fit[[which.min(lplc)]]

    meta$dmm_cluster <- factor(mixture(best, assign = T))
    sample_data(ps) <- meta

    if (plots != F) {
        p_density <- ggdensity(log10(colSums(counts)),
            add = "mean", rug = TRUE,
            color = hcl.colors(1, palette = "Dark 3"))
        p_fit <- plot(lplc, type="b", xlab="Number of Dirichlet Components", ylab="Model Fit")
        p_splom <- splom(log(fitted(best)))
    }
    if (plots == "show") {
        show(p_density)
        show(p_fit)
        show(p_splom)
    } else {
        ggsave(
            filename = plots + 'counts_per_sample.png',
            plot = p_density
        )
        ggsave(
            filename = plots + 'dmm_fit_results.png',
            plot = p_fit
        )
        ggsave(
            filename = plots + 'dmm_projections.png',
            plot = p_splom
        )
    }

    return(ps)
}