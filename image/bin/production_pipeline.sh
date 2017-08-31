#!/bin/bash

set -o errexit
set -o pipefail

INPUT=$1
OUTPUT=$2
FILTERED_READS=$(mktemp -d)/reads.fq.gz

PIPE="in=stdin.fq out=stout.fq"

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
	ref=adapters2.fa \
	${PIPE} \
| bbduk.sh \
	maq=5,0 \
	trimq=10 \
	qtrim=f \
	ordered \
	maxns=1 \
	minlen=51 \
	minlenfraction=0.33 \
	k=25 \
	hdist=1 \
	zl=6 \
	cf=t \
	barcodefilter=crash \
	ow=true \
	rqc=hashmap \
	loglog \
	ref=pJET1.2.fasta \
	${PIPE} \
| bbduk.sh \
	ordered \
	overwrite=true \
	k=20 \
	hdist=1 \
	pigz=t \
	zl=6 \
	ow=true \
	ref=short.fa \
	out1=${FILTERED_READS}

spades.py \
	-o ${OUTPUT} \
	--phred-offset 33 \
	--cov-cutoff auto \
	--careful \
	-k 25,55,95 \
	--12 ${FILTERED_READS}

rm -f ${FILTERED_READS}
