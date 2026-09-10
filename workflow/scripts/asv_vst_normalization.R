library("DESeq2")
library(phyloseq)

vst_normalization <- function(ps) {
  dds <- phyloseq_to_deseq2(ps, ~ 1)
  dds <- estimateSizeFactors(dds, type = "poscounts")
  dds_vst <- varianceStabilizingTransformation(dds)

  vst_trans_count_tab <- assay(dds_vst)
  euc_dist <- dist(t(vst_trans_count_tab))

  return(list(
    norm_tab = vst_trans_count_tab,
    euclidean_dist = euc_dist
  ))
}


ps_raw <- readRDS(snakemake@input$ps_raw)
results = vst_normalization(ps_raw)

write.table(
  results$norm_tab,
  snakemake@output$norm_tab,
  sep="\t",
  quote=F,  
  col.names=NA
)

write.table(
  as.matrix(results$euclidean_dist),
  snakemake@output$euclidean_dist,
  sep="\t",
  quote=F,
  col.names=NA
)

counts_tab <- results$norm_tab

samples_info_phy <- sample_data(ps_raw)
taxa_table_phy <- tax_table(ps_raw)

ps_vst <- phyloseq(otu_table(counts_tab, taxa_are_rows = T), samples_info_phy, taxa_table_phy)

saveRDS(ps_vst, snakemake@output$ps_vst)