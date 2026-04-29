def extract_sra_run_table():
    import pandas as pd
    return pd.read_csv('data/initial/SraRunTable.csv')['Run'].to_list()[:5]