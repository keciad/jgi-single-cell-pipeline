#!/bin/bash

set -o errexit
set -o pipefail
set -o xtrace

SEQ_FILES=/usr/local/bbmap/resources

FILTERED_READS=$(mktemp -d)/reads.fq.gz
TMP_OUT=$(mktemp -d)


INPUT=$1
OUTPUT=$2

clumpify.sh \
	unpigz=t \
	zl=4 \
	passes=1 \
	reorder \
	in1=${INPUT} \
	out1=stdout.fq \
| bbduk.sh \
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
	in1=stdin.fq \
	out1=stdout.fq \
| bbduk.sh \
	ordered \
	overwrite=true \
	k=20 \
	hdist=1 \
	pigz=t \
	zl=6 \
	ow=true \
	ref=${SEQ_FILES}/short.fa \
	in1=stdin.fq \
	out1=${FILTERED_READS}

spades.py \
	-o ${TMP_OUT} \
	--phred-offset 33 \
	--cov-cutoff auto \
	--careful \
	-k 25,55,95 \
	--12 ${FILTERED_READS}

cp ${TMP_OUT}/contigs.fasta ${OUTPUT}
rm -rf ${FILTERED_READS} ${TMP_OUT}
