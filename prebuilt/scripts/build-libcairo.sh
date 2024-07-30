#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.24 currently ${libcairo_VERSION} is 1.18.0

THIS="libcairo"
URL_ROOT="https://www.cairographics.org/releases/cairo-${libcairo_VERSION}.tar.xz"
ARCHIVE_DESTINATION="cairo-${libcairo_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"
INCLUDE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
untarBinary
buildSrcLibrary
# copy config.h
cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/*.h ${INCLUDE_DIRECTORY}
# copy cairo-features.h
cp -u ${BUILDDIR}/${ARCHIVE_DESTINATION}/build/src/*.h ${INCLUDE_DIRECTORY}

