conda create -n seqkit -c bioconda -c conda-forge seqkit

# according to the website, we can run up to 50 jobs at once
# https://www.msi.umn.edu/queues
seqkit split2 ./shear_100_50.fna -p 24 -f

```
python shear_db.py Rep94.fasta 100 50 > Rep94.shear.fasta
burst15 -t 16 -q Rep94.shear.fasta -a Rep94.acx -r Rep94.edx -o Rep94.shear.b6 -m ALLPATHS -fr -i 0.98
sed 's/_/./1' Rep94.shear.b6 > Rep94.shear.fixed.b6
embalmulate Rep94.shear.fixed.b6 Rep94.shear.otu.txt
python shear_results_fix.py Rep94.shear.otu.txt Rep94.tax Rep94.shear
```

````
# testing the memory usage of aligning 1m 100 bp queries
/usr/bin/time -v /scratch.global/ben/refseq/burst_linux_DB15 -t 32 -q /scratch.global/ben/shear_100_50.1m.fna -a /scratch.global/ben/refseq/rep200_fn.acx -r /scratch.global/ben/refseq/rep200_fn.edx -o /scratch.global/ben/refseq/shear_100_50.1m.b6 -m ALLPATHS -fr -i 0.98
```

```
# Let me gather the database together on MSI, superglass, and teraminx
# Teraminx
/project/flatiron/data/rep200/rep200_abfpv/shogun
# superglass
/mnt/btrfs/data/rep200/shogun
# msi
/scratch.global/ben/refseq/shogun
```

# Shearing
```
# Next step is to check to see if the shearing of the file worked
# on teraminx
time rsync -rP hillm096@login.msi.umn.edu:/scratch.global/ben/refseq/shear_100_50.1m.b6 /project/flatiron/data/rep200/rep200_abfpv/shogun/shear_100_50.1m.b6
# on superglass
time rsync -rP hillm096@teraminx.cs.umn.edu:/project/flatiron/data/rep200/rep200_abfpv/shogun/shear_100_50.1m.b6 /mnt/btrfs/data/rep200/shogun/shear_100_50.1m.b6  


```