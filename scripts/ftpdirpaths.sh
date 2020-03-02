#!/usr/bin/env bash
ASSEMBLY_SUMMARY=$1
OUTPUT_FILE=$2
awk -F "\t" '($5 == "representative genome" || $5 == "reference genome") && $14=="Full" && $11=="latest"{print $20}' ${ASSEMBLY_SUMMARY} >> ${OUTPUT_FILE}