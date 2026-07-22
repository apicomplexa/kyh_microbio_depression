rule LearnErrors:
    input: expand("<samples_filter>/{sample}_R{{n}}.fastq.gz", sample=SRA_RUNS)
    output:
        error_model='<temp>/err_model_R{n}.rds',
        error_model_plot='<figures>/dada2_error_model_R{n}.png',
    params:
        band='R{n}'
    threads: 6
    script:
        '../scripts/learn_error.R'

rule AVSCalling:
    input:
        r1=lambda wc: expand("<samples_filter>/{sample}_R1.fastq.gz", sample=BATCH_TO_SAMPLES[wc.batch]),
        r2=lambda wc: expand("<samples_filter>/{sample}_R2.fastq.gz", sample=BATCH_TO_SAMPLES[wc.batch]),
        error_r1='<temp>/err_model_R1.rds',
        error_r2='<temp>/err_model_R2.rds'
    output:
        seqtab=temp('<temp>/batch/{batch}/seqtab.rds'),
        dada2=temp('<temp>/batch/{batch}/dada2.rds'),
    threads: 8
    resources:
        mem_mb=10000
    script:
        '../scripts/asv_calling.R'

rule AggregateBatches:
    input:
        batches_seqtab=expand('<temp>/batch/{batch}/seqtab.rds', batch=BATCHES)
    output:
        seqtab='<temp>/seqtab.rds'
    script:
        '../scripts/aggregate_seqtabs_batches.R'

rule ChimeraRemoval:
    input:
        seqtab='<temp>/seqtab.rds'
    output:
        seqtab_nochim='<temp>/seqtab_nochim.rds'
    threads: 8
    resources:
        mem_mb=10000
    script:
        '../scripts/chimera_removal.R'

rule AssignTaxonomy:
    input:
        seqtab_nochim='<temp>/seqtab_nochim.rds',
        silva=config['silva_db']
    output:
        tax='<temp>/taxonomy.rds'
    threads: 8
    script:
        '../scripts/assign_taxonomy.R'

rule SaveResults:
    input:
        seqtab='<temp>/seqtab.rds',
        seqtab_nochim='<temp>/seqtab_nochim.rds',
        filterAndTrimReports=expand('<reports>/qc/filterAndTrim/report_{sra_run}.tsv', sra_run=SRA_RUNS),
        taxa='<temp>/taxonomy.rds',
        metadata=config['samples_meta']
    output:
        reads_loss_summary='<results>/reads_loss_summary.tsv',
        fa='<results>/ASVs.fa',
        counts='<results>/ASVs_counts.tsv',
        tax='<results>/ASVs_taxa.tsv',
        reads_loss_plot='<figures>/reads_loss_plot.png',
        red_zone_samples='<results>/red_zone_samples.txt'
    script:
        '../scripts/save_dada2_results.R'
