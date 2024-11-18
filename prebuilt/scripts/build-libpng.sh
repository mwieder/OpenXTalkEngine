#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${LIBZ_VERSION} is 1.6.43
#libpng-1.6.43.tar.xz

THIS="libpng"
# should do this with sed
UNTARRED="lpng1644"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libpng_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function unxzpngBinary
{
	echo "Untarring ${THIS}-${libpng_VERSION}"
	unzip -o "${THIS}-${libpng_VERSION}.tar"
}


fetchBinary
unxzpngBinary
echo "renaming ${UNTARRED} to ${ARCHIVE_DESTINATION}"
mv "${UNTARRED}" "${ARCHIVE_DESTINATION}"
buildLibrary

