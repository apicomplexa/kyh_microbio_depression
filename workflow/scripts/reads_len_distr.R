library(ShortRead)
library(ggplot2)
library(dplyr)

get_read_lengths <- function(files) {
  lengths_list <- lapply(files, function(f) {
    fq <- readFastq(f)
    width(sread(fq))
  })
  unlist(lengths_list)
}

reads_len_stat <- function(for_reads, rev_reads) {

for_lengths <- get_read_lengths(for_reads)
rev_lengths <- get_read_lengths(rev_reads)

cat("forward reads:\n")
print(summary(for_lengths))

cat("\nreverse reads:\n")
print(summary(rev_lengths))
}