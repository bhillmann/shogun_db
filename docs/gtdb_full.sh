#!/usr/bin/env bash
for f in *.fna.gz; do FN=${f/_/-}; FN=${FN/_*/}; mv $f ${FN/-/_}.fna.gz; done

/mnt/nvidia/pkr/code/BURST/bin/lingenome . gtdb.fna FILENAME

/mnt/nvidia/pkr/code/BURST/bin/burst_linux_DB15 -r gtdb.fna -o gtdb.edx -a gtdb.acx -d DNA 320 -i 0.95 -t 40 -s 1500

# shear the database
/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/shear_db.py -f ./gtdb.fna -r 100 -s 50 -o ./shear_100_50.fna
/usr/bin/time -v /mnt/nvidia/pkr/code/BURST/bin/burst_linux_DB15 -t 40 -q ./shear_100_50.fna -a gtdb.acx -r gtdb.edx -o gtdb.shear.b6 -m ALLPATHS -fr -i 0.98
sed 's/_/./1' gtdb.shear.b6 | sed 's/_/./1' > gtdb.shear.fixed.b6
/mnt/nvidia/pkr/code/BURST/embalmlets/bin/embalmulate gtdb.shear.fixed.b6 gtdb.shear.otu.txt

# download the taxonomy
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/ar122_taxonomy_r95.tsv -O- > r95.tax
wget https://data.ace.uq.edu.au/public/gtdb/data/releases/release95/95.0/bac120_taxonomy_r95.tsv -O- >> r95.tax

# build the taxonomy files
/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/gtdb_taxonomy.py --fasta /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/gtdb.fna --taxa_table /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/r95.tax --output /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/r95.filtered.tax
/usr/bin/time -v python /mnt/nvidia/pkr/code/helix/helix/shear_results.py --alignment /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/gtdb.shear.otu.txt --taxa_table /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/r95.filtered.tax --output /mnt/btrfs/data/gtdb_95/gtdb_genomes_reps_r95/sheared_bayes.txt