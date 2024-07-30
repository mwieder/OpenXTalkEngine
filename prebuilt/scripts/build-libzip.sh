#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${libzip_VERSION} is 1.10.1

THIS="libzip"
URL_ROOT="https://libzip.org/download/${THIS}-${libzip_VERSION}.tar.gz"
ARCHIVE_DESTINATION="${THIS}-${libzip_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

function buildSrcLibrary {
	cmakeBinary
	mesonBinary
	cp -r ${BUILDDIR}/${ARCHIVE_DESTINATION}/lib/*.h ${FILE_DIRECTORY}
	cp -r ${BUILDDIR}/${ARCHIVE_DESTINATION}/lib/*.c ${FILE_DIRECTORY}
	cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/*.h ${FILE_DIRECTORY}
}

fetchBinary
untarBinary
buildSrcLibrary
#cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/zipconf.h ../../revzip/src
#cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/config.h ../../revzip/src
cp ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/*.h ../../revzip/src

