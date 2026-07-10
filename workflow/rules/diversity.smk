rule AsvNormalization:
    input:
        counts_tab = "<results>/ASVs_counts.tsv"
    output:
        norm_tab = "<results>/ASVs_counts_normalized.tsv",
        euclidean_dist = "<results>/ASVs_euclidean_distance.tsv"
    script:
        "../scripts/asv_normalization.R"

rule AlphaBetaDiversity:
    input:
        norm_counts_tab = "<results>/ASVs_counts_normalized.tsv",
        distances_matrix = "<results>/ASVs_euclidean_distance.tsv"
    output:
        ab_report = '<reports>/alpha_beta.pdf'
    shell:
        "quarto render workflow/report/alpha_beta.qmd --to pdf "
        "-o AlphaBetaDiversity.pdf "
        "-P i_norm_counts_tab:{input.norm_counts_tab} "
        "-P i_distances_matrix:{input.distances_matrix} "
        "&& "
        "mv AlphaBetaDiversity.pdf {output.ab_report}"
