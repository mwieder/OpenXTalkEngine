#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${LIBZ_VERSION} is 1.6.42
#libpng-1.6.42.tar.xz

THIS="libpng"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libpng_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
untarBinary
buildLibrary

