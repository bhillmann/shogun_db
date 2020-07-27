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
mkdir ../gtdb_genomes_reps_r95_20
ls | head -n 20 | xargs cp -t ../gtdb_genomes_reps_r95_20

for f in *.fna.gz; do FN=${f/_/-}; FN=${FN/_*/}; mv $f ${FN/-/_}.fna.gz; done

/mnt/nvidia/pkr/code/BURST/bin/lingenome . gtdb_20.fna FILENAME

/mnt/nvidia/pkr/code/BURST/bin/burst_linux_DB15 -r gtdb_20.fna -o gtdb_20.edx -a gtdb_20.acx -d DNA 320 -i 0.95 -t 40 -s 1500

# shear the database
/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/shear_db.py -f ./gtdb_20.fna -r 100 -s 50 -o ./shear_100_50.fna
/usr/bin/time -v /mnt/nvidia/pkr/code/BURST/bin/burst_linux_DB15 -t 40 -q ./shear_100_50.fna -a gtdb_20.acx -r gtdb_20.edx -o gtdb_20.shear.b6 -m ALLPATHS -fr -i 0.98
sed 's/_/./1' gtdb_20.shear.b6 | sed 's/_/./1' > gtdb_20.shear.fixed.b6
/mnt/nvidia/pkr/code/BURST/embalmlets/bin/embalmulate gtdb_20.shear.fixed.b6 gtdb_20.shear.otu.txt

wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/ar122_taxonomy_r95.tsv -O- > r95.tax
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/bac120_taxonomy_r95.tsv -O- >> r95.tax

/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/gtdb_taxonomy.py --fasta /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/gtdb_20.fna --taxa_table /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/r95.tax --output /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/r95_20.tax
/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/shear_results.py --alignment /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/gtdb_20.shear.otu.txt --taxa_table /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/r95_20.tax --output /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95_20/sheared_bayes.txt
```