#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${LIBZ_VERSION} is 1.6.45
#libpng-1.6.45.tar.xz

THIS="libpng"
# should do this with sed
PNG_VERSION=$(echo ${libpng_VERSION} | sed 's/\.//g')
#UNTARRED="lpng1645"
UNTARRED="lpng${PNG_VERSION}"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libpng_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function unxzBinary
{
	PNG_LATEST=$(ls ${THIS}*.tar | sed 's/libpng//g')
#	echo "Untarring ${THIS}-${libpng_VERSION}"
	echo "Untarring ${THIS}${PNG_LATEST}"
#	unzip -o "${THIS}-${libpng_VERSION}.tar"
	unzip -o "${THIS}${PNG_LATEST}"
}


fetchBinary
unxzBinary
mv "${UNTARRED}" "${ARCHIVE_DESTINATION}"
buildLibrary
