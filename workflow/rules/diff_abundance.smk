# Differential abundance — NOT wired into the workflow yet.
# Deliberately left out of `include:` in workflow/Snakefile. Before enabling it:
#   1. `notebook:` points at diff_abundance.r.ipynb, which does not exist.
#      The actual notebook is workflow/notebooks/deseq2.r.ipynb.
#   2. `input.norm_counts_tab` names <results>/ASV_norm_counts.tsv, but rule
#      AsvNormalization (rules/diversity.smk) produces ASVs_counts_normalized.tsv.
# Only the relative paths were updated during the layout refactor; the logic
# above is untouched and still broken.

rule DiffAbundance:
    input:
        norm_counts_tab = "<results>/ASV_norm_counts.tsv",
        distances_matrix = "<results>/ASVs_euclidean_distance.tsv"
    output:
        "<results>/diff_abundance_report.txt"
    log:
        notebook="<logs>/diff_abundance_notebook.r.ipynb"
    notebook:
        "../notebooks/diff_abundance.r.ipynb"
