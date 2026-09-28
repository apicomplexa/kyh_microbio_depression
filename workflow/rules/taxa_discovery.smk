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

rule TaxaDiversity:
    input:
        ps_raw = "<temp>/ps_raw.rds",
        ps_core = "<temp>/ps_core.rds",
        euc_dist_core = "<results>/ASVs_euclidean_core_distance.tsv"
    output:
        ab_report = '<reports>/taxonomy_overview.pdf'
    shell:
        "quarto render workflow/report/taxonomy.qmd --to pdf "
        "-o taxonomy_overview.pdf "
        "-P ps_raw:{input.ps_raw} "
        "-P ps_core:{input.ps_core} "
        "-P euc_dist_core:{input.euc_dist_core}  "
        "&& "
        "mv taxonomy_overview.pdf {output.ab_report}"
