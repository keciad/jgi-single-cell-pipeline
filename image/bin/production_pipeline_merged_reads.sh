#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

SEQ_FILES=/usr/local/bbmap/resources

TMP_READS_1=$(mktemp -d)/reads.fq.gz
TMP_READS_2=$(mktemp -d)/reads.fq.gz
TMP_OUT=$(mktemp -d)


FILTERED_READS=$(mktemp -d)/reads.fq.gz
OUTPUT_MERGED=$(mktemp -d)/merged.fq.gz
OUTPUT_UNMERGED=$(mktemp -d)/unmerged.fq.gz

INPUT=$1
OUTPUT=$2

clumpify.sh \
	interleaved=t \
	pigz=t \
	unpigz=t \
	zl=4 \
	passes=1 \
	reorder \
	in1=${INPUT} \
	out1=${TMP_READS_1}

bbduk.sh \
	interleaved=t \
	ktrim=r \
	ordered \
	minlen=51 \
	minlenfraction=0.33 \
	mink=11 \
	tbo \
	tpe \
	rcomp=f \
	overwrite=true \
	k=23 \
	hdist=1 \
	hdist2=1 \
	ftm=5 \
	zl=4 \
	ow=true \
	rqc=hashmap \
	loglog \
	ref=${SEQ_FILES}/adapters.fa \
	in1=${TMP_READS_1} \
	out1=stdout.fq \
| bbduk.sh \
	interleaved=t \
	ordered \
	overwrite=true \
	k=20 \
	hdist=1 \
	pigz=t \
	zl=6 \
	ow=true \
	ref=${SEQ_FILES}/short.fa \
	in1=stdin.fq \
	out1=${TMP_READS_2}

reformat.sh \
	interleaved=t \
	samplereadstarget=5000000 \
	pigz=t \
	unpigz=t \
	in1=${TMP_READS_2} \
	out1=${FILTERED_READS}

bbmerge-auto.sh \
	interleaved=t \
	in=${FILTERED_READS} \
	out=${OUTPUT_MERGED} \
	outu=${OUTPUT_UNMERGED} \
	pigz=t \
	strict \
	k=93 \
	extend2=80 \
	rem \
	ordered


# Check which files contain reads
ARGS=()
[[ ! -s ${OUTPUT_UNMERGED} ]] || ARGS+=(" --pe1-12 ${OUTPUT_UNMERGED}")
[[ ! -s ${OUTPUT_MERGED} ]] || ARGS+=(" --s2 ${OUTPUT_MERGED}")


spades.py \
	${ARGS[@]} \
	-o ${TMP_OUT} \
	--threads $(nproc) \
	--phred-offset 33 \
	--cov-cutoff auto \
	--careful \
	-k 25,55,95

reformat.sh \
	in=${TMP_OUT}/contigs.fasta \
	out=${OUTPUT} \
	minlength=1000

rm -rf /tmp/tmp.*
