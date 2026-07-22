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
  notebooks/                  eda (started from _eda) and dev (started from _dev) notebooks (.ipynb primarily)
  envs/*.yaml                 conda environments
  reports/*.qmd               Ready to render Quarto reports
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


## Analysis roadmap

### Upstream & ASV inference
- [x] Contaminant removal — done upstream, before NCBI upload (outside this pipeline)
- [x] SRA download + primer trimming (cutadapt) + DADA2 quality filtering, with QC reports
- [x] Error models + per-batch ASV calling (DADA2), batch merge, chimera removal
- [x] Taxonomy assignment (DECIPHER IdTaxa vs SILVA SSU r138.2)
- [x] Results export: ASVs.fa, ASVs_counts.tsv, ASVs_taxa.tsv, reads_loss_summary.tsv
- [ ] Prevalence/abundance filtering + drop mitochondria / chloroplast / unassigned
- [ ] (optional) Phylogenetic tree (align + build) → enables UniFrac / Faith's PD

### Diversity — beta
- [x] DESeq2 VST normalization + Euclidean distance matrix
- [x] PCoA ordination + sample dendrogram
- [x] PERMANOVA (adonis2) with covariates (batch, sex, age)
- [x] Switch adonis2 to by="margin" (or reorder terms) so the depression effect is covariate-adjusted
- [ ] Fix mislabeled "beta dispersion" wording (PERMANOVA tests location, not dispersion)
- [x] betadisper / PERMDISP dispersion test (required to interpret PERMANOVA correctly)
- [ ] Resolve flagged PCoA outliers (biological vs technical)

### Diversity — alpha  (NOT STARTED)
- [x] Feed raw ASVs_counts.tsv into the report (VST is invalid for richness)
- [ ] Alpha metrics: Observed, Shannon (+ Faith's PD if a tree is built)
- [ ] Group tests, covariate-adjusted (case/control)

- [ ] Harden alpha/beta report to publish-ready

### Differential abundance — ASVs
- [ ] Wire up diff_abundance.smk (currently a stub)
- [ ] DESeq2 + MaAsLin2 on raw counts, covariate-adjusted (case/control); report consensus + effect sizes
- [ ] Report, publish-ready

### Functional prediction
- [x] PICRUSt2 pipeline → KO + pathway unstrat tables (max_nsti 2)
- [ ] NSTI QC: report weighted / per-sample NSTI, document filtering + prediction limitations
- [ ] Pin PICRUSt2 env (envs/picrust2.yaml) instead of hardcoded `conda: picrust2`
- [ ] Gut-brain / gut-metabolic modules (GBM/GMM, Omixer-RPM) — depression-specific layer
- [ ] Functional report, publish-ready

### Differential abundance — KO / KEGG pathways
- [ ] DESeq2 + MaAsLin2 on KO and pathway tables
- [ ] Report, publish-ready

### Community structure
- [ ] DMM clustering: model selection (Laplace / BIC), assign community types
- [ ] Test community type ~ depression status + covariates (case/control)
- [ ] Report, publish-ready

### Interaction networks
- [ ] Per-group co-occurrence networks (SPIEC-EASI / SparCC, compositionality-aware)
- [ ] Differential network analysis depression vs control (e.g. NetCoMi) + hub / keystone taxa
- [ ] Report, publish-ready

### Cross-cutting (publish-readiness)
- [ ] Lock covariate set (batch, sex, age; + antidepressants/PPIs/BMI/Bristol if available) and apply consistently across DA / DMM / networks
- [ ] Consistent FDR across all DA blocks; report effect sizes, not only p-values
- [ ] Fixed seeds for stochastic steps (DMM, SPIEC-EASI) + env/version locking (pixi / Apptainer) + sessionInfo
- [ ] STORMS reporting checklist
- [ ] Unified methods draft + consistent figure style