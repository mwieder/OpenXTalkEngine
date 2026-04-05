#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.24 currently ${pixman_VERSION} is 0.43.2

THIS="pixman"
URL_ROOT="https://www.cairographics.org/releases/${THIS}-${pixman_VERSION}.tar.gz"
ARCHIVE_DESTINATION="${THIS}-${pixman_VERSION}"
FILE_DIRECTORY="../../thirdparty/libcairo/src"
INCLUDE_DIRECTORY="../../thirdparty/libcairo/src"

function buildPixmanLibrary {
	configureBuild
	cmakeBuild
	mesonBuild
	echo "copying header files to ${INCLUDE_DIRECTORY}"
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/${THIS}/*.h ${INCLUDE_DIRECTORY}
	echo "copying C files to ${INCLUDE_DIRECTORY}"
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/${THIS}/*.c ${INCLUDE_DIRECTORY}
	echo "copying .S files to ${INCLUDE_DIRECTORY}"
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/${THIS}/*.S ${INCLUDE_DIRECTORY}
	echo "copying dither files to ${INCLUDE_DIRECTORY}"
	cp -ur ${BUILDDIR}/${ARCHIVE_DESTINATION}/${THIS}/dither ${INCLUDE_DIRECTORY}
	cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/${THIS}/*.h ${INCLUDE_DIRECTORY}
}

fetchBinary
untarBinary
buildPixmanLibrary

