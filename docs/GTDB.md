"# GTDB

```
# on superglass
mkdir /mnt/btrfs/data/gtdb_95
cd /mnt/btrfs/data/gtdb_95

# link information for the database https://gtdb.ecogenomic.org/
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/latest/genomic_files_reps/gtdb_genomes_reps.tar.gz -O- | tar -xz -C /mnt/btrfs/data/gtdb_95

# documentation
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/auxillary_files/gtdbtk_r95_data.tar.gz
tar xvzf gtdbtk_r95_data.tar.gz

# subset for testing from doc
```