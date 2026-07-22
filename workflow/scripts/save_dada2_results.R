library(dplyr)
library(dada2)

# Summary of reads loss at each step of the dada2 pipeline
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


# Save Dada2 pipeline results
seqtab.nochim.filtered <- seqtab.nochim[, colSums(seqtab.nochim) > 0]
asv_seqs <- colnames(seqtab.nochim.filtered)
asv_map <- data.frame(
    header=paste("ASV", seq_along(asv_seqs), sep="_"),
    sequence=asv_seqs
)


# Save ASV sequences in fasta
asv_fasta <- asv_map |>
    transmute(
        fasta = paste0(">", header, "\n", sequence)
    ) |>
    pull(fasta)
writeLines(asv_fasta, snakemake@output$fa)

# Save ASV counts in tsv
asv_tab <- t(seqtab.nochim.filtered)
row.names(asv_tab) <- asv_map$header[match(colnames(seqtab.nochim.filtered), asv_map$sequence)]
write.table(asv_tab, snakemake@output$counts, sep="\t", quote=F, col.names=NA)

# Save Taxa table in tsv
taxa <- readRDS(snakemake@input$taxa)[colnames(seqtab.nochim.filtered), ]
row.names(taxa) <- asv_map$header[match(row.names(taxa), asv_map$sequence)]
write.table(taxa, snakemake@output$tax, sep="\t", quote=F, col.names=NA)


# Save reads loss summary in tsv

reads_loss_summary <- data.frame(
    input=reads_filter_reports[['reads.in']],
    filtered=reads_filter_reports[['reads.out']],
    merged=rowSums(seqtab),
    nochim=rowSums(seqtab.nochim),
    nochim_nozero=rowSums(seqtab.nochim.filtered),
    nochim_to_input=rowSums(seqtab.nochim.filtered) / reads_filter_reports[['reads.in']],
    row.names=rownames(seqtab)
)

write.table(
    reads_loss_summary,
    file=snakemake@output$reads_loss_summary,
    row.names=T,
    col.names=T,
    sep='\t',
    quote=F
)

# Load and run reads loss plot function
source('workflow/scripts/plots/reads_loss.R')

# Load metadata
metadata <- read.csv(snakemake@input$metadata, row.names = 'Run')

# Create reads loss plot with saved outputs
png(snakemake@output$reads_loss_plot, width = 1200, height = 700, res = 100)
plot_reads_loss(
    metadata,
    depr_or_control,
    reads_loss_file = snakemake@output$reads_loss_summary,
    red_zone_file = snakemake@output$red_zone_samples
)
dev.off()