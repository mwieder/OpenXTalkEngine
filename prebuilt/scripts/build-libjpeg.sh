#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${LIBZ_VERSION} is 6b
#https://sourceforge.net/projects/libjpeg/files/latest/download

THIS="libjpeg"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
# should do this with sed
ARCHIVE_DESTINATION="${THIS}sr6"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
unzipBinary
buildLibrary

