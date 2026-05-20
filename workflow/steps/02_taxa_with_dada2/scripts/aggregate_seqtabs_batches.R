library(dada2)
seqtab <- mergeSequenceTables(tables=snakemake@input$batches_seqtab)
saveRDS(seqtab, snakemake@output$seqtab)