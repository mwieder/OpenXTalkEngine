#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${libzip_VERSION} is 1.10.1

THIS="libzip"
URL_ROOT="https://libzip.org/download/${THIS}-${libzip_VERSION}.tar.gz"
ARCHIVE_DESTINATION="${THIS}-${libzip_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

			
# run cmake
# run make
# copy files if we have a newer version
function buildSrcLibrary {
	cmake "${BUILDDIR}/${ARCHIVE_DESTINATION}"
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/src/*.h ${FILE_DIRECTORY}
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/src/*.c ${FILE_DIRECTORY}
}

fetchBinary
untarBinary
buildSrcLibrary

