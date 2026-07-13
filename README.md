# kyh_microbio_depression

16S rRNA amplicon analysis of the gut microbiome in depression (KYH cohort).

The pipeline pulls reads from NCBI SRA, trims primers, calls ASVs with DADA2,
assigns taxonomy against SILVA, and runs diversity + functional (PICRUSt2)
analyses. It is a [Snakemake](https://snakemake.readthedocs.io) workflow laid
out according to the
[official standardized structure](https://snakemake.readthedocs.io/en/stable/snakefiles/deployment.html#distribution-and-reproducibility).

## Quick start

```bash
pixi run snakemake_dry     # dry run — see what would execute
pixi run snakemake_all     # run the workflow
pixi run snakemake_dag     # render the DAG to results/reports/workflow-dag.pdf
pixi run snakemake_report  # render the Snakemake HTML report
```

Always invoke Snakemake **from the repository root**: `configfile:` and the
`pathvars` in `config/config.yaml` are resolved relative to the working
directory. `workflow/rules/common.smk` additionally raises a `WorkflowError`
if `pathvars` is absent — passing `--configfile` on the command line makes
Snakemake skip the declared config without complaining.

Run flags (cores, conda, resources) live in `workflow/profiles/default/config.yaml`,
which Snakemake discovers automatically.

## Layout

```
config/config.yaml            workflow configuration + pathvars
resources/                    reference DBs and metadata (mostly gitignored)
  SILVA_SSU_r138.2_v2.RData
  metadata/all_meta.csv       sample sheet consumed by the workflow
workflow/
  Snakefile                   entry point, `rule all`
  rules/*.smk                 rule modules
  scripts/*.R                 scripts invoked via the `script:` directive
  scripts/common/*.R          shared R libraries (plotting helpers), `source()`d
  notebooks/                  eda and dev notebooks (.ipynb primarily)
  envs/*.yaml                 conda environments
  reports/*.qmd               Quarto reports
  profiles/default/config.yaml
data/{raw,temp}/              reads and intermediates (gitignored)
logs/                         rule logs (gitignored)
results/                      outputs (gitignored)
```

Paths written as `<results>`, `<samples>`, `<temp>` in the rules are Snakemake 9
[pathvars](https://snakemake.readthedocs.io), resolved from the `pathvars:`
section of `config/config.yaml`.

## Pipeline steps

**Load and trim** (`rules/load_and_trim.smk`) — downloads `.fastq` from NCBI SRA
(driven by `resources/metadata/SraRunTable.csv`), trims primers with cutadapt
(minLength 215, maxLength 285, untrimmed reads discarded), and quality-filters
with DADA2. Emits cutadapt and filterAndTrim QC reports.

**Taxonomy** (`rules/dada2.smk`) — learns error models, calls ASVs per
sequencing batch, merges batches, removes chimeras, and assigns taxonomy with
DECIPHER `IdTaxa` against SILVA SSU r138.2. Emits `results/ASVs.fa`,
`ASVs_counts.tsv`, `ASVs_taxa.tsv`, `reads_loss_summary.tsv`.

**Functional prediction** (`rules/functional.smk`) — PICRUSt2 pipeline producing
KO and pathway abundance tables.

**Diversity** (`rules/diversity.smk`) — DESeq2 VST normalization, Euclidean
distance matrix, and the alpha/beta diversity report rendered from
`workflow/report/alpha_beta.qmd`.

**Differential abundance** (`rules/diff_abundance.smk`) — not wired up yet; see
the TODO at the top of that file.

## Data and privacy

Subject-level clinical metadata (`resources/metadata/`) is **not** tracked.
Only `SraRunTable.csv` and `kyh_variables_description.csv` are committed. Check
`.gitignore` before adding anything under `resources/`.
