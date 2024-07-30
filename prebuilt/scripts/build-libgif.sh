#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${libgif_VERSION} is 1.6.42
#libpng-1.6.42.tar.xz

THIS="giflib"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libgif_VERSION}"
FILE_DIRECTORY="../../thirdparty/libgif/src"

fetchBinary
untarBinary
buildLibrary

