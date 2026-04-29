#!/usr/bin/env bash
set -euo pipefail

# ====== DOWNLOAD SNAKEMAKE ======

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh -bc

~/miniforge3/bin/conda env create -y --file workflow/envs/snakemake.yaml
rm Miniforge3-$(uname)-$(uname -m).sh
