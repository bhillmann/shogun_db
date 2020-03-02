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

${OUTPUT_DIR}/assembly_summary_refseq.txt  : ${OUTPUT_DIR}
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

${OUTPUT_DIR}/ftpdirpaths : ${OUTPUT_DIR}/assembly_summary_refseq.txt
	scripts/ftpdirpaths.sh ${OUTPUT_DIR}/assembly_summary_refseq.txt ${OUTPUT_DIR}/ftpdirpaths

${OUTPUT_DIR}/ftpfilepaths : ${OUTPUT_DIR}/ftpdirpaths
	scripts/ftpfilepaths.sh ${OUTPUT_DIR}/ftpdirpaths ${OUTPUT_DIR}/ftpfilepaths

${OUTPUT_DIR}/genomes/%.gz : ${OUTPUT_DIR}/ftpfilepaths
	mkdir -p ${OUTPUT_DIR}/genomes
	cat ${OUTPUT_DIR}/ftpfilepaths | xargs -n 1 -P 16 wget -q --retry-c
	 onnrefused --waitretry=1 --read-timeout=20 --timeout=15 -t 99 -P ${OUTPUT_DIR}/genomes

#${OUTPUT_DIR}/combined_seqs.fna ${OUTPUT_DIR}/combined_plasmids.fna : ${OUTPUT_DIR}/fnas/%.fna
#	scripts/lingenome ${OUTPUT_DIR}/fnas/%.fna ${OUTPUT_DIR}/combined_seqs.fna ${OUTPUT_DIR}/combined_plasmids.fna HEADFIX

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

ftpdirpaths : ${OUTPUT_DIR}/combined_seqs.fna ${OUTPUT_DIR}/combined_plasmids.fna

all : ${OUTPUT_DIR}/taxonkit_output.txt ftpdirpaths
