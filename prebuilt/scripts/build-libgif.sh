#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${libgif_VERSION} is 6.1.2
#giflib-6.1.2.tar

THIS="giflib"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
ARCHIVE_DESTINATION="${THIS}-${libgif_VERSION}"
FILE_DIRECTORY="../../thirdparty/libgif/src"

fetchBinary
untarBinary
buildLibrary
mkdir -p ../../thirdparty/libgif/include
cp ${FILE_DIRECTORY}/gif_lib.h ../../thirdparty/libgif/include

