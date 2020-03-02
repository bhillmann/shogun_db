#!/usr/bin/env bash
FTPDIRPATHS=$1
FTPFILEPATHS=$2
awk 'BEGIN{FS=OFS="/";filesuffix="genomic.fna.gz"}{ftpdir=$0;asm=$10;file=asm"_"filesuffix;print ftpdir,file}' ${FTPDIRPATHS} >> ${FTPFILEPATHS}