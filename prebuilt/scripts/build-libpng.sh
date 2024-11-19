#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${LIBZ_VERSION} is 1.6.44
#libpng-1.6.44.tar.xz

THIS="libpng"
# should do this with sed
PNG_VERSION=$(echo ${libpng_VERSION} | sed 's/\.//g')
#UNTARRED="lpng1644"
UNTARRED="lpng${PNG_VERSION}"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libpng_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function unxzBinary
{
	echo "Untarring ${THIS}-${libpng_VERSION}"
	unzip -o "${THIS}-${libpng_VERSION}.tar"
}


fetchBinary
unxzBinary
mv "${UNTARRED}" "${ARCHIVE_DESTINATION}"
buildLibrary

