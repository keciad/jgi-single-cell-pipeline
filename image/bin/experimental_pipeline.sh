#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

export OUTPUT_MERGED=$(mktemp -d)/merged.fq.gz
export OUTPUT_UNMERGED=$(mktemp -d)/unmerged.fq.gz

export PIPE="in=stdin.fq out=stdout.fq"

export TMP_READS_1=$(mktemp -d)/reads.fq.gz
export TMP_READS_2=$(mktemp -d)/reads.fq.gz
export TMP_OUT=$(mktemp -d)

INPUT=$1
OUTPUT=$2

clumpify.sh \
	in=${INPUT} \
        out=stdout.fq \
	unpigz=t \
	dedupe \
	optical \
| bbduk.sh \
	${PIPE} \
	ktrim=r \
	k=23 \
	mink=11 \
	hdist=1 \
	tbo \
	tpe \
	minlen=70 \
	ref=adapters \
	ftm=5 \
	ordered \
| bbduk.sh  \
	${PIPE} \
	k=31 \
	ref=artifacts,phix \
	ordered \
	cardinality \
| bbmerge.sh \
	${PIPE} \
	ecco \
	mix \
	vstrict \
	ordered \
| clumpify.sh \
	${PIPE} \
	ecc \
	passes=4 \
	reorder \
	in=stdin.fq \
	out=${TMP_READS_1}

# Bug in later bbmap tools doesn't accept reads from stdin.fq
tadpole.sh \
	ecc \
	k=62 \
	ordered \
	pigz=t \
	out=${TMP_READS_2} \
	in=${TMP_READS_1}

bbmerge-auto.sh \
	in=${TMP_READS_2} \
	out=${OUTPUT_MERGED} \
	outu=${TMP_READS_1} \
	overwrite=t \
	pigz=t \
	strict \
	k=93 \
	extend2=80 \
	rem \
	ordered

bbduk.sh \
	in=${TMP_READS_1} \
	out=${OUTPUT_UNMERGED} \
	qtrim=r \
	trimq=10 \
	minlen=70 \
	pigz=t \
	ordered

# Check which files contain reads
ARGS=()
[[ ! -s ${OUTPUT_UNMERGED} ]] || ARGS+=(" --12 ${OUTPUT_UNMERGED}")
[[ ! -s ${OUTPUT_MERGED} ]] || ARGS+=(" -s ${OUTPUT_MERGED}")


spades.py \
	--only-assembler \
	${ARGS[@]} \
	--threads $(nproc) \
	-k25,55,95,125 \
	--phred-offset 33 \
	-o ${TMP_OUT}


cp ${TMP_OUT}/contigs.fasta ${OUTPUT}
rm -fr \
	${OUTPUT_MERGED} \
	${OUTPUT_UNMERGED} \
	${TMP_OUT} \
	${TMP_READS_1} \
	${TMP_READS_2}
