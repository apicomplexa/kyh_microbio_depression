library(phyloseq)
library(microbiome)

ps_raw <- readRDS(snakemake@input$ps_raw)
ps_core <- microbiome::core(
    ps_raw, 
    detection snakemake@params$detection_threshold, 
    prevalence = snakemake@params$prevalence_threshold
)

write.table(
    as.data.frame(otu_table(ps_core)),
    snakemake@output$counts_tab,
    sep="\t",
    quote=F,
    col.names=NA
)
saveRDS(ps_core, snakemake@output$ps_core)