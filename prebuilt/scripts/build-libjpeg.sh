#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2024.07.22 currently ${LIBZ_VERSION} is 6b
#https://sourceforge.net/projects/libjpeg/files/latest/download

SHORT_THIS="jpeg"
THIS="libjpeg"
URL_ROOT="https://sourceforge.net/projects/${THIS}/files/latest/download"
# should do this with sed
ARCHIVE_DESTINATION="${SHORT_THIS}sr6"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
unxzBinary
mv ${SHORT_THIS}-${libjpeg_VERSION} ${ARCHIVE_DESTINATION}
# have to convert the windows-style line endings to linux
pushd ${BUILDDIR}/${ARCHIVE_DESTINATION}
./configure
makeBinary
popd
buildLibrary

