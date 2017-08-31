#!/bin/bash

set -o errexit
set -o nounset
set -o xtrace

NON_ESSENTIAL_BUILD="ca-certificates wget"
SPADES="python-minimal python-setuptools"
BBTOOLS="openjdk-7-jre-headless pigz"

# Build dependencies
apt-get update --yes
apt-get install --yes --no-install-recommends ${NON_ESSENTIAL_BUILD}

export PATH=$PATH:/usr/local/bin/install

# Install individual tools
spades.sh
bbtools.sh

# Clean up dependencies
apt-get autoremove --purge --yes ${NON_ESSENTIAL_BUILD}
apt-get clean

# Install required files
apt-get install --yes --no-install-recommends ${SPADES} ${BBTOOLS}

rm -rf /var/lib/apt/lists/*

# Remove all no-longer-required build artefacts
EXTENSIONS=("pyc" "c" "cc" "cpp" "h" "o" "pdf")
for EXT in "${EXTENSIONS[@]}"
do
	find /usr/local -name "*.$EXT" -delete
done
