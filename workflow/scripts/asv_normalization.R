library("DESeq2")

if (!exists("snakemake")) {
  library(methods)
  Snakemake <- setClass(
      "Snakemake",
      slots = c(
          input = "list",
          output = "list",
          params = "list",
          wildcards = "list",
          threads = "numeric",
          log = "list",
          resources = "list",
          config = "list",
          rule = "character",
          bench_iteration = "numeric",
          scriptdir = "character",
          source = "function"
      )
  )
  snakemake <- Snakemake(
    input=list(counts_tab = "results/ASVs_counts.tsv"),
    output=list(norm_tab = "results/ASVs_counts_normalized.tsv", euclidean_dist = "results/ASVs_euclidean_distance.tsv")
  )
}

counts_tab <- as.matrix(read.csv(snakemake@input$counts_tab, sep = "\t", row.names='X'))

colData <- DataFrame(factor(c(rep('A', dim(counts_tab)[2]))))
rownames(colData) <- colnames(counts_tab)

deseq_counts <- DESeqDataSetFromMatrix(
  counts_tab,
  colData,
  ~ 1
)

deseq_counts <- estimateSizeFactors(deseq_counts, type = "poscounts")
deseq_counts_vst <- varianceStabilizingTransformation(deseq_counts)

vst_trans_count_tab <- assay(deseq_counts)
euc_dist <- dist(t(vst_trans_count_tab))

write.table(
  vst_trans_count_tab,
  snakemake@output$norm_tab,
  sep="\t",
  quote=F,  
  col.names=NA
)

write.table(
  as.matrix(euc_dist),
  snakemake@output$euclidean_dist,
  sep="\t",
  quote=F,
  col.names=NA
)