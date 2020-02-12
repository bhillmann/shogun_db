import pandas as pd
import numpy as np

df_assembly = pd.read_csv("./scratch/refseq/assembly_summary_refseq.txt", delimiter='\t', skiprows=1)
# df_taxonkit = pd.read_csv("./scratch/refseq/taxonkit_output.txt", delimiter='\t', header=None)
df_taxonkit = pd.read_csv("./scratch/refseq/taxonkit_output.txt", delimiter='\t', header=None,
                          names=['taxid', 'full_taxastr', 'taxid_taxastr', 'taxastr'])

# convert taxid to int
df_assembly["taxid"] = df_assembly["taxid"].astype(np.int)
df_taxonkit["taxid"] = df_taxonkit["taxid"].astype(np.int)
df_taxonkit = df_taxonkit.drop_duplicates(["taxid"])

# remove spaces from taxastr
df_taxonkit["taxastr"] = df_taxonkit["taxastr"].str.replace(" ", "_")
# remove special characters
df_taxonkit["taxastr"] = df_taxonkit["taxastr"].str.replace("&&&", "")

df_assembly = pd.merge(df_assembly, df_taxonkit, on='taxid')

df_assembly = df_assembly.rename(columns={
    "# assembly_accession": "assembly_accession"
})

df_assembly_subset = df_assembly.query(
    'version_status == "latest"' + \
    'and genome_rep == "Full"' + \
    'and refseq_category in ["reference genome", "representative genome"]'
)
print(df_assembly_subset.shape)
# Out[10]: (1845, 25)

df_assembly_subset_reference = df_assembly.query(
    'refseq_category in ["reference genome", "representative genome"]'
)
print(df_assembly_subset_reference.shape)
# Out[8]: (6870, 25)
