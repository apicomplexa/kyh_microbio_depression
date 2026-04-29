# 01_load_and_trim

## Description
Loads `.fastq` files form NSBI SRA, trimms primers and creates QC reports

## Inputs
- `SraRunTable.csv` providing on SRA run explorer page

## Outputs
- Trimmed `.fastq` without primers, minLength 215, maxLength=285, untrimmed read were discard
- MultiQC report aggregating FastQC report (for trimmed reads)? cutadapt report

