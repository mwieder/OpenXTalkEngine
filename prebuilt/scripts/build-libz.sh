#!/bin/bash

source "${BASEDIR}/scripts/platform.inc"
source "${BASEDIR}/scripts/lib_versions.inc"
source "${BASEDIR}/scripts/util.inc"

# 2023.10.27 currently ${LIBZ_VERSION} is 1.3.1

THIS="libz"
URL_ROOT="https://www.zlib.net/current/zlib.tar.gz"
ARCHIVE_DESTINATION="zlib-${libz_VERSION}"
FILE_DIRECTORY="../../thirdparty/${THIS}/src"

fetchBinary
untarBinary
buildLibrary

