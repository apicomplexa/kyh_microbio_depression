from collections import defaultdict
import pandas as pd

METADATA_TAB = pd.read_csv('data/initial/all_meta.csv', index_col='Run')

SRA_RUNS = METADATA_TAB.index.to_list()
BATCH_TO_SAMPLES = defaultdict(list)

for sample_id, row in METADATA_TAB.iterrows():
    BATCH_TO_SAMPLES[row['batch']].append(sample_id)

BATCHES = list(BATCH_TO_SAMPLES.keys())