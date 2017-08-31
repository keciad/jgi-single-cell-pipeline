#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

URL="http://downloads.sourceforge.net/project/bbmap/BBMap_${BBTOOLS_VERSION}.tar.gz"
fetch_archive.sh ${URL} bbmap
ln -s /usr/local/bbmap/*.sh /usr/local/bin
