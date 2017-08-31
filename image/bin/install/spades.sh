#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

URL="http://spades.bioinf.spbau.ru/release${SPADES_VERSION}/SPAdes-${SPADES_VERSION}-Linux.tar.gz"
fetch_archive.sh ${URL} spades
ln -s /usr/local/spades/bin/* /usr/local/bin
rm -rf /usr/local/spades/share/spades/test_dataset*
