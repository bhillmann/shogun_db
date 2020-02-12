# Usage
# make			# make a specific database
# make clean	# remove database

OUTPUT_DIR := scratch/refseq
ASSEMBLY_SUMMARY_LINK := ftp://ftp.ncbi.nlm.nih.gov/genomes/ASSEMBLY_REPORTS/assembly_summary_refseq.txt
NCBI_TAXDUMP := ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz

TAXDUMP_ARRAY := nodes names delnodes merged
TAXDUMP_FILES := $(foreach wrd,$(TAXDUMP_ARRAY),${OUTPUT_DIR}/$(wrd).dmp)

update-conda-env :
	conda env update --file environment.yml

${OUTPUT_DIR} :
	mkdir -p ${OUTPUT_DIR}

${OUTPUT_DIR}/taxdump :
	mkdir -p ${OUTPUT_DIR}/taxdump

TAXDUMP_FILES : ${OUTPUT_DIR}/taxdump
	wget ${NCBI_TAXDUMP} -O - | tar -C ${OUTPUT_DIR}/taxdump -xz

${OUTPUT_DIR}/assembly_summary_refseq.txt : ${OUTPUT_DIR}
#	wget ${ASSEMBLY_SUMMARY_LINK} -O - > ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/assembly_summary.txt' > ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt' | tail -n +3 >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/assembly_summary.txt' | tail -n +3  >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/protozoa/assembly_summary.txt' | tail -n +3  >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	curl 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/viral/assembly_summary.txt' | tail -n +3  >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/archaea/assembly_summary.txt -O- > ${OUTPUT_DIR}/assembly_summary_refseq.txt
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/assembly_summary.txt -O- | tail -n +3 >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/fungi/assembly_summary.txt -O- | tail -n +3 >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/protozoa/assembly_summary.txt -O- | tail -n +3 >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
	wget ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/viral/assembly_summary.txt -O- | tail -n +3 >> ${OUTPUT_DIR}/assembly_summary_refseq.txt
#	awk -F "\t" '($5 == "representative genome" || $5 == "reference genome") && $14=="Full" && $11=="latest"{print $20}' assembly_summary.txt >> ftpdirpaths



${OUTPUT_DIR}/taxids.txt : ${OUTPUT_DIR}/assembly_summary_refseq.txt
	# Skip three lines of the header
	tail -n +3 ${OUTPUT_DIR}/assembly_summary_refseq.txt | cut -f 6 > ${OUTPUT_DIR}/taxids.txt

${OUTPUT_DIR}/taxonkit_output.txt : ${OUTPUT_DIR}/taxids.txt TAXDUMP_FILES
	taxonkit --data-dir ${OUTPUT_DIR}/taxdump lineage -t ${OUTPUT_DIR}/taxids.txt  \
	| taxonkit --data-dir ${OUTPUT_DIR}/taxdump reformat -F -r "&&&" \
	-f "k__{k};p__{p};c__{c};o__{o};f__{f};g__{g};s__{s};t__{S}" \
	> ${OUTPUT_DIR}/taxonkit_output.txt

clean :
	rm -rf ${OUTPUT_DIR}

all : ${OUTPUT_DIR}/taxonkit_output.txt
