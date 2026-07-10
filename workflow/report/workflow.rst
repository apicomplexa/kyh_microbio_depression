16S rRNA amplicon analysis of the gut microbiome in depression (KYH cohort).

Reads are pulled from NCBI SRA, primers are trimmed with cutadapt, and reads are
quality-filtered with DADA2. ASVs are called per sequencing batch, merged,
chimera-filtered, and assigned taxonomy against SILVA SSU r138.2 via DECIPHER.
Downstream: VST normalization, alpha/beta diversity, and PICRUSt2 functional
prediction.

Configuration lives in ``config/config.yaml``; the sample sheet is
``resources/metadata/all_meta.csv``.
