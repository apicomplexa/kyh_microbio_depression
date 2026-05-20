library(dplyr)
library(dada2)

# Summary of reads loss at each step of the dada2 pipeline``
reads_filter_reports <- do.call(rbind, lapply(
    snakemake@input$filterAndTrimReports,
    function(x) {
        read.table(x, header=TRUE, row.names=1, sep="\t")
    }
))
names(reads_filter_reports) <- sapply(
    strsplit(names(reads_filter_reports), "_"),
    `[`,
    1
)

seqtab <- readRDS(snakemake@input$seqtab)
seqtab.nochim <- readRDS(snakemake@input$seqtab_nochim)

reads_loss_summary <- data.frame(
    input=reads_filter_reports[['reads.in']],
    filtered=reads_filter_reports[['reads.out']],
    merged=rowSums(seqtab),
    nochim=rowSums(seqtab.nochim),
    nochim_to_input=rowSums(seqtab.nochim) / reads_filter_reports[['reads.in']]
)

write.table(
    reads_loss_summary,
    file=snakemake@output$reads_loss_summary,
    row.names=F,
    col.names=T,
    sep='\t',
    quote=F
)

# Save Dada2 pipeline results
asv_seqs <- colnames(seqtab.nochim)
asv_map <- data.frame(
    header=paste(">ASV", seq_along(asv_seqs), sep="_"),
    sequence=asv_seqs
)

# Save ASV sequences in fasta
asv_fasta <- asv_map |>
    select(header, sequence) |>
    as.matrix() |>
    t() |>
    as.vector()
write(asv_fasta, snakemake@output$fa)

# Save ASV counts in tsv
asv_tab <- t(seqtab.nochim)
row.names(asv_tab) <- asv_map$header[match(colnames(seqtab.nochim), asv_map$sequence)]
write.table(asv_tab, snakemake@output$counts, sep="\t", quote=F, col.names=NA)

# Save Taxa table in tsv
taxa <- readRDS(snakemake@input$taxa)
row.names(taxa) <- asv_map$header[match(row.names(taxa), asv_map$sequence)]
write.table(taxa, snakemake@output$tax, sep="\t", quote=F, col.names=NA)
