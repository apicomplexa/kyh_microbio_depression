library(phyloseq); packageVersion('phyloseq')
library(ggplot2); packageVersion(('ggplot2'))
library(vegan); packageVersion(('vegan'))

plot_pcoa <- function(phy, pcoa, samples_info, eigen_vals, group_col, path_to_save) {
    p <- plot_ordination(phy, pcoa, color=group_col) + 
        geom_point(size=1) + 
        labs(col=group_col) + 
        geom_text(aes(label=rownames(samples_info),
                    hjust=0.3,
                    vjust=-0.4)) + 
        coord_fixed(sqrt(eigen_vals[2]/eigen_vals[1])) + 
        ggtitle("PCoA") + 
        theme_bw()

    show(p)

    ggsave(
        filename = path_to_save,
        plot = p,
        width = 180,
        height = 120,
        units = 'mm'
    )
}