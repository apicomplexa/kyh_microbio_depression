rule FunctionalAnalysis:
    input:
        fa='<results>/ASVs.fa',
        counts='<results>/ASVs_counts.tsv'
    output:
        path='<results>/picrust2/pathways_out/path_abun_unstrat.tsv.gz',
        ko='<results>/picrust2/KO_metagenome_out/pred_metagenome_unstrat.tsv.gz'
    params:
        outdir=lambda wc, output: subpath(output.path, ancestor=2),
        nsti=2
    # conda: "../envs/picrust2.yaml"
    conda: "picrust2" # ready conda env because snakemake on my system refuse to download dependencies 
    threads: 12
    shell:
        """
        rm -rf {params.outdir}
        picrust2_pipeline.py \
            -s {input.fa} \
            -i {input.counts} \
            -o {params.outdir} \
            -p {threads} \
            --max_nsti {params.nsti} \
            --verbose
        """
