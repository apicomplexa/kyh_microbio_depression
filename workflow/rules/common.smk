from collections import defaultdict
import pandas as pd
from snakemake.exceptions import WorkflowError

# `configfile:` is resolved against the working directory. A missing file
# raises on its own, but when `--configfile` is passed on the command line the
# declared config/config.yaml is skipped without any error, so guard the keys
# the rules actually depend on.
if "pathvars" not in config:
    raise WorkflowError(
        "config/config.yaml was not loaded. Run snakemake from the repository "
        "root, and if you pass --configfile make sure it defines `pathvars`."
    )

METADATA_TAB = pd.read_csv(config['samples_meta'], index_col='Run')

SRA_RUNS = METADATA_TAB.index.to_list()
BATCH_TO_SAMPLES = defaultdict(list)

for sample_id, row in METADATA_TAB.iterrows():
    BATCH_TO_SAMPLES[row['batch']].append(sample_id)

BATCHES = list(BATCH_TO_SAMPLES.keys())
