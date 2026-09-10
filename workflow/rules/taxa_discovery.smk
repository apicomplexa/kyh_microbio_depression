rule FilterASVs:
    input:
        ps_raw='<temp>/ps_raw.rds'
    output:
        counts_tab = "<results>/ASVs_counts_filtered.tsv",
        ps_core = "<temp>/ps_core.rds"
    params:
        prevalence_threshold=0.05,
        detection_threshold=1
    script:
        "../scripts/filter_core_asvs.R"

rule AsvNormalization:
    input:
        ps_raw='<temp>/ps_{ps}.rds'
    output:
        norm_tab = "<results>/ASVs_counts_{ps}_normalized.tsv",
        euclidean_dist = "<results>/ASVs_euclidean_{ps}_distance.tsv",
        ps_vst = "<temp>/ps_{ps}_vst.rds"
    script:
        "../scripts/asv_vst_normalization.R"

rule AlphaBetaDiversity:
    input:
        ps_core = "<temp>/ps_core.rds",
        ps_norm = "<temp>/ps_core_vst.rds",
        distances_matrix = "<results>/ASVs_euclidean_core_distance.tsv"
    # output:
    #     ab_report = '<reports>/alpha_beta.pdf'
    # shell:
    #     "quarto render workflow/report/alpha_beta.qmd --to pdf "
    #     "-o AlphaBetaDiversity.pdf "
    #     "-P i_norm_counts_tab:{input.norm_counts_tab} "
    #     "-P i_distances_matrix:{input.distances_matrix} "
    #     "&& "
    #     "mv AlphaBetaDiversity.pdf {output.ab_report}"
