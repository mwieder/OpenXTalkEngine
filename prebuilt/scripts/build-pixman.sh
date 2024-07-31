#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.24 currently ${pixman} is 0.43.2

THIS="pixman"
URL_ROOT="https://www.cairographics.org/releases/${THIS}-${pixman_VERSION}.tar.xz"
ARCHIVE_DESTINATION="${THIS}-${pixman_VERSION}"
FILE_DIRECTORY="../../thirdparty/libcairo/src"
INCLUDE_DIRECTORY="../../thirdparty/libcairo/src"

fetchBinary
untarBinary
buildSrcLibrary
# copy config.h
cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/*.h ${INCLUDE_DIRECTORY}
# copy cairo-features.h
cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/src/*.h ${INCLUDE_DIRECTORY}

