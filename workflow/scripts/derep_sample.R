library(dada2)

derep <- derepFastq(snakemake@input, multithread=snakemake@threads)

saveRDS(
    derep,
    snakemake@output
)