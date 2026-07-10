
rule LoadFastqBySRR:
    output:
        fq=expand('<samples>/raw/{{sra_run}}_{n}.fastq', n=[1,2])
    params:
        outDir=lambda wc, output: subpath(output.fq[0], parent=True)
    shell:
        'fasterq-dump {wildcards.sra_run} -O {params.outDir}'


rule CompressAndRenameFastq:
    input:
        fq='<samples>/raw/{sra_run}_{n}.fastq'
    output:
        fq='<samples>/raw/{sra_run}_R{n}.fastq.gz'
    shell:
        'pigz -c {input.fq} > {output.fq} && '
        'rm {input.fq}'

rule CutAdapters:
    input:
        fastq=expand('<samples>/raw/{{sra_run}}_R{n}.fastq.gz', n=[1,2])
    output:
        fastq=expand('<samples>/trimmed/{{sra_run}}_R{n}.fastq.gz', n=[1,2]),
        report='<reports>/qc/cutadapt/report_{sra_run}.json.gz'
    log:
        "<logs>/cutadapt/{sra_run}.log"
    shell:
        "cutadapt "
        "-g CCTACGGGNGGCWGCAG "
        "-G GACTACHVGGGTATCTAATCC "
        "-m 215 -M 285 --discard-untrimmed "
        "-o {output.fastq[0]} -p {output.fastq[1]} "
        "{input} --json={output.report} > {log} 2>&1"

rule FilterAndTrim:
    input:
        fq=expand("<samples>/trimmed/{{sample}}_R{n}.fastq.gz", n=[1, 2])
    output:
        fq=expand("<samples_filter>/{{sample}}_R{n}.fastq.gz", n=[1, 2]),
        report='<reports>/qc/filterAndTrim/report_{sample}.tsv'
    params:
        trunc_len_f=config['trimming']['trunc_len_f'],
        trunc_len_r=config['trimming']['trunc_len_r'],
        max_ee_f=config['trimming']['max_ee_f'],
        max_ee_r=config['trimming']['max_ee_r']
    resources:
        mem_mb=1100
    script:
        '../scripts/dada2_filter_and_trim.R'
